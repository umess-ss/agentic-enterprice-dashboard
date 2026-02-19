import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/agent_model.dart';

class AgentCardWidget extends StatelessWidget {
  final AgentModel agent;
  final VoidCallback? onKillSwitch;
  final VoidCallback? onAction;

  const AgentCardWidget({
    super.key,
    required this.agent,
    this.onKillSwitch,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark.withAlpha(128),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.borderDark,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Top row - Agent info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Agent icon
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: _iconBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  agent.iconData,
                  color: _iconColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              // Agent name and status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      agent.name,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          height: 6,
                          width: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _statusColor,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          agent.statusText,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 10,
                            fontWeight: agent.isDangerous
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: agent.isDangerous
                                ? AppTheme.danger
                                : AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // ID & Cost
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'ID: ${agent.id}',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      color: AppTheme.textMuted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    agent.costFormatted,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 12,
                      color: agent.isDangerous
                          ? AppTheme.primary
                          : AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Action buttons
          Row(
            children: [
              // Kill Switch
              Expanded(
                child: GestureDetector(
                  onTap: onKillSwitch,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: agent.isDangerous
                          ? AppTheme.danger.withAlpha(51)
                          : AppTheme.danger.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: agent.isDangerous
                            ? AppTheme.danger.withAlpha(128)
                            : AppTheme.danger.withAlpha(77),
                        width: 1,
                      ),
                      boxShadow: agent.isDangerous
                          ? [
                              BoxShadow(
                                color: AppTheme.danger.withAlpha(77),
                                blurRadius: 12,
                                spreadRadius: 0,
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.power_settings_new,
                          size: 14,
                          color: AppTheme.danger,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'KILL SWITCH',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.danger,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Approve / Override
              Expanded(
                child: GestureDetector(
                  onTap: onAction,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: agent.isDangerous
                          ? AppTheme.primary.withAlpha(51)
                          : AppTheme.primary,
                      borderRadius: BorderRadius.circular(8),
                      border: agent.isDangerous
                          ? Border.all(
                              color: AppTheme.primary.withAlpha(77),
                              width: 1,
                            )
                          : null,
                      boxShadow: !agent.isDangerous
                          ? [
                              BoxShadow(
                                color: AppTheme.primary.withAlpha(51),
                                blurRadius: 15,
                                spreadRadius: 0,
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.verified_outlined,
                          size: 14,
                          color: agent.isDangerous
                              ? AppTheme.primary
                              : AppTheme.backgroundDark,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          agent.action == AgentAction.approve
                              ? 'APPROVE'
                              : 'OVERRIDE',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: agent.isDangerous
                                ? AppTheme.primary
                                : AppTheme.backgroundDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color get _iconBgColor {
    if (agent.isDangerous) return AppTheme.danger.withAlpha(51);
    if (agent.isHealthy) return AppTheme.primary.withAlpha(51);
    return AppTheme.borderDark;
  }

  Color get _iconColor {
    if (agent.isDangerous) return AppTheme.danger;
    if (agent.isHealthy) return AppTheme.primary;
    return AppTheme.textMuted;
  }

  Color get _statusColor {
    if (agent.isDangerous) return AppTheme.danger;
    return AppTheme.primary;
  }
}
