import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service layer for the Multi-Agent Dashboard.
/// Streams live updates from Supabase Realtime and handles HITL actions.
class SupabaseAgentService {
  static SupabaseAgentService? _instance;
  late final SupabaseClient _client;

  SupabaseAgentService._();

  static SupabaseAgentService get instance {
    _instance ??= SupabaseAgentService._();
    return _instance!;
  }

  SupabaseClient get client => _client;

  /// Initialize Supabase connection
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: 'https://bmrspnwwaddqzgfcpgxs.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJtcnNwbnd3YWRkcXpnZmNwZ3hzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk3MDU4NjgsImV4cCI6MjA4NTI4MTg2OH0.tHTYTQyOUk2O4ZcM9WM_s4NJjJUAoOp6KPiyGoOLPm8',
    );
    instance._client = Supabase.instance.client;
  }

  // ---------------------------------------------------------------------------
  // MISSION CONTROL — Real-time agent status stream
  // ---------------------------------------------------------------------------

  /// Stream all missions from `mission_control` table.
  /// Emits the full list on initial load, then re-emits on any INSERT/UPDATE/DELETE.
  Stream<List<Map<String, dynamic>>> streamMissions() {
    final controller = StreamController<List<Map<String, dynamic>>>();

    // Initial fetch
    _fetchMissions().then((data) {
      if (!controller.isClosed) controller.add(data);
    });

    // Listen for real-time changes
    final channel = _client
        .channel('mission_control_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'mission_control',
          callback: (payload) {
            // Re-fetch full list on any change
            _fetchMissions().then((data) {
              if (!controller.isClosed) controller.add(data);
            });
          },
        )
        .subscribe();

    controller.onCancel = () {
      _client.removeChannel(channel);
    };

    return controller.stream;
  }

  Future<List<Map<String, dynamic>>> _fetchMissions() async {
    final response = await _client
        .from('mission_control')
        .select()
        .order('created_at', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Fetch a single mission by ID
  Future<Map<String, dynamic>?> getMission(String missionId) async {
    final response = await _client
        .from('mission_control')
        .select()
        .eq('id', missionId)
        .maybeSingle();
    return response;
  }

  // ---------------------------------------------------------------------------
  // AGENT ACTIONS — HITL approval queue stream
  // ---------------------------------------------------------------------------

  /// Stream pending agent actions (HITL gate).
  Stream<List<Map<String, dynamic>>> streamPendingActions() {
    final controller = StreamController<List<Map<String, dynamic>>>();

    // Initial fetch
    _fetchPendingActions().then((data) {
      if (!controller.isClosed) controller.add(data);
    });

    // Listen for real-time changes
    final channel = _client
        .channel('agent_actions_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'agent_actions',
          callback: (payload) {
            _fetchPendingActions().then((data) {
              if (!controller.isClosed) controller.add(data);
            });
          },
        )
        .subscribe();

    controller.onCancel = () {
      _client.removeChannel(channel);
    };

    return controller.stream;
  }

  Future<List<Map<String, dynamic>>> _fetchPendingActions() async {
    final response = await _client
        .from('agent_actions')
        .select()
        .eq('status', 'pending')
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Approve an action — updates status to 'approved' and triggers Edge Function
  Future<void> approveAction(String actionId) async {
    // Update the action status
    await _client.from('agent_actions').update({
      'status': 'approved',
      'approved_by': 'human_operator',
      'approved_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', actionId);

    // Invoke the Edge Function to process the approved action
    try {
      await _client.functions.invoke(
        'process-agent-action',
        body: {'action_id': actionId, 'decision': 'approved'},
      );
    } catch (e) {
      // Edge function may not be deployed yet — log silently
      // ignore: avoid_print
      print('Edge function call skipped: $e');
    }
  }

  /// Reject an action — updates status to 'rejected'
  Future<void> rejectAction(String actionId) async {
    await _client.from('agent_actions').update({
      'status': 'rejected',
      'approved_by': 'human_operator',
      'approved_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', actionId);
  }

  // ---------------------------------------------------------------------------
  // AGENT LOGS — Real-time terminal log stream
  // ---------------------------------------------------------------------------

  /// Stream the latest agent logs for the terminal UI.
  Stream<List<Map<String, dynamic>>> streamLogs({int limit = 50}) {
    final controller = StreamController<List<Map<String, dynamic>>>();

    // Initial fetch
    _fetchLogs(limit).then((data) {
      if (!controller.isClosed) controller.add(data);
    });

    // Listen for real-time changes
    final channel = _client
        .channel('agent_logs_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'agent_logs',
          callback: (payload) {
            _fetchLogs(limit).then((data) {
              if (!controller.isClosed) controller.add(data);
            });
          },
        )
        .subscribe();

    controller.onCancel = () {
      _client.removeChannel(channel);
    };

    return controller.stream;
  }

  Future<List<Map<String, dynamic>>> _fetchLogs(int limit) async {
    final response = await _client
        .from('agent_logs')
        .select()
        .order('created_at', ascending: false)
        .limit(limit);
    return List<Map<String, dynamic>>.from(response.reversed);
  }

  // ---------------------------------------------------------------------------
  // UTILITY METHODS
  // ---------------------------------------------------------------------------

  /// Update a mission's status (used by Edge Functions or admin actions)
  Future<void> updateMissionStatus(String missionId, String newStatus) async {
    await _client.from('mission_control').update({
      'status': newStatus,
    }).eq('id', missionId);
  }

  /// Write a log entry
  Future<void> writeLog({
    required String agentId,
    required String source,
    required String message,
    String level = 'info',
  }) async {
    await _client.from('agent_logs').insert({
      'agent_id': agentId,
      'source': source,
      'message': message,
      'level': level,
    });
  }

  /// Get computed metrics from mission_control
  Future<Map<String, dynamic>> getMetrics() async {
    final missions = await _fetchMissions();
    final actions = await _fetchPendingActions();

    final activeCount =
        missions.where((m) => m['status'] != 'Completed').length;
    final totalCost = missions.fold<double>(
        0.0, (sum, m) => sum + (double.tryParse('${m['cost_per_hour']}') ?? 0));
    final alertCount = actions.where((a) =>
        a['risk_level'] == 'critical' || a['risk_level'] == 'high').length;

    return {
      'active_agents': activeCount,
      'total_cost': totalCost,
      'safety_alerts': alertCount,
      'pending_actions': actions.length,
    };
  }
}
