// supabase/functions/agent-brain/index.ts
// ═══════════════════════════════════════════════════════════════════════════════
// AGENT BRAIN — Supabase Edge Function
// Integrates Gemini 2.0 API to analyze mission_control data for anomalies
// and write 'Proposed Action' entries back to the agent_actions table.
//
// Endpoint: POST /functions/v1/agent-brain
// Auth: Supabase anon key or service role key
// ═══════════════════════════════════════════════════════════════════════════════

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

// ─── CORS Headers ────────────────────────────────────────────────────────────
const corsHeaders = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers":
        "authorization, x-client-info, apikey, content-type",
};

// ─── Gemini 2.0 API Configuration ────────────────────────────────────────────
const GEMINI_API_KEY = Deno.env.get("GEMINI_API_KEY") ?? "";
const GEMINI_API_URL =
    "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent";

// ─── System Prompt for Anomaly Detection ─────────────────────────────────────
const SYSTEM_PROMPT = `You are an enterprise AI anomaly detection agent for a multi-agent orchestration system.
You analyze mission control data from autonomous AI agents and detect:
1. Cost anomalies (agents exceeding budget thresholds)
2. Performance degradation (declining confidence scores)
3. Status inconsistencies (stuck or failed agents)
4. Security risks (unauthorized actions or unusual patterns)
5. Resource contention (multiple agents competing for same resources)

For each anomaly found, produce a structured JSON response with:
- anomaly_type: one of ["cost_spike", "performance_drop", "status_stuck", "security_risk", "resource_conflict"]
- severity: one of ["low", "medium", "high", "critical"]
- affected_agent_id: the agent_id experiencing the issue
- affected_agent_name: the agent name
- title: a concise action title (max 80 chars)
- description: a detailed explanation of the anomaly and proposed fix
- proposed_action: the recommended action to take
- confidence: your confidence in this assessment (0.0 to 1.0)

IMPORTANT: Return a JSON array of anomaly objects. If no anomalies are found, return an empty array [].
Always be conservative — flag potential issues early rather than waiting for failures.`;

// ─── Smart Summary Prompt ────────────────────────────────────────────────────
const SUMMARY_PROMPT = `You are an AI analyst for an enterprise multi-agent dashboard.
Given the current state of all agents in the mission control system, produce a concise
executive summary covering:
1. Overall system health (healthy / degraded / critical)
2. Key metrics overview (active agents, total cost, alerts)
3. Notable trends or patterns
4. Top 3 recommended actions for the human operator

Format your response as JSON:
{
  "system_health": "healthy|degraded|critical",
  "health_score": 0-100,
  "summary_text": "2-3 sentence executive overview",
  "key_insights": ["insight1", "insight2", "insight3"],
  "recommended_actions": ["action1", "action2", "action3"],
  "risk_factors": ["risk1", "risk2"],
  "timestamp": "ISO timestamp"
}`;

// ─── Gemini API Call ─────────────────────────────────────────────────────────
async function callGemini(prompt: string, data: string): Promise<string> {
    const response = await fetch(`${GEMINI_API_URL}?key=${GEMINI_API_KEY}`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
            contents: [
                {
                    parts: [
                        { text: prompt },
                        { text: `\n\nCurrent Mission Control Data:\n${data}` },
                    ],
                },
            ],
            generationConfig: {
                temperature: 0.2,
                topK: 40,
                topP: 0.95,
                maxOutputTokens: 4096,
                responseMimeType: "application/json",
            },
        }),
    });

    if (!response.ok) {
        const errorBody = await response.text();
        throw new Error(`Gemini API error (${response.status}): ${errorBody}`);
    }

    const result = await response.json();
    return result.candidates?.[0]?.content?.parts?.[0]?.text ?? "[]";
}

// ─── MCP-Style Schema Access Layer ──────────────────────────────────────────
// Provides structured read/write access to the Supabase schema,
// following Model Context Protocol patterns for resource access.

interface MCPResource {
    uri: string;
    name: string;
    description: string;
    mimeType: string;
}

interface MCPContext {
    resources: MCPResource[];
    read: (table: string, filters?: Record<string, unknown>) => Promise<unknown[]>;
    write: (table: string, data: Record<string, unknown>) => Promise<unknown>;
    update: (table: string, id: string, data: Record<string, unknown>) => Promise<unknown>;
}

