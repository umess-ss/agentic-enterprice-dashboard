import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/agent_model.dart';

class MetricCardWidget extends StatelessWidget {
  final MetricCard metric;

  const MetricCardWidget({super.key, required this.metric});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor, width: 1),
        boxShadow: _boxShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(metric.icon, color: _iconColor, size: 24),
          const SizedBox(height: 8),
          Text(
            metric.title.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: _labelColor,
              letterSpacing: 0.5,
              fontFamily: 'SpaceGrotesk',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            metric.value,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            metric.subtitle,
            style: AppTheme.monoSmallStyle.copyWith(
              fontSize: 10,
              color: _subtitleColor,
            ),
          ),
        ],
      ),
    );
  }

  Color get _backgroundColor {
    switch (metric.type) {
      case MetricType.primary:
        return AppTheme.primary.withAlpha(13);
      case MetricType.neutral:
        return AppTheme.surfaceDark.withAlpha(102);
      case MetricType.danger:
        return AppTheme.danger.withAlpha(13);
    }
  }

  Color get _borderColor {
    switch (metric.type) {
      case MetricType.primary:
        return AppTheme.primary.withAlpha(51);
      case MetricType.neutral:
        return AppTheme.borderDark;
      case MetricType.danger:
        return AppTheme.danger.withAlpha(51);
    }
  }

  Color get _iconColor {
    switch (metric.type) {
      case MetricType.primary:
        return AppTheme.primary;
      case MetricType.neutral:
        return AppTheme.textMuted;
      case MetricType.danger:
        return AppTheme.danger;
    }
  }

  Color get _labelColor {
    switch (metric.type) {
      case MetricType.primary:
        return AppTheme.primary.withAlpha(153);
      case MetricType.neutral:
        return AppTheme.textMuted;
      case MetricType.danger:
        return AppTheme.danger.withAlpha(179);
    }
  }

  Color get _subtitleColor {
    switch (metric.type) {
      case MetricType.primary:
        return AppTheme.primary;
      case MetricType.neutral:
        return AppTheme.textMuted;
      case MetricType.danger:
        return AppTheme.danger;
    }
  }

  List<BoxShadow>? get _boxShadow {
    switch (metric.type) {
      case MetricType.primary:
        return [
          BoxShadow(
            color: AppTheme.primary.withAlpha(51),
            blurRadius: 15,
            spreadRadius: 0,
          ),
        ];
      case MetricType.danger:
        return [
          BoxShadow(
            color: AppTheme.danger.withAlpha(77),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ];
      case MetricType.neutral:
        return null;
    }
  }
}
