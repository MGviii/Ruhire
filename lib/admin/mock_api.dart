import 'dart:async';

class AdminBus {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final List<String> onboardStudentIds;

  const AdminBus({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.onboardStudentIds,
  });
}

class AdminStudent {
  final String id;
  final String name;
  final String grade;
  final String parentId;

  const AdminStudent({required this.id, required this.name, required this.grade, required this.parentId});
}

class AdminParent {
  final String id;
  final String name;
  final String email;
  final String phone;

  const AdminParent({required this.id, required this.name, required this.email, this.phone = ''});
}

class AdminDriver {
  final String id;
  final String name;
  final String phone;

  const AdminDriver({required this.id, required this.name, required this.phone});
}

class AdminAttendanceRow {
  final String id;
  final String studentName;
  final DateTime timestamp;
  final String status; // check-in / check-out

  const AdminAttendanceRow({required this.id, required this.studentName, required this.timestamp, required this.status});
}

class AdminDashboardStats {
  final int totalBuses;
  final int activeStudents;
  final int activeAlerts;

  const AdminDashboardStats({required this.totalBuses, required this.activeStudents, required this.activeAlerts});
}

class AdminMockApiService {
  AdminMockApiService({this.interval = const Duration(seconds: 3), this.jitter = 0.00035});

  final Duration interval;
  final double jitter;

  Stream<List<AdminBus>> watchBuses() async* {
    double lat = -1.9462;
    double lng = 30.0626;
    while (true) {
      await Future<void>.delayed(interval);
      lat += jitter * 0.7;
      lng += jitter * 0.9;
      yield [
        AdminBus(id: 'b1', name: 'Bus 1', latitude: lat, longitude: lng, onboardStudentIds: const ['s1', 's2']),
        AdminBus(id: 'b2', name: 'Bus 2', latitude: lat + 0.01, longitude: lng + 0.01, onboardStudentIds: const ['s3']),
      ];
    }
  }

  Future<AdminDashboardStats> fetchDashboardStats() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return const AdminDashboardStats(totalBuses: 2, activeStudents: 3, activeAlerts: 1);
  }

  Future<List<AdminAttendanceRow>> fetchAttendance({String? query, String? status}) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final now = DateTime.now();
    final rows = List.generate(20, (i) => AdminAttendanceRow(
          id: 'r$i',
          studentName: 'Student ${i + 1}',
          timestamp: now.subtract(Duration(minutes: i * 13)),
          status: i % 2 == 0 ? 'check-in' : 'check-out',
        ));
    return rows
        .where((r) => query == null || r.studentName.toLowerCase().contains(query.toLowerCase()))
        .where((r) => status == null || r.status == status)
        .toList();
  }

  Future<List<AdminStudent>> fetchStudents() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return const [
      AdminStudent(id: 's1', name: 'Alice', grade: 'G3', parentId: 'p1'),
      AdminStudent(id: 's2', name: 'Bob', grade: 'G3', parentId: 'p2'),
      AdminStudent(id: 's3', name: 'Charlie', grade: 'G5', parentId: 'p3'),
    ];
  }

  Future<List<AdminParent>> fetchParents() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return const [
      AdminParent(id: 'p1', name: 'Parent A', email: 'a@example.com', phone: '+250700000010'),
      AdminParent(id: 'p2', name: 'Parent B', email: 'b@example.com', phone: '+250700000011'),
      AdminParent(id: 'p3', name: 'Parent C', email: 'c@example.com', phone: '+250700000012'),
    ];
  }

  Future<List<AdminDriver>> fetchDrivers() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return const [
      AdminDriver(id: 'd1', name: 'Driver One', phone: '+250700000001'),
      AdminDriver(id: 'd2', name: 'Driver Two', phone: '+250700000002'),
    ];
  }

  // Placeholder CRUD methods
  Future<void> addBus(AdminBus bus) async {}
  Future<void> updateBus(AdminBus bus) async {}
  Future<void> deleteBus(String id) async {}
  Future<void> addStudent(AdminStudent s) async {}
  Future<void> updateStudent(AdminStudent s) async {}
  Future<void> deleteStudent(String id) async {}
  Future<void> addParent(AdminParent p) async {}
  Future<void> updateParent(AdminParent p) async {}
  Future<void> deleteParent(String id) async {}
  Future<void> addDriver(AdminDriver d) async {}
  Future<void> updateDriver(AdminDriver d) async {}
  Future<void> deleteDriver(String id) async {}
}
