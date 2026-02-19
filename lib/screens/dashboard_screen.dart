import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/agent_model.dart';
import '../widgets/metric_card_widget.dart';
import '../widgets/terminal_widget.dart';
import '../widgets/agent_card_widget.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final metrics = MetricCard.sampleMetrics;
    final logs = TerminalLog.sampleLogs;
    final agents = AgentModel.sampleAgents.take(3).toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          // Metrics Carousel
          SizedBox(
            height: 148,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: metrics.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return MetricCardWidget(metric: metrics[index]);
              },
            ),
          ),
          const SizedBox(height: 24),
          // Terminal Section
          TerminalWidget(logs: logs),
          const SizedBox(height: 32),
          // Agent Inventory
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
          // Agent Cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: agents.map((agent) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AgentCardWidget(
                    agent: agent,
                    onKillSwitch: () {
                      _showActionSnackbar(
                          context, 'Kill switch activated for ${agent.name}');
                    },
                    onAction: () {
                      final action = agent.action == AgentAction.approve
                          ? 'approved'
                          : 'overridden';
                      _showActionSnackbar(
                          context, '${agent.name} $action');
                    },
                  ),
                );
              }).toList(),
            ),
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
