import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// MISSION STATUS — maps to Supabase mission_control.status
// ---------------------------------------------------------------------------
enum MissionStatus {
  thinking,
  executing,
  completed,
  failed;

  static MissionStatus fromString(String value) {
    switch (value) {
      case 'Thinking':
        return MissionStatus.thinking;
      case 'Executing':
        return MissionStatus.executing;
      case 'Completed':
        return MissionStatus.completed;
      case 'Failed':
        return MissionStatus.failed;
      default:
        return MissionStatus.thinking;
    }
  }

  String get label {
    switch (this) {
      case MissionStatus.thinking:
        return 'THINKING';
      case MissionStatus.executing:
        return 'EXECUTING';
      case MissionStatus.completed:
        return 'COMPLETED';
      case MissionStatus.failed:
        return 'FAILED';
    }
  }
}

// ---------------------------------------------------------------------------
// AGENT MODEL — backed by Supabase mission_control table
// ---------------------------------------------------------------------------
enum AgentStatus {
  operational,
  anomalyFlagged,
  offline,
  initializing,
}

enum AgentAction {
  approve,
  override,
}

class AgentModel {
  final String? dbId; // UUID from Supabase
  final String name;
  final String id;
  final AgentStatus status;
  final MissionStatus missionStatus;
  final double costPerHour;
  final IconData iconData;
  final AgentAction action;
  final String? taskDescription;
  final double confidenceScore;
  final String? reasoning;

  const AgentModel({
    this.dbId,
    required this.name,
    required this.id,
    required this.status,
    this.missionStatus = MissionStatus.executing,
    required this.costPerHour,
    required this.iconData,
    required this.action,
    this.taskDescription,
    this.confidenceScore = 0.0,
    this.reasoning,
  });

  /// Factory: Parse from Supabase mission_control row
  factory AgentModel.fromSupabase(Map<String, dynamic> data) {
    final missionStatus = MissionStatus.fromString(data['status'] ?? 'Thinking');
    final agentStatus = _mapMissionToAgentStatus(missionStatus);

    return AgentModel(
      dbId: data['id'],
      name: data['agent_name'] ?? 'Unknown Agent',
      id: data['agent_id'] ?? '000',
      status: agentStatus,
      missionStatus: missionStatus,
      costPerHour: double.tryParse('${data['cost_per_hour']}') ?? 0.0,
      iconData: _iconFromName(data['icon_name'] ?? 'smart_toy'),
      action: missionStatus == MissionStatus.thinking
          ? AgentAction.override
          : AgentAction.approve,
      taskDescription: data['task_description'],
      confidenceScore: double.tryParse('${data['confidence_score']}') ?? 0.0,
      reasoning: data['reasoning'],
    );
  }

  static AgentStatus _mapMissionToAgentStatus(MissionStatus mission) {
    switch (mission) {
      case MissionStatus.thinking:
        return AgentStatus.initializing;
      case MissionStatus.executing:
        return AgentStatus.operational;
      case MissionStatus.completed:
        return AgentStatus.operational;
      case MissionStatus.failed:
        return AgentStatus.anomalyFlagged;
    }
  }

  static IconData _iconFromName(String name) {
    switch (name) {
      case 'analytics':
        return Icons.analytics_outlined;
      case 'account_balance':
        return Icons.account_balance_outlined;
      case 'support_agent':
        return Icons.support_agent_outlined;
      case 'storage':
        return Icons.storage_outlined;
      case 'shield':
        return Icons.shield_outlined;
      case 'model_training':
        return Icons.model_training_outlined;
      default:
        return Icons.smart_toy_outlined;
    }
  }

  String get statusText {
    switch (status) {
      case AgentStatus.operational:
        return missionStatus.label;
      case AgentStatus.anomalyFlagged:
        return 'ANOMALY FLAGGED';
      case AgentStatus.offline:
        return 'OFFLINE';
      case AgentStatus.initializing:
        return missionStatus.label;
    }
  }

