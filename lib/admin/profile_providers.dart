import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminProfile {
  final String uid;
  final String name;
  final String email;
  final String phone;

  const AdminProfile({required this.uid, required this.name, required this.email, required this.phone});

  Map<String, dynamic> toMap() => {'name': name, 'email': email, 'phone': phone};

  static AdminProfile fromDoc(DocumentSnapshot<Map<String, dynamic>> doc, String email) {
    final d = doc.data() ?? const {};
    return AdminProfile(uid: doc.id, name: (d['name'] as String?) ?? '', email: email, phone: (d['phone'] as String?) ?? '');
  }
}

final adminAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);
final adminFirestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

final adminProfileProvider = FutureProvider<AdminProfile>((ref) async {
  final auth = ref.read(adminAuthProvider);
  final user = auth.currentUser;
  if (user == null) throw Exception('Not authenticated');
  final fs = ref.read(adminFirestoreProvider);
  final doc = await fs.collection('admins').doc(user.uid).get();
  return AdminProfile.fromDoc(doc, user.email ?? '');
});

class AdminProfileController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> updateProfile({required String name, required String phone}) async {
    state = const AsyncValue.loading();
    try {
      final auth = ref.read(adminAuthProvider);
      final user = auth.currentUser;
      if (user == null) throw Exception('Not authenticated');
      final fs = ref.read(adminFirestoreProvider);
      await fs.collection('admins').doc(user.uid).set({'name': name, 'phone': phone}, SetOptions(merge: true));
      state = const AsyncValue.data(null);
      ref.invalidate(adminProfileProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> changeEmail(String newEmail) async {
    state = const AsyncValue.loading();
    try {
      final user = ref.read(adminAuthProvider).currentUser;
      if (user == null) throw Exception('Not authenticated');
      // Firebase Auth v6: use verifyBeforeUpdateEmail
      await user.verifyBeforeUpdateEmail(newEmail);
      state = const AsyncValue.data(null);
      ref.invalidate(adminProfileProvider);
    } on FirebaseAuthException catch (e, st) {
      state = AsyncValue.error(e.message ?? 'Email update failed', st);
    } catch (e, st) {
      state = AsyncValue.error('Email update failed', st);
    }
  }

  Future<void> changePassword({required String currentPassword, required String newPassword}) async {
    state = const AsyncValue.loading();
    try {
      final auth = ref.read(adminAuthProvider);
      final user = auth.currentUser;
      if (user == null) throw Exception('Not authenticated');
      final email = user.email;
      if (email == null || email.isEmpty) throw Exception('Missing email');
      // Securely verify current password via reauthentication (never use Firestore for passwords)
      final credential = EmailAuthProvider.credential(email: email, password: currentPassword);
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
      state = const AsyncValue.data(null);
    } on FirebaseAuthException catch (e, st) {
      state = AsyncValue.error(e.message ?? 'Password update failed', st);
    } catch (e, st) {
      state = AsyncValue.error('Password update failed', st);
    }
  }

  Future<void> updateAll({required String name, required String phone, required String email}) async {
    state = const AsyncValue.loading();
    try {
      final auth = ref.read(adminAuthProvider);
      final user = auth.currentUser;
      if (user == null) throw Exception('Not authenticated');

      // Update Firestore profile
      final fs = ref.read(adminFirestoreProvider);
      await fs.collection('admins').doc(user.uid).set({'name': name, 'phone': phone}, SetOptions(merge: true));

      // Update email if changed
      final currentEmail = user.email ?? '';
      if (email.trim().isNotEmpty && email.trim() != currentEmail) {
        await user.verifyBeforeUpdateEmail(email.trim());
      }

      state = const AsyncValue.data(null);
      ref.invalidate(adminProfileProvider);
    } on FirebaseAuthException catch (e, st) {
      state = AsyncValue.error(e.message ?? 'Update failed', st);
    } catch (e, st) {
      state = AsyncValue.error('Update failed', st);
    }
  }
}

final adminProfileControllerProvider = AsyncNotifierProvider<AdminProfileController, void>(() => AdminProfileController());


