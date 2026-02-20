import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_theme.dart';
import '../services/ai_service.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// SMART SUMMARY WIDGET
// Displays a Gemini-generated executive summary of the entire agent fleet.
// Features: auto-refresh, health-score gauge, key insights, action items.
// ═══════════════════════════════════════════════════════════════════════════════

class SmartSummaryWidget extends StatefulWidget {
  const SmartSummaryWidget({super.key});

  @override
  State<SmartSummaryWidget> createState() => _SmartSummaryWidgetState();
}

class _SmartSummaryWidgetState extends State<SmartSummaryWidget>
    with SingleTickerProviderStateMixin {
  SmartSummary? _summary;
  bool _isLoading = true;
  bool _hasError = false;
  late AnimationController _glowController;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _fetchSummary();
    // Auto-refresh every 2 minutes
    _refreshTimer = Timer.periodic(const Duration(minutes: 2), (_) {
      _fetchSummary();
    });
  }

  @override
  void dispose() {
    _glowController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchSummary() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      final summary = await AIService.instance.getSmartSummary();
      if (mounted) {
        setState(() {
          _summary = summary;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  Color _healthColor(String health) {
    switch (health) {
      case 'healthy':
        return AppTheme.primary;
      case 'degraded':
        return const Color(0xFFFF9500);
      case 'critical':
        return AppTheme.danger;
      default:
        return AppTheme.textMuted;
    }
  }

  IconData _healthIcon(String health) {
    switch (health) {
      case 'healthy':
        return Icons.check_circle_outline;
      case 'degraded':
        return Icons.warning_amber_rounded;
      case 'critical':
        return Icons.error_outline;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7C3AED), Color(0xFF2563EB)],
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_awesome, size: 10, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      'GEMINI AI',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'SMART SUMMARY',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textMuted,
                  letterSpacing: 2,
                ),
              ),
              const Spacer(),
              // Refresh button
              GestureDetector(
                onTap: _isLoading ? null : _fetchSummary,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceDark,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.borderDark),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(AppTheme.primary),
                          ),
                        )
                      : Icon(
                          Icons.refresh,
                          size: 14,
                          color: AppTheme.textMuted,
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Main Card
          if (_isLoading && _summary == null) _buildShimmer(),
          if (_hasError && _summary == null) _buildError(),
          if (_summary != null) _buildSummaryCard(_summary!),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: AppTheme.surfaceDark,
      highlightColor: AppTheme.borderDark,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.danger.withAlpha(60)),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_off, color: AppTheme.danger, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Unable to reach AI agent. Tap refresh to retry.',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(SmartSummary summary) {
    final healthColor = _healthColor(summary.systemHealth);
    final healthIcon = _healthIcon(summary.systemHealth);

    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: healthColor.withAlpha(
                (40 + (30 * _glowController.value)).toInt(),
              ),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: healthColor.withAlpha(
                  (10 + (15 * _glowController.value)).toInt(),
                ),
                blurRadius: 20,
                spreadRadius: 0,
              ),
            ],
          ),
          child: child,
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Health Score Badge + Status
            Row(
              children: [
                // Health Score Circle
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        healthColor.withAlpha(40),
                        healthColor.withAlpha(15),
                      ],
                    ),
                    border: Border.all(
                      color: healthColor.withAlpha(120),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${summary.healthScore}',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: healthColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(healthIcon, size: 14, color: healthColor),
                          const SizedBox(width: 6),
                          Text(
                            summary.systemHealth.toUpperCase(),
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: healthColor,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        summary.summaryText,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Key Insights
            if (summary.keyInsights.isNotEmpty) ...[
              Text(
                'KEY INSIGHTS',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textMuted,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              ...summary.keyInsights.take(3).map((insight) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 5),
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          insight,
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            color: AppTheme.primary.withAlpha(200),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],

            // Risk Factors
            if (summary.riskFactors.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.danger.withAlpha(10),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.danger.withAlpha(40)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.shield_outlined,
                          size: 10,
                          color: AppTheme.danger.withAlpha(180),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'RISK FACTORS',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.danger.withAlpha(180),
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ...summary.riskFactors.map((risk) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Text(
                          '• $risk',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 9,
                            color: AppTheme.textSecondary,
                            height: 1.3,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],

            // Recommended Actions
            if (summary.recommendedActions.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'RECOMMENDED ACTIONS',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textMuted,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              ...summary.recommendedActions
                  .asMap()
                  .entries
                  .take(3)
                  .map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: const Color(0xFF7C3AED).withAlpha(25),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: const Color(0xFF7C3AED).withAlpha(60),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '${entry.key + 1}',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF7C3AED),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],

            // Timestamp
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.access_time,
                  size: 10,
                  color: AppTheme.textMuted.withAlpha(100),
                ),
                const SizedBox(width: 4),
                Text(
                  'Updated ${_formatTimestamp(summary.timestamp)}',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 8,
                    color: AppTheme.textMuted.withAlpha(100),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${dt.month}/${dt.day} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
