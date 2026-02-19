import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/agent_model.dart';
import '../services/supabase_agent_service.dart';
import '../widgets/agent_card_widget.dart';

class AgentsScreen extends StatefulWidget {
  const AgentsScreen({super.key});

  @override
  State<AgentsScreen> createState() => _AgentsScreenState();
}

class _AgentsScreenState extends State<AgentsScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Executing', 'Thinking', 'Completed'];
  final _service = SupabaseAgentService.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _service.streamMissions(),
      builder: (context, snapshot) {
        final allAgents = snapshot.hasData
            ? snapshot.data!.map((d) => AgentModel.fromSupabase(d)).toList()
            : AgentModel.sampleAgents;

        final filteredAgents = _getFilteredAgents(allAgents);

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Stats Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildStatChip(
                      '${allAgents.length}',
                      'Total',
                      AppTheme.primary,
                    ),
                    const SizedBox(width: 12),
                    _buildStatChip(
                      '${allAgents.where((a) => a.missionStatus == MissionStatus.executing).length}',
                      'Executing',
                      AppTheme.primary,
                    ),
                    const SizedBox(width: 12),
                    _buildStatChip(
                      '${allAgents.where((a) => a.isThinking).length}',
                      'Thinking',
                      const Color(0xFFFFCC00),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Filters
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: _filters.map((filter) {
                    final isSelected = _selectedFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedFilter = filter),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.primary.withAlpha(25)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.primary.withAlpha(128)
                                  : AppTheme.borderDark,
                            ),
                          ),
                          child: Text(
                            filter,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? AppTheme.primary
                                  : AppTheme.textMuted,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
              // Section Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      'AGENT REGISTRY',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textMuted,
                        letterSpacing: 2,
                      ),
                    ),
                    const Spacer(),
                    if (snapshot.hasData)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withAlpha(20),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'LIVE',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primary,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Agent Cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: filteredAgents.map((agent) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AgentCardWidget(
                        agent: agent,
                        onKillSwitch: () {
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Kill switch activated for ${agent.name}',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 12,
                                  color: AppTheme.danger,
                                ),
                              ),
                              backgroundColor: AppTheme.terminalBg,
                            ),
                          );
                        },
                        onAction: () {
                          final action = agent.action == AgentAction.approve
                              ? 'approved'
                              : 'overridden';
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${agent.name} $action',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 12,
                                  color: AppTheme.primary,
                                ),
                              ),
                              backgroundColor: AppTheme.terminalBg,
                            ),
                          );
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
      },
    );
  }

  Widget _buildStatChip(String count, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withAlpha(13),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withAlpha(51)),
        ),
        child: Column(
          children: [
            Text(
              count,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            Text(
              label.toUpperCase(),
              style: GoogleFonts.spaceGrotesk(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: color,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<AgentModel> _getFilteredAgents(List<AgentModel> agents) {
    switch (_selectedFilter) {
      case 'Executing':
        return agents
            .where((a) => a.missionStatus == MissionStatus.executing)
            .toList();
      case 'Thinking':
        return agents.where((a) => a.isThinking).toList();
      case 'Completed':
        return agents
            .where((a) => a.missionStatus == MissionStatus.completed)
            .toList();
      default:
        return agents;
    }
  }
}