function createMCPContext(supabaseClient: ReturnType<typeof createClient>): MCPContext {
    const resources: MCPResource[] = [
        {
            uri: "supabase://mission_control",
            name: "Mission Control",
            description: "Real-time agent mission status, tasks, and confidence scores",
            mimeType: "application/json",
        },
        {
            uri: "supabase://agent_actions",
            name: "Agent Actions",
            description: "HITL approval queue for proposed agent actions",
            mimeType: "application/json",
        },
        {
            uri: "supabase://agent_logs",
            name: "Agent Logs",
            description: "Real-time agent activity log stream",
            mimeType: "application/json",
        },
    ];

    return {
        resources,
        read: async (table: string, filters?: Record<string, unknown>) => {
            let query = supabaseClient.from(table).select("*");
            if (filters) {
                for (const [key, value] of Object.entries(filters)) {
                    query = query.eq(key, value);
                }
            }
            const { data, error } = await query;
            if (error) throw new Error(`MCP Read Error [${table}]: ${error.message}`);
            return data ?? [];
        },
        write: async (table: string, data: Record<string, unknown>) => {
            const { data: result, error } = await supabaseClient
                .from(table)
                .insert(data)
                .select()
                .single();
            if (error) throw new Error(`MCP Write Error [${table}]: ${error.message}`);
            return result;
        },
        update: async (table: string, id: string, data: Record<string, unknown>) => {
            const { data: result, error } = await supabaseClient
                .from(table)
                .update(data)
                .eq("id", id)
                .select()
                .single();
            if (error) throw new Error(`MCP Update Error [${table}]: ${error.message}`);
            return result;
        },
    };
}

