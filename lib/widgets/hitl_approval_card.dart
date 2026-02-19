import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/agent_model.dart';
import '../services/supabase_agent_service.dart';

/// Human-in-the-Loop Approval Card
/// Overlays on the UI when an agent proposes an action requiring human approval.
class HitlApprovalCard extends StatefulWidget {
  final AgentActionModel action;
  final VoidCallback? onDismiss;

  const HitlApprovalCard({
    super.key,
    required this.action,
    this.onDismiss,
  });

  @override
  State<HitlApprovalCard> createState() => _HitlApprovalCardState();
}

class _HitlApprovalCardState extends State<HitlApprovalCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _handleApprove() async {
    setState(() => _isProcessing = true);
    try {
      await SupabaseAgentService.instance.approveAction(widget.action.id);
      // Write log entry
      await SupabaseAgentService.instance.writeLog(
        agentId: widget.action.agentId,
        source: 'HITL_GATE',
        message: 'ACTION_APPROVED: ${widget.action.title}',
        level: 'info',
      );
    } catch (e) {
      debugPrint('Approve error: $e');
    }
    if (mounted) {
      setState(() => _isProcessing = false);
      widget.onDismiss?.call();
    }
  }

  Future<void> _handleReject() async {
    setState(() => _isProcessing = true);
    try {
      await SupabaseAgentService.instance.rejectAction(widget.action.id);
      // Write log entry
      await SupabaseAgentService.instance.writeLog(
        agentId: widget.action.agentId,
        source: 'HITL_GATE',
        message: 'ACTION_REJECTED: ${widget.action.title}',
        level: 'warning',
      );
    } catch (e) {
      debugPrint('Reject error: $e');
    }
    if (mounted) {
      setState(() => _isProcessing = false);
      widget.onDismiss?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final action = widget.action;

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: action.riskColor.withAlpha(
                (80 + (50 * _pulseController.value)).toInt(),
              ),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: action.riskColor.withAlpha(
                  (20 + (30 * _pulseController.value)).toInt(),
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
            // Header - HITL badge + risk level
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C3AED).withAlpha(30),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: const Color(0xFF7C3AED).withAlpha(100),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.person_outline,
                        size: 10,
                        color: Color(0xFF7C3AED),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'HUMAN-IN-THE-LOOP',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF7C3AED),
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: action.riskColor.withAlpha(20),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: action.riskColor.withAlpha(80),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        action.riskIcon,
                        size: 10,
                        color: action.riskColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        action.riskLevel.toUpperCase(),
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          color: action.riskColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Agent name + action title
            Text(
              action.agentName,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                color: AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              action.title,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            // Description
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.terminalBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF1E293B),
                ),
              ),
              child: Text(
                action.description,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  color: AppTheme.primary.withAlpha(200),
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 14),
            // Approve / Reject buttons
            if (_isProcessing)
              Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppTheme.primary),
                  ),
                ),
              )
            else
              Row(
                children: [
                  // Reject
                  Expanded(
                    child: GestureDetector(
                      onTap: _handleReject,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: AppTheme.danger.withAlpha(25),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.danger.withAlpha(80),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.close,
                              size: 14,
                              color: AppTheme.danger,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'REJECT',
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
                  // Approve
                  Expanded(
                    child: GestureDetector(
                      onTap: _handleApprove,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withAlpha(60),
                              blurRadius: 15,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check,
                              size: 14,
                              color: AppTheme.backgroundDark,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'APPROVE',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.backgroundDark,
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
      ),
    );
  }
}
