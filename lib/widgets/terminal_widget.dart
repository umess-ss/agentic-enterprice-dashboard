import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/agent_model.dart';

class TerminalWidget extends StatefulWidget {
  final List<TerminalLog> logs;

  const TerminalWidget({super.key, required this.logs});

  @override
  State<TerminalWidget> createState() => _TerminalWidgetState();
}

class _TerminalWidgetState extends State<TerminalWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _cursorController;

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'REAL-TIME TERMINAL',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textMuted,
                  letterSpacing: 2,
                ),
              ),
              Text(
                'ENC-v2.04',
                style: AppTheme.monoSmallStyle.copyWith(
                  color: AppTheme.primary.withAlpha(128),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Terminal body
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          height: 200,
          decoration: BoxDecoration(
            color: AppTheme.terminalBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFF1E293B),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...widget.logs.asMap().entries.map((entry) {
                final log = entry.value;
                final isLast = entry.key == widget.logs.length - 1;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                          color: log.isWarning
                              ? AppTheme.danger
                              : AppTheme.primary,
                          shadows: [
                            Shadow(
                              color: (log.isWarning
                                      ? AppTheme.danger
                                      : AppTheme.primary)
                                  .withAlpha(153),
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
                                          AppTheme.primary.withAlpha(153),
                                      blurRadius: 8,
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
                                        shadows: [
                                          Shadow(
                                            color: AppTheme.primary
                                                .withAlpha(153),
                                            blurRadius: 8,
                                          ),
                                        ],
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
              }),
            ],
          ),
        ),
      ],
    );
  }
}