  bool get isHealthy => status == AgentStatus.operational;
  bool get isDangerous => status == AgentStatus.anomalyFlagged;
  bool get isThinking => missionStatus == MissionStatus.thinking;

  String get costFormatted {
    return '\$${costPerHour.toStringAsFixed(2)}/hr';
  }

  String get confidenceFormatted {
    return '${(confidenceScore * 100).toStringAsFixed(0)}%';
  }

  static List<AgentModel> get sampleAgents => [
        const AgentModel(
          name: 'Agent_Alpha-9',
          id: '982-K',
          status: AgentStatus.operational,
          costPerHour: 0.42,
          iconData: Icons.analytics_outlined,
          action: AgentAction.approve,
        ),
        const AgentModel(
          name: 'Financial_Audit_Bot',
          id: '104-F',
          status: AgentStatus.anomalyFlagged,
          costPerHour: 2.14,
          iconData: Icons.account_balance_outlined,
          action: AgentAction.override,
        ),
        const AgentModel(
          name: 'Customer_Rel_v4',
          id: '002-C',
          status: AgentStatus.operational,
          costPerHour: 0.12,
          iconData: Icons.support_agent_outlined,
          action: AgentAction.approve,
        ),
        const AgentModel(
          name: 'Data_Pipeline_v3',
          id: '417-D',
          status: AgentStatus.operational,
          costPerHour: 0.87,
          iconData: Icons.storage_outlined,
          action: AgentAction.approve,
        ),
        const AgentModel(
          name: 'Security_Scanner',
          id: '091-S',
          status: AgentStatus.anomalyFlagged,
          costPerHour: 1.55,
          iconData: Icons.shield_outlined,
          action: AgentAction.override,
        ),
        const AgentModel(
          name: 'ML_Training_Node',
          id: '302-M',
          status: AgentStatus.operational,
          costPerHour: 3.20,
          iconData: Icons.model_training_outlined,
          action: AgentAction.approve,
        ),
      ];
}

// ---------------------------------------------------------------------------
// TERMINAL LOG — backed by Supabase agent_logs table
// ---------------------------------------------------------------------------
class TerminalLog {
  final String timestamp;
  final String source;
  final String message;
  final bool isWarning;
  final String level;

  const TerminalLog({
    required this.timestamp,
    required this.source,
    required this.message,
    this.isWarning = false,
    this.level = 'info',
  });

  factory TerminalLog.fromSupabase(Map<String, dynamic> data) {
    final createdAt = DateTime.tryParse(data['created_at'] ?? '') ?? DateTime.now();
    final timeStr =
        '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}:${createdAt.second.toString().padLeft(2, '0')}';
    final level = data['level'] ?? 'info';

    return TerminalLog(
      timestamp: timeStr,
      source: data['source'] ?? 'SYSTEM',
      message: data['message'] ?? '',
      isWarning: level == 'warning' || level == 'error',
      level: level,
    );
  }

  static List<TerminalLog> get sampleLogs => const [
        TerminalLog(
          timestamp: '14:20:01',
          source: 'AGENT_BETA',
          message: 'ACCESS_GRANTED',
        ),
        TerminalLog(
          timestamp: '14:20:05',
          source: 'MONITORING_ACTIVE',
          message: 'SYSTEM_STABLE',
        ),
        TerminalLog(
          timestamp: '14:21:12',
          source: 'THREAT_SCAN',
          message: 'NO_MALWARE_DETECTED',
        ),
        TerminalLog(
          timestamp: '14:22:45',
          source: 'AGENT_KAPPA',
          message: 'DATA_INGESTION_START',
        ),
        TerminalLog(
          timestamp: '14:23:10',
          source: 'GATEWAY_WARN',
          message: 'HIGH_TRAFFIC_FLOW',
          isWarning: true,
        ),
        TerminalLog(
          timestamp: '14:23:12',
          source: 'SYSTEM',
          message: 'LISTENING',
        ),
      ];
}

// ---------------------------------------------------------------------------
// AGENT ACTION — HITL approval model
// ---------------------------------------------------------------------------
class AgentActionModel {
  final String id;
  final String? missionId;
  final String agentId;
  final String agentName;
  final String actionType;
  final String title;
  final String description;
  final String riskLevel;
  final String status;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final DateTime? expiresAt;