// ─── Main Handler ────────────────────────────────────────────────────────────
serve(async (req: Request) => {
    // Handle CORS preflight
    if (req.method === "OPTIONS") {
        return new Response("ok", { headers: corsHeaders });
    }

    try {
        // Parse request body
        const body = await req.json().catch(() => ({}));
        const mode = body.mode ?? "analyze"; // "analyze" | "summary" | "confirm"
        const actionId = body.action_id;
        const missionId = body.mission_id;

        // Initialize Supabase client with service role for full access
        const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
        const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
        const supabaseClient = createClient(supabaseUrl, supabaseServiceKey);

        // Create MCP context for structured schema access
        const mcp = createMCPContext(supabaseClient);

        // ─── MODE: CONFIRM ───────────────────────────────────────────────────
        // Human confirmed an agent's proposed action
        if (mode === "confirm" && actionId) {
            const action = await mcp.read("agent_actions", { id: actionId });
            if (action.length === 0) {
                return new Response(
                    JSON.stringify({ error: "Action not found" }),
                    { status: 404, headers: { ...corsHeaders, "Content-Type": "application/json" } }
                );
            }

            // Update action status to confirmed
            await mcp.update("agent_actions", actionId, {
                status: "confirmed",
                approved_by: "human_operator",
                approved_at: new Date().toISOString(),
            });

            // Log the confirmation
            const actionData = action[0] as Record<string, unknown>;
            await mcp.write("agent_logs", {
                agent_id: actionData.agent_id ?? "system",
                source: "AGENT_BRAIN",
                message: `ACTION_CONFIRMED: ${actionData.title ?? "Unknown action"} — executing proposed plan`,
                level: "info",
            });

            // Update the related mission status if applicable
            if (actionData.mission_id) {
                await mcp.update("mission_control", actionData.mission_id as string, {
                    status: "Executing",
                });
            }

            return new Response(
                JSON.stringify({
                    success: true,
                    message: "Action confirmed and executing",
                    action_id: actionId,
                }),
                { headers: { ...corsHeaders, "Content-Type": "application/json" } }
            );
        }

        // ─── FETCH MISSION DATA via MCP ──────────────────────────────────────
        let missions;
        if (missionId) {
            missions = await mcp.read("mission_control", { id: missionId });
        } else {
            missions = await mcp.read("mission_control");
        }

        if (!missions || missions.length === 0) {
            return new Response(
                JSON.stringify({
                    success: true,
                    message: "No missions found to analyze",
                    anomalies: [],
                }),
                { headers: { ...corsHeaders, "Content-Type": "application/json" } }
            );
        }

        const missionDataStr = JSON.stringify(missions, null, 2);

        // ─── MODE: SUMMARY ──────────────────────────────────────────────────
        if (mode === "summary") {
            // Also fetch pending actions for context
            const pendingActions = await mcp.read("agent_actions", { status: "pending" });

            const enrichedData = JSON.stringify(
                {
                    missions,
                    pending_actions: pendingActions,
                    meta: {
                        total_missions: missions.length,
                        total_pending: pendingActions.length,
                        analysis_timestamp: new Date().toISOString(),
                    },
                },
                null,
                2
            );

            const summaryText = await callGemini(SUMMARY_PROMPT, enrichedData);
            let summary;
            try {
                summary = JSON.parse(summaryText);
            } catch {
                summary = {
                    system_health: "unknown",
                    health_score: 50,
                    summary_text: summaryText,
                    key_insights: [],
                    recommended_actions: [],
                    risk_factors: [],
                    timestamp: new Date().toISOString(),
                };
            }

            // Log the analysis
            await mcp.write("agent_logs", {
                agent_id: "agent-brain",
                source: "GEMINI_ANALYSIS",
                message: `SMART_SUMMARY: System health=${summary.system_health}, Score=${summary.health_score}%`,
                level: summary.system_health === "critical" ? "error" : "info",
            });

            return new Response(JSON.stringify({ success: true, summary }), {
                headers: { ...corsHeaders, "Content-Type": "application/json" },
            });
        }

        // ─── MODE: ANALYZE (default) ─────────────────────────────────────────
        const analysisText = await callGemini(SYSTEM_PROMPT, missionDataStr);

        let anomalies: Array<Record<string, unknown>>;
        try {
            anomalies = JSON.parse(analysisText);
            if (!Array.isArray(anomalies)) anomalies = [anomalies];
        } catch {
            anomalies = [];
        }

        // Write each anomaly as a proposed action in agent_actions (MCP write)
        const writtenActions: Array<Record<string, unknown>> = [];
        for (const anomaly of anomalies) {
            const riskMap: Record<string, string> = {
                critical: "critical",
                high: "high",
                medium: "medium",
                low: "low",
            };

            const actionData = {
                agent_id: anomaly.affected_agent_id ?? "system",
                agent_name: anomaly.affected_agent_name ?? "System Agent",
                mission_id: missionId ?? null,
                action_type: "approval_required",
                title: anomaly.title ?? "Anomaly Detected",
                description: anomaly.description ?? "AI-detected anomaly requires review",
                risk_level: riskMap[anomaly.severity as string] ?? "medium",
                status: "pending",
                payload: {
                    anomaly_type: anomaly.anomaly_type,
                    proposed_action: anomaly.proposed_action,
                    confidence: anomaly.confidence,
                    detected_by: "gemini-2.0-flash",
                    detected_at: new Date().toISOString(),
                },
                expires_at: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
            };

            try {
                const result = await mcp.write("agent_actions", actionData);
                writtenActions.push(result as Record<string, unknown>);
            } catch (writeErr) {
                console.error("Failed to write action:", writeErr);
            }
        }

        // Log the analysis run
        await mcp.write("agent_logs", {
            agent_id: "agent-brain",
            source: "GEMINI_ANALYSIS",
            message: `ANOMALY_SCAN: Found ${anomalies.length} anomalies across ${missions.length} missions. ${writtenActions.length} proposed actions created.`,
            level: anomalies.length > 0 ? "warning" : "info",
        });

        return new Response(
            JSON.stringify({
                success: true,
                anomalies_found: anomalies.length,
                actions_created: writtenActions.length,
                anomalies,
                actions: writtenActions,
                mcp_resources_accessed: mcp.resources.map((r) => r.uri),
            }),
            { headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
    } catch (err) {
        console.error("Agent Brain Error:", err);
        return new Response(
            JSON.stringify({
                success: false,
                error: err instanceof Error ? err.message : "Unknown error",
            }),
            {
                status: 500,
                headers: { ...corsHeaders, "Content-Type": "application/json" },
            }
        );
    }
});
