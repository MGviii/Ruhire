import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/config.dart';
import '../services/api_client.dart';
import 'mock_api.dart';

final adminConfigProvider = Provider<AppConfig>((ref) => kDefaultConfig);

final adminApiProvider = Provider<dynamic>((ref) {
  final cfg = ref.watch(adminConfigProvider);
  if (cfg.useMocks) return AdminMockApiService();
  return ApiClient.fromConfig(cfg);
});

final adminDashboardStatsProvider = FutureProvider<AdminDashboardStats>((ref) async {
  final api = ref.read(adminApiProvider);
  if (api is AdminMockApiService) return api.fetchDashboardStats();
  final client = api as ApiClient;
  final res = await client.get<Map<String, dynamic>>('/admin/stats');
  final d = res.data!;
  return AdminDashboardStats(totalBuses: d['totalBuses'] as int, activeStudents: d['activeStudents'] as int, activeAlerts: d['activeAlerts'] as int);
});

final adminBusesProvider = StreamProvider<List<AdminBus>>((ref) {
  final api = ref.read(adminApiProvider);
  if (api is AdminMockApiService) return api.watchBuses();
  final client = api as ApiClient;
  // Polling placeholder; replace with websocket for live updates
  final controller = StreamController<List<AdminBus>>();
  Timer.periodic(const Duration(seconds: 5), (t) async {
    try {
      final res = await client.get<List<dynamic>>('/admin/buses');
      final list = (res.data ?? [])
          .map((e) => AdminBus(
                id: e['id'] as String,
                name: e['name'] as String,
                latitude: (e['lat'] as num).toDouble(),
                longitude: (e['lng'] as num).toDouble(),
                onboardStudentIds: List<String>.from(e['onboard'] as List<dynamic>),
              ))
          .toList();
      controller.add(list);
    } catch (e) {}
  });
  ref.onDispose(() => controller.close());
  return controller.stream;
});

final adminAttendanceProvider = FutureProvider.family<List<AdminAttendanceRow>, ({String? query, String? status})>((ref, args) async {
  final api = ref.read(adminApiProvider);
  if (api is AdminMockApiService) return api.fetchAttendance(query: args.query, status: args.status);
  final client = api as ApiClient;
  final res = await client.get<List<dynamic>>('/admin/attendance', query: {
    if (args.query != null) 'q': args.query,
    if (args.status != null) 'status': args.status,
  });
  return (res.data ?? [])
      .map((e) => AdminAttendanceRow(
            id: e['id'] as String,
            studentName: e['studentName'] as String,
            timestamp: DateTime.parse(e['timestamp'] as String),
            status: e['status'] as String,
          ))
      .toList();
});

final adminStudentsProvider = FutureProvider<List<AdminStudent>>((ref) async {
  final api = ref.read(adminApiProvider);
  if (api is AdminMockApiService) return api.fetchStudents();
  final client = api as ApiClient;
  final res = await client.get<List<dynamic>>('/admin/students');
  return (res.data ?? [])
      .map((e) => AdminStudent(id: e['id'] as String, name: e['name'] as String, grade: e['grade'] as String, parentId: e['parentId'] as String))
      .toList();
});

final adminParentsProvider = FutureProvider<List<AdminParent>>((ref) async {
  final api = ref.read(adminApiProvider);
  if (api is AdminMockApiService) return api.fetchParents();
  final client = api as ApiClient;
  final res = await client.get<List<dynamic>>('/admin/parents');
  return (res.data ?? [])
      .map((e) => AdminParent(
            id: e['id'] as String,
            name: e['name'] as String,
            email: e['email'] as String,
            phone: (e['phone'] ?? '') as String,
          ))
      .toList();
});

final adminDriversProvider = FutureProvider<List<AdminDriver>>((ref) async {
  final api = ref.read(adminApiProvider);

  final client = api as ApiClient;
  final res = await client.get<List<dynamic>>('/admin/drivers');
  return (res.data ?? [])
      .map((e) => AdminDriver(id: e['id'] as String, name: e['name'] as String, phone: e['phone'] as String))
      .toList();
});
