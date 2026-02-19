import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  bool _autoApprove = false;
  bool _threatDetection = true;
  bool _costAlerts = true;
  bool _auditLogging = true;
  double _rateLimit = 0.75;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            // System Info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.terminalBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF1E293B)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SYSTEM CONFIG',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textMuted,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('Version', 'ENC-v2.04'),
                  _buildInfoRow('Node ID', 'us-east-1-primary'),
                  _buildInfoRow('Uptime', '14d 7h 32m'),
                  _buildInfoRow('Last Deploy', '2026-02-18 09:14 UTC'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Toggles
            Text(
              'AGENT POLICIES',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppTheme.textMuted,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            _buildToggle(
              'Auto-Approve Agents',
              'Automatically approve new agents',
              Icons.auto_awesome_outlined,
              _autoApprove,
              (val) => setState(() => _autoApprove = val),
            ),
            _buildToggle(
              'Threat Detection',
              'Real-time malware scanning',
              Icons.shield_outlined,
              _threatDetection,
              (val) => setState(() => _threatDetection = val),
            ),
            _buildToggle(
              'Cost Alerts',
              'Notify when budget exceeds threshold',
              Icons.attach_money,
              _costAlerts,
              (val) => setState(() => _costAlerts = val),
            ),
            _buildToggle(
              'Audit Logging',
              'Log all agent activities',
              Icons.history_outlined,
              _auditLogging,
              (val) => setState(() => _auditLogging = val),
            ),
            const SizedBox(height: 24),
            // Rate Limit
            Text(
              'RATE LIMITING',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppTheme.textMuted,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark.withAlpha(128),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.borderDark),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Request Threshold',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        '${(_rateLimit * 10000).toInt()} req/s',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 12,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: AppTheme.primary,
                      inactiveTrackColor: AppTheme.borderDark,
                      thumbColor: AppTheme.primary,
                      overlayColor: AppTheme.primary.withAlpha(51),
                      trackHeight: 3,
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 6),
                    ),
                    child: Slider(
                      value: _rateLimit,
                      onChanged: (val) => setState(() => _rateLimit = val),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Danger Zone
            Text(
              'DANGER ZONE',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppTheme.danger,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            _buildDangerButton(
              'Kill All Agents',
              'Terminate all running agents',
              Icons.power_settings_new,
            ),
            const SizedBox(height: 8),
            _buildDangerButton(
              'Purge Logs',
              'Delete all stored logs',
              Icons.delete_outline,
            ),
            const SizedBox(height: 8),
            _buildDangerButton(
              'Factory Reset',
              'Reset system to defaults',
              Icons.restart_alt,
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              color: AppTheme.textMuted,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              color: AppTheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggle(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark.withAlpha(128),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.borderDark),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 10,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppTheme.primary,
            activeTrackColor: AppTheme.primary.withAlpha(77),
            inactiveThumbColor: AppTheme.textMuted,
            inactiveTrackColor: AppTheme.borderDark,
          ),
        ],
      ),
    );
  }

  Widget _buildDangerButton(String title, String subtitle, IconData icon) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Action blocked: $title requires admin override',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                color: AppTheme.danger,
              ),
            ),
            backgroundColor: AppTheme.terminalBg,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: AppTheme.danger.withAlpha(77)),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.danger.withAlpha(13),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.danger.withAlpha(51)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.danger, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.danger,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 10,
                      color: AppTheme.danger.withAlpha(153),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppTheme.danger.withAlpha(153),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
