import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// AI SERVICE — Calls the agent-brain Edge Function
// Provides Smart Summary, Anomaly Analysis, and HITL Confirmation
// ═══════════════════════════════════════════════════════════════════════════════

/// Data model for the AI-generated Smart Summary
class SmartSummary {
  final String systemHealth;
  final int healthScore;
  final String summaryText;
  final List<String> keyInsights;
  final List<String> recommendedActions;
  final List<String> riskFactors;
  final DateTime timestamp;

  const SmartSummary({
    required this.systemHealth,
    required this.healthScore,
    required this.summaryText,
    required this.keyInsights,
    required this.recommendedActions,
    required this.riskFactors,
    required this.timestamp,
  });

  factory SmartSummary.fromJson(Map<String, dynamic> json) {
    return SmartSummary(
      systemHealth: json['system_health'] ?? 'unknown',
      healthScore: json['health_score'] ?? 50,
      summaryText: json['summary_text'] ?? 'Analysis unavailable',
      keyInsights: List<String>.from(json['key_insights'] ?? []),
      recommendedActions: List<String>.from(json['recommended_actions'] ?? []),
      riskFactors: List<String>.from(json['risk_factors'] ?? []),
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }

  /// Color-mapped health status
  bool get isHealthy => systemHealth == 'healthy';
  bool get isDegraded => systemHealth == 'degraded';
  bool get isCritical => systemHealth == 'critical';
}

/// Data model for an individual anomaly detection result
class AnomalyResult {
  final String anomalyType;
  final String severity;
  final String affectedAgentId;
  final String affectedAgentName;
  final String title;
  final String description;
  final String proposedAction;
  final double confidence;

  const AnomalyResult({
    required this.anomalyType,
    required this.severity,
    required this.affectedAgentId,
    required this.affectedAgentName,
    required this.title,
    required this.description,
    required this.proposedAction,
    required this.confidence,
  });

  factory AnomalyResult.fromJson(Map<String, dynamic> json) {
    return AnomalyResult(
      anomalyType: json['anomaly_type'] ?? 'unknown',
      severity: json['severity'] ?? 'medium',
      affectedAgentId: json['affected_agent_id'] ?? '',
      affectedAgentName: json['affected_agent_name'] ?? 'Unknown',
      title: json['title'] ?? 'Anomaly Detected',
      description: json['description'] ?? '',
      proposedAction: json['proposed_action'] ?? '',
      confidence: (json['confidence'] ?? 0.5).toDouble(),
    );
  }
}

/// Response from the analyze endpoint
class AnalysisResponse {
  final bool success;
  final int anomaliesFound;
  final int actionsCreated;
  final List<AnomalyResult> anomalies;
  final String? error;

  const AnalysisResponse({
    required this.success,
    this.anomaliesFound = 0,
    this.actionsCreated = 0,
    this.anomalies = const [],
    this.error,
  });

  factory AnalysisResponse.fromJson(Map<String, dynamic> json) {
    return AnalysisResponse(
      success: json['success'] ?? false,
      anomaliesFound: json['anomalies_found'] ?? 0,
      actionsCreated: json['actions_created'] ?? 0,
      anomalies: (json['anomalies'] as List<dynamic>?)
              ?.map((a) => AnomalyResult.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
      error: json['error'],
    );
  }
}

// ─── AIService Singleton ─────────────────────────────────────────────────────
class AIService {
  static AIService? _instance;
  late final SupabaseClient _client;

  AIService._();

  static AIService get instance {
    _instance ??= AIService._();
    return _instance!;
  }

  /// Initialize with Supabase client (call after SupabaseAgentService.initialize())
  void init(SupabaseClient client) {
    _client = client;
  }

  // ─── Smart Summary ──────────────────────────────────────────────────────
  /// Calls the agent-brain Edge Function in 'summary' mode
  /// Returns a Gemini-generated analysis of the entire system state.
  Future<SmartSummary> getSmartSummary() async {
    try {
      final response = await _client.functions.invoke(
        'agent-brain',
        body: {'mode': 'summary'},
      );

      final data = response.data;
      if (data == null) {
        throw Exception('Empty response from agent-brain');
      }

      final Map<String, dynamic> responseMap;
      if (data is String) {
        responseMap = jsonDecode(data) as Map<String, dynamic>;
      } else {
        responseMap = data as Map<String, dynamic>;
      }

      if (responseMap['success'] == true && responseMap['summary'] != null) {
        return SmartSummary.fromJson(
          responseMap['summary'] as Map<String, dynamic>,
        );
      } else {
        throw Exception(responseMap['error'] ?? 'Analysis failed');
      }
    } catch (e) {
      debugPrint('AIService.getSmartSummary error: $e');
      // Return a fallback summary so the UI doesn't crash
      return SmartSummary(
        systemHealth: 'unknown',
        healthScore: 0,
        summaryText:
            'Unable to connect to AI agent. Check Edge Function deployment and GEMINI_API_KEY.',
        keyInsights: ['AI analysis currently unavailable'],
        recommendedActions: ['Verify Edge Function deployment', 'Check API key configuration'],
        riskFactors: ['Analysis service offline'],
        timestamp: DateTime.now(),
      );
    }
  }

  // ─── Anomaly Analysis ──────────────────────────────────────────────────
  /// Runs anomaly detection across all missions or a specific mission.
  Future<AnalysisResponse> runAnomalyAnalysis({String? missionId}) async {
    try {
      final body = <String, dynamic>{'mode': 'analyze'};
      if (missionId != null) body['mission_id'] = missionId;

      final response = await _client.functions.invoke(
        'agent-brain',
        body: body,
      );

      final data = response.data;
      if (data == null) {
        throw Exception('Empty response from agent-brain');
      }

      final Map<String, dynamic> responseMap;
      if (data is String) {
        responseMap = jsonDecode(data) as Map<String, dynamic>;
      } else {
        responseMap = data as Map<String, dynamic>;
      }

      return AnalysisResponse.fromJson(responseMap);
    } catch (e) {
      debugPrint('AIService.runAnomalyAnalysis error: $e');
      return AnalysisResponse(
        success: false,
        error: e.toString(),
      );
    }
  }

  // ─── HITL Confirmation ─────────────────────────────────────────────────
  /// Sends a 'Confirmed' status to execute the agent's proposed plan.
  /// This is the Human-in-the-Loop approval that triggers action execution.
  Future<bool> confirmAction(String actionId) async {
    try {
      final response = await _client.functions.invoke(
        'agent-brain',
        body: {
          'mode': 'confirm',
          'action_id': actionId,
        },
      );

      final data = response.data;
      if (data == null) return false;

      final Map<String, dynamic> responseMap;
      if (data is String) {
        responseMap = jsonDecode(data) as Map<String, dynamic>;
      } else {
        responseMap = data as Map<String, dynamic>;
      }

      return responseMap['success'] == true;
    } catch (e) {
      debugPrint('AIService.confirmAction error: $e');
      return false;
    }
  }
}
