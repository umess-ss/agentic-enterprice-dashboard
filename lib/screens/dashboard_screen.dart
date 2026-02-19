import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/agent_model.dart';
import '../services/supabase_agent_service.dart';
import '../widgets/metric_card_widget.dart';
import '../widgets/terminal_widget.dart';
import '../widgets/agent_card_widget.dart';
import '../widgets/hitl_approval_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _service = SupabaseAgentService.instance;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),

          // ── METRICS CAROUSEL (Live from Supabase) ──
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: _service.streamMissions(),
            builder: (context, snapshot) {
              return FutureBuilder<Map<String, dynamic>>(
                future: _service.getMetrics(),
                builder: (context, metricsSnap) {
                  final metrics = metricsSnap.hasData
                      ? MetricCard.fromLiveData(metricsSnap.data!)
                      : MetricCard.sampleMetrics;

                  return SizedBox(
                    height: 148,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: metrics.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        return MetricCardWidget(metric: metrics[index]);
                      },
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 24),

          // ── HITL APPROVAL CARDS (Real-time from agent_actions) ──
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: _service.streamPendingActions(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SizedBox.shrink();
              }

              final actions = snapshot.data!
                  .map((d) => AgentActionModel.fromSupabase(d))
                  .toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7C3AED).withAlpha(25),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: const Color(0xFF7C3AED).withAlpha(80),
                            ),
                          ),
                          child: Text(
                            '${actions.length} PENDING',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF7C3AED),
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'APPROVAL QUEUE',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textMuted,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: actions.map((action) {
                        return HitlApprovalCard(
                          action: action,
                          onDismiss: () {
                            // Stream auto-updates
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              );
            },
          ),

          // ── REAL-TIME TERMINAL (Live from agent_logs) ──
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: _service.streamLogs(limit: 10),
            builder: (context, snapshot) {
              final logs = snapshot.hasData
                  ? snapshot.data!
                      .map((d) => TerminalLog.fromSupabase(d))
                      .toList()
                  : TerminalLog.sampleLogs;

              return TerminalWidget(logs: logs);
            },
          ),
          const SizedBox(height: 32),

          // ── ACTIVE AGENT INVENTORY (Live from mission_control) ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'ACTIVE AGENT INVENTORY',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppTheme.textMuted,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 16),

          StreamBuilder<List<Map<String, dynamic>>>(
            stream: _service.streamMissions(),
            builder: (context, snapshot) {
              final agents = snapshot.hasData
                  ? snapshot.data!
                      .map((d) => AgentModel.fromSupabase(d))
                      .take(4)
                      .toList()
                  : AgentModel.sampleAgents.take(3).toList();

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: agents.map((agent) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AgentCardWidget(
                        agent: agent,
                        onKillSwitch: () {
                          _showActionSnackbar(context,
                              'Kill switch activated for ${agent.name}');
                          if (agent.dbId != null) {
                            _service.updateMissionStatus(
                                agent.dbId!, 'Failed');
                            _service.writeLog(
                              agentId: agent.id,
                              source: 'KILL_SWITCH',
                              message: '${agent.name}_TERMINATED',
                              level: 'error',
                            );
                          }
                        },
                        onAction: () {
                          final actionLabel =
                              agent.action == AgentAction.approve
                                  ? 'approved'
                                  : 'overridden';
                          _showActionSnackbar(
                              context, '${agent.name} $actionLabel');
                        },
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  void _showActionSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 12,
            color: AppTheme.primary,
          ),
        ),
        backgroundColor: AppTheme.terminalBg,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: AppTheme.primary.withAlpha(77)),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