  const AgentActionModel({
    required this.id,
    this.missionId,
    required this.agentId,
    required this.agentName,
    required this.actionType,
    required this.title,
    required this.description,
    required this.riskLevel,
    required this.status,
    required this.payload,
    required this.createdAt,
    this.expiresAt,
  });

  factory AgentActionModel.fromSupabase(Map<String, dynamic> data) {
    return AgentActionModel(
      id: data['id'] ?? '',
      missionId: data['mission_id'],
      agentId: data['agent_id'] ?? '',
      agentName: data['agent_name'] ?? 'Unknown',
      actionType: data['action_type'] ?? 'approval_required',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      riskLevel: data['risk_level'] ?? 'low',
      status: data['status'] ?? 'pending',
      payload: Map<String, dynamic>.from(data['payload'] ?? {}),
      createdAt: DateTime.tryParse(data['created_at'] ?? '') ?? DateTime.now(),
      expiresAt: data['expires_at'] != null
          ? DateTime.tryParse(data['expires_at'])
          : null,
    );
  }

  bool get isCritical => riskLevel == 'critical';
  bool get isHighRisk => riskLevel == 'high' || riskLevel == 'critical';

  Color get riskColor {
    switch (riskLevel) {
      case 'critical':
        return const Color(0xFFFF3B30);
      case 'high':
        return const Color(0xFFFF9500);
      case 'medium':
        return const Color(0xFFFFCC00);
      case 'low':
        return const Color(0xFF0DF233);
      default:
        return const Color(0xFF64748B);
    }
  }

  IconData get riskIcon {
    switch (riskLevel) {
      case 'critical':
        return Icons.error_outline;
      case 'high':
        return Icons.warning_amber_rounded;
      case 'medium':
        return Icons.info_outline;
      case 'low':
        return Icons.check_circle_outline;
      default:
        return Icons.help_outline;
    }
  }
}

// ---------------------------------------------------------------------------
// METRIC CARD
// ---------------------------------------------------------------------------
class MetricCard {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final MetricType type;

  const MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.type,
  });

  static List<MetricCard> get sampleMetrics => const [
        MetricCard(
          title: 'Active Agents',
          value: '24',
          subtitle: '+2 vs. last hr',
          icon: Icons.smart_toy_outlined,
          type: MetricType.primary,
        ),
        MetricCard(
          title: 'Cost Today',
          value: '\$1.2k',
          subtitle: 'Budget: 62%',
          icon: Icons.payments_outlined,
          type: MetricType.neutral,
        ),
        MetricCard(
          title: 'Safety Alerts',
          value: '03',
          subtitle: 'Critical Priority',
          icon: Icons.warning_amber_rounded,
          type: MetricType.danger,
        ),
      ];

  /// Build metrics from live Supabase data
  static List<MetricCard> fromLiveData(Map<String, dynamic> data) {
    final active = data['active_agents'] ?? 0;
    final cost = data['total_cost'] ?? 0.0;
    final alerts = data['safety_alerts'] ?? 0;
    final pending = data['pending_actions'] ?? 0;

    return [
      MetricCard(
        title: 'Active Agents',
        value: '$active',
        subtitle: '$pending pending actions',
        icon: Icons.smart_toy_outlined,
        type: MetricType.primary,
      ),
      MetricCard(
        title: 'Cost / Hour',
        value: '\$${(cost as double).toStringAsFixed(1)}',
        subtitle: 'Live estimate',
        icon: Icons.payments_outlined,
        type: MetricType.neutral,
      ),
      MetricCard(
        title: 'Safety Alerts',
        value: alerts.toString().padLeft(2, '0'),
        subtitle: alerts > 0 ? 'Critical Priority' : 'All Clear',
        icon: Icons.warning_amber_rounded,
        type: alerts > 0 ? MetricType.danger : MetricType.primary,
      ),
    ];
  }
}

enum MetricType { primary, neutral, danger }
