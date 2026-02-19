import 'package:flutter/material.dart';

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
  final String name;
  final String id;
  final AgentStatus status;
  final double costPerHour;
  final IconData iconData;
  final AgentAction action;

  const AgentModel({
    required this.name,
    required this.id,
    required this.status,
    required this.costPerHour,
    required this.iconData,
    required this.action,
  });

  String get statusText {
    switch (status) {
      case AgentStatus.operational:
        return 'OPERATIONAL';
      case AgentStatus.anomalyFlagged:
        return 'ANOMALY FLAGGED';
      case AgentStatus.offline:
        return 'OFFLINE';
      case AgentStatus.initializing:
        return 'INITIALIZING';
    }
  }

  bool get isHealthy => status == AgentStatus.operational;
  bool get isDangerous => status == AgentStatus.anomalyFlagged;

  String get costFormatted {
    if (costPerHour >= 1.0) {
      return '\$${costPerHour.toStringAsFixed(2)}/hr';
    }
    return '\$${costPerHour.toStringAsFixed(2)}/hr';
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

class TerminalLog {
  final String timestamp;
  final String source;
  final String message;
  final bool isWarning;

  const TerminalLog({
    required this.timestamp,
    required this.source,
    required this.message,
    this.isWarning = false,
  });

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
}

enum MetricType { primary, neutral, danger }
