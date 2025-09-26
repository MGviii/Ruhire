import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth_providers.dart';
import '../services/config.dart';
import '../services/api_client.dart';
import 'mock_api.dart';

final appConfigProvider = Provider<AppConfig>((ref) => kDefaultConfig);

final parentApiProvider = Provider<dynamic>((ref) {
  final cfg = ref.watch(appConfigProvider);
  if (cfg.useMocks) return MockParentApiService();
  return ApiClient.fromConfig(cfg);
});

// Lightweight child summary for UI display
class ChildSummary {
  final String id;
  final String name;
  final String className;
  const ChildSummary({required this.id, required this.name, required this.className});
}

// Fetch ALL children for the logged-in parent
final childrenProvider = FutureProvider<List<ChildSummary>>((ref) async {
  final firestore = ref.read(firestoreProvider);
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return const [];

  // Resolve parent doc by uid or email
  DocumentSnapshot<Map<String, dynamic>>? parentDoc = await firestore.collection('parents').doc(user.uid).get();
  if (!parentDoc.exists && user.email != null) {
    final q = await firestore
        .collection('parents')
        .where('email', isEqualTo: user.email)
        .limit(1)
        .get();
    if (q.docs.isNotEmpty) parentDoc = q.docs.first;
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> docs = [];
  if (parentDoc.exists) {
    final q1 = await firestore
        .collection('students')
        .where('parentId', isEqualTo: parentDoc.id)
        .where('isActive', isEqualTo: true)
        .get();
    docs.addAll(q1.docs);
  }
  if (docs.isEmpty) {
    final q2 = await firestore
        .collection('students')
        .where('parentId', isEqualTo: user.uid)
        .where('isActive', isEqualTo: true)
        .get();
    docs.addAll(q2.docs);
  }
  if (docs.isEmpty && parentDoc.exists) {
    final pdata = parentDoc.data()!;
    // single childId
    final childId = (pdata['childId'] ?? '') as String;
    if (childId.isNotEmpty) {
      final d = await firestore.collection('students').doc(childId).get();
      if (d.exists) {
        return [
          ChildSummary(
            id: d.id,
            name: (d.data()!['name'] ?? '') as String,
            className: (d.data()!['class'] ?? '') as String,
          )
        ];
      }
    }
    // optional: array of childIds
    final childIds = (pdata['childIds'] as List?)?.whereType<String>().toList() ?? [];
    if (childIds.isNotEmpty) {
      final fetched = await Future.wait(childIds.map((cid) => firestore.collection('students').doc(cid).get()));
      return fetched
          .where((d) => d.exists)
          .map((d) => ChildSummary(
                id: d.id,
                name: (d.data()!['name'] ?? '') as String,
                className: (d.data()!['class'] ?? '') as String,
              ))
          .toList();
    }
  }
  return docs
      .map((d) => ChildSummary(
            id: d.id,
            name: (d.data()['name'] ?? '') as String,
            className: (d.data()['class'] ?? '') as String,
          ))
      .toList();
});

final busLocationStreamProvider = StreamProvider<BusLocation>((ref) {
  final api = ref.read(parentApiProvider);
  if (api is MockParentApiService) {
    return api.watchBusLocation();
  }
  // Backend polling placeholder; replace with realtime subscription if available
  final client = api as ApiClient;
  final controller = StreamController<BusLocation>();
  Timer.periodic(const Duration(seconds: 5), (t) async {
    try {
      final res = await client.get<Map<String, dynamic>>('/bus/location');
      final data = res.data!;
      controller.add(BusLocation(
        latitude: (data['lat'] as num).toDouble(),
        longitude: (data['lng'] as num).toDouble(),
        updatedAt: DateTime.parse(data['updatedAt'] as String),
      ));
    } catch (e) {
      // swallow errors, could add retry/backoff
    }
  });
  ref.onDispose(() => controller.close());
  return controller.stream;
});

final attendanceProvider = FutureProvider<List<AttendanceRecord>>((ref) async {
  final api = ref.read(parentApiProvider);
  if (api is MockParentApiService) {
    return api.fetchAttendance();
  }
  final client = api as ApiClient;
  final res = await client.get<List<dynamic>>('/attendance');
  final list = (res.data ?? []);
  return list.map((e) => AttendanceRecord(date: DateTime.parse(e['date'] as String), present: e['present'] as bool)).toList();
});

final profileProvider = FutureProvider<ParentProfile>((ref) async {
  // Always resolve from Firestore using the currently logged-in Firebase user
  final firestore = ref.read(firestoreProvider);
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    throw Exception('Not logged in');
  }
  // Resolve parent document by uid or email
  DocumentSnapshot<Map<String, dynamic>>? parentDoc = await firestore.collection('parents').doc(user.uid).get();
  if (!parentDoc.exists && user.email != null) {
    final q = await firestore
        .collection('parents')
        .where('email', isEqualTo: user.email)
        .limit(1)
        .get();
    if (q.docs.isNotEmpty) parentDoc = q.docs.first;
  }
  if (parentDoc == null || !parentDoc.exists) {
    throw Exception('Parent profile not found');
  }
  final pdata = parentDoc.data()!;
  // Try to resolve a child student using several strategies
  String studentName = '';
  String className = '';
  // 1) parentId == parent document id
  var studentQ = await firestore
      .collection('students')
      .where('parentId', isEqualTo: parentDoc.id)
      .where('isActive', isEqualTo: true)
      .limit(1)
      .get();
  if (studentQ.docs.isEmpty) {
    // 2) parentId == current user uid
    studentQ = await firestore
        .collection('students')
        .where('parentId', isEqualTo: user.uid)
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();
  }
  if (studentQ.docs.isEmpty) {
    // 3) parent doc might carry a childId reference
    final childId = (pdata['childId'] ?? '') as String;
    if (childId.isNotEmpty) {
      final childDoc = await firestore.collection('students').doc(childId).get();
      if (childDoc.exists) {
        final sd = childDoc.data() as Map<String, dynamic>;
        studentName = (sd['name'] ?? '') as String;
        className = (sd['class'] ?? '') as String;
      }
    }
  }
  if (studentQ.docs.isNotEmpty) {
    final sd = studentQ.docs.first.data();
    studentName = (sd['name'] ?? '') as String;
    className = (sd['class'] ?? '') as String;
  }
  final parentName = (pdata['name'] ?? '') as String;
  final parentEmail = (pdata['email'] ?? '') as String;
  final parentPhone = (pdata['phone'] ?? '') as String;
  return ParentProfile(
    studentName: studentName,
    className: className,
    parentName: parentName,
    parentEmail: parentEmail,
    parentPhone: parentPhone,
  );
});

class NotificationInitController extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    if (!kIsWeb) {
      // Placeholders for FCM init; real impl would request permissions and get token
      await Future<void>.delayed(const Duration(milliseconds: 200));
    }
    return true;
  }
}

final notificationInitProvider = AsyncNotifierProvider<NotificationInitController, bool>(
  () => NotificationInitController(),
);


