import 'dart:async';

class BusLocation {
  final double latitude;
  final double longitude;
  final DateTime updatedAt;

  const BusLocation({required this.latitude, required this.longitude, required this.updatedAt});
}

class AttendanceRecord {
  final DateTime date;
  final bool present;

  const AttendanceRecord({required this.date, required this.present});
}

class ParentProfile {
  final String studentName;
  final String className;
  final String parentName;
  final String parentEmail;
  final String parentPhone;

  const ParentProfile({
    required this.studentName,
    required this.className,
    required this.parentName,
    this.parentEmail = '',
    this.parentPhone = '',
  });
}

class MockParentApiService {
  MockParentApiService({this.interval = const Duration(seconds: 3), this.jitter = 0.0004});

  final Duration interval;
  final double jitter; // degrees jitter per step

  // Emits a new location, moving with jitter for realism
  Stream<BusLocation> watchBusLocation() async* {
    double lat = -1.9462;
    double lng = 30.0626;
    while (true) {
      await Future<void>.delayed(interval);
      lat += jitter * 0.6;
      lng += jitter * 0.8;
      yield BusLocation(latitude: lat, longitude: lng, updatedAt: DateTime.now());
    }
  }

  Future<List<AttendanceRecord>> fetchAttendance() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final now = DateTime.now();
    return List<AttendanceRecord>.generate(14, (i) {
      final d = now.subtract(Duration(days: i));
      return AttendanceRecord(date: DateTime(d.year, d.month, d.day), present: i % 5 != 0);
    });
  }

  Future<ParentProfile> fetchProfile() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return const ParentProfile(
      studentName: 'John Doe',
      className: 'Grade 3B',
      parentName: 'Jane Doe',
      parentEmail: 'parent@example.com',
      parentPhone: '+250700000099',
    );
  }
}


