import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class LogsScreen extends StatefulWidget {
  const LogsScreen({super.key});

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _cursorController;
  String _selectedLevel = 'All';
  final List<String> _levels = ['All', 'Info', 'Warning', 'Error'];

  final List<_ExtendedLog> _logs = [
    _ExtendedLog('14:18:32', 'SYSTEM', 'BOOT_SEQUENCE_COMPLETE', 'info'),
    _ExtendedLog('14:19:10', 'AUTH_ENGINE', 'TOKEN_REFRESH_SUCCESS', 'info'),
    _ExtendedLog('14:19:45', 'FIREWALL', 'RULE_UPDATE_APPLIED', 'info'),
    _ExtendedLog('14:20:01', 'AGENT_BETA', 'ACCESS_GRANTED', 'info'),
    _ExtendedLog('14:20:05', 'MONITORING_ACTIVE', 'SYSTEM_STABLE', 'info'),
    _ExtendedLog(
        '14:20:22', 'RATE_LIMITER', 'THRESHOLD_REACHED_API_V2', 'warning'),
    _ExtendedLog('14:21:12', 'THREAT_SCAN', 'NO_MALWARE_DETECTED', 'info'),
    _ExtendedLog(
        '14:21:58', 'DB_CLUSTER', 'REPLICATION_LAG_DETECTED', 'warning'),
    _ExtendedLog('14:22:15', 'AGENT_GAMMA', 'TASK_EXECUTION_FAILED', 'error'),
    _ExtendedLog('14:22:45', 'AGENT_KAPPA', 'DATA_INGESTION_START', 'info'),
    _ExtendedLog(
        '14:23:10', 'GATEWAY_WARN', 'HIGH_TRAFFIC_FLOW', 'warning'),
    _ExtendedLog('14:23:12', 'SYSTEM', 'LISTENING', 'info'),
    _ExtendedLog(
        '14:23:45', 'SSL_MANAGER', 'CERTIFICATE_EXPIRY_30D', 'warning'),
    _ExtendedLog(
        '14:24:01', 'AGENT_DELTA', 'MEMORY_ALLOCATION_ERROR', 'error'),
  ];

  @override
  void initState() {
    super.initState();
    _cursorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _cursorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredLogs = _getFilteredLogs();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        // Filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: _levels.map((level) {
              final isSelected = _selectedLevel == level;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedLevel = level),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _getLevelColor(level).withAlpha(25)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? _getLevelColor(level).withAlpha(128)
                            : AppTheme.borderDark,
                      ),
                    ),
                    child: Text(
                      level,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? _getLevelColor(level)
                            : AppTheme.textMuted,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        // Terminal container
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.terminalBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF1E293B),
                width: 1,
              ),
            ),
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: filteredLogs.length,
              itemBuilder: (context, index) {
                final log = filteredLogs[index];
                final isLast = index == filteredLogs.length - 1;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Level indicator
                      Container(
                        width: 3,
                        height: 14,
                        margin: const EdgeInsets.only(right: 8, top: 2),
                        decoration: BoxDecoration(
                          color: _getLevelColor(log.level),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Text(
                        '[${log.timestamp}] ',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                          color: AppTheme.primary.withAlpha(128),
                        ),
                      ),
                      Text(
                        '${log.source}: ',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _getLevelColor(log.level),
                          shadows: [
                            Shadow(
                              color: _getLevelColor(log.level).withAlpha(153),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                      Flexible(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                log.message,
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 11,
                                  color: AppTheme.primary.withAlpha(230),
                                  shadows: [
                                    Shadow(
                                      color:
                                          AppTheme.primary.withAlpha(102),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isLast)
                              AnimatedBuilder(
                                animation: _cursorController,
                                builder: (context, child) {
                                  return Opacity(
                                    opacity: _cursorController.value > 0.5
                                        ? 1.0
                                        : 0.0,
                                    child: Text(
                                      '_',
                                      style: GoogleFonts.jetBrainsMono(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.primary,
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  Color _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'error':
        return AppTheme.danger;
      case 'warning':
        return const Color(0xFFFFA726);
      case 'info':
        return AppTheme.primary;
      default:
        return AppTheme.primary;
    }
  }

  List<_ExtendedLog> _getFilteredLogs() {
    if (_selectedLevel == 'All') return _logs;
    return _logs
        .where((l) => l.level.toLowerCase() == _selectedLevel.toLowerCase())
        .toList();
  }
}

class _ExtendedLog {
  final String timestamp;
  final String source;
  final String message;
  final String level;

  _ExtendedLog(this.timestamp, this.source, this.message, this.level);
}
