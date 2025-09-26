import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth_providers.dart';

class Student {
  final String id;
  final String studentId;
  final String name;
  final String class_;
  final String parentId;
  final String address;
  final DateTime createdAt;
  final bool isActive;

  const Student({
    required this.id,
    required this.studentId,
    required this.name,
    required this.class_,
    required this.parentId,
    required this.address,
    required this.createdAt,
    required this.isActive,
  });

  factory Student.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Student(
      id: doc.id,
      studentId: data['studentId'] ?? '',
      name: data['name'] ?? '',
      class_: data['class'] ?? '',
      parentId: data['parentId'] ?? '',
      address: data['address'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'studentId': studentId,
      'name': name,
      'class': class_,
      'parentId': parentId,
      'address': address,
      'createdAt': Timestamp.fromDate(createdAt),
      'isActive': isActive,
    };
  }
}

class FirestoreStudentsService {
  final FirebaseFirestore _firestore;

  FirestoreStudentsService(this._firestore);

  // Get random 5 students
  Future<List<Student>> getRandomStudents({int limit = 5}) async {
    try {
      final querySnapshot = await _firestore
          .collection('students')
          .where('isActive', isEqualTo: true)
          .limit(limit * 2) // Get more to randomize from
          .get();

      final allStudents = querySnapshot.docs
          .map((doc) => Student.fromFirestore(doc))
          .toList();

      // Shuffle and take only the requested number
      allStudents.shuffle();
      return allStudents.take(limit).toList();
    } catch (e) {
      throw Exception('Failed to fetch students: $e');
    }
  }

  // Get all students with pagination
  Future<List<Student>> getAllStudents({int limit = 10, DocumentSnapshot? startAfter}) async {
    try {
      Query query = _firestore
          .collection('students')
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => Student.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch students: $e');
    }
  }

  // Add new student
  Future<void> addStudent(Student student) async {
    try {
      await _firestore
          .collection('students')
          .doc(student.id)
          .set(student.toFirestore());
    } catch (e) {
      throw Exception('Failed to add student: $e');
    }
  }

  // Update student
  Future<void> updateStudent(Student student) async {
    try {
      await _firestore
          .collection('students')
          .doc(student.id)
          .update(student.toFirestore());
    } catch (e) {
      throw Exception('Failed to update student: $e');
    }
  }

  // Delete student (soft delete by setting isActive to false)
  Future<void> deleteStudent(String studentId) async {
    try {
      await _firestore
          .collection('students')
          .doc(studentId)
          .update({'isActive': false});
    } catch (e) {
      throw Exception('Failed to delete student: $e');
    }
  }

  // Get student count
  Future<int> getStudentCount() async {
    try {
      final querySnapshot = await _firestore
          .collection('students')
          .where('isActive', isEqualTo: true)
          .get();
      return querySnapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to get student count: $e');
    }
  }
}

final firestoreStudentsServiceProvider = Provider<FirestoreStudentsService>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return FirestoreStudentsService(firestore);
});

// Provider for random students
final randomStudentsProvider = FutureProvider<List<Student>>((ref) async {
  final service = ref.watch(firestoreStudentsServiceProvider);
  return await service.getRandomStudents();
});

// Provider for all students with pagination
final allStudentsProvider = FutureProvider.family<List<Student>, ({int limit, DocumentSnapshot? startAfter})>((ref, params) async {
  final service = ref.watch(firestoreStudentsServiceProvider);
  return await service.getAllStudents(limit: params.limit, startAfter: params.startAfter);
});

// Provider for student count
final studentCountProvider = FutureProvider<int>((ref) async {
  final service = ref.watch(firestoreStudentsServiceProvider);
  return await service.getStudentCount();
});
