import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

final firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

final authStateChangesProvider = StreamProvider<User?>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return auth.authStateChanges();
});

final userRoleProvider = FutureProvider<String?>((ref) async {
  // Recompute when auth state changes
  ref.watch(authStateChangesProvider);
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return null;
  final firestore = ref.read(firestoreProvider);

  // Try Admins by document id
  final adminById = await firestore.collection('admins').doc(user.uid).get();
  if (adminById.exists) return 'admin';

  // Try Parents by document id
  final parentById = await firestore.collection('parents').doc(user.uid).get();
  if (parentById.exists) return 'parent';

  // Try Admins by email
  if (user.email != null) {
    final adminByEmail = await firestore
        .collection('admins')
        .where('email', isEqualTo: user.email)
        .limit(1)
        .get();
    if (adminByEmail.docs.isNotEmpty) return 'admin';

    final parentByEmail = await firestore
        .collection('parents')
        .where('email', isEqualTo: user.email)
        .limit(1)
        .get();
    if (parentByEmail.docs.isNotEmpty) return 'parent';
  }
  return null;
});

final mustChangePasswordProvider = FutureProvider<bool>((ref) async {
  ref.watch(authStateChangesProvider);
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return false;
  final firestore = ref.read(firestoreProvider);
  final doc = await firestore.collection('users').doc(user.uid).get();
  final data = doc.data();
  if (data == null) return false;
  final v = data['mustChangePassword'];
  return v == true;
});

class AuthController extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    // Rebuild when auth state changes
    ref.watch(authStateChangesProvider);
    return FirebaseAuth.instance.currentUser;
  }

  Future<void> signInWithEmail(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final cred = await ref.read(firebaseAuthProvider).signInWithEmailAndPassword(
            email: email,
            password: password,
          );
      state = AsyncValue.data(cred.user);
    } on FirebaseAuthException catch (e, st) {
      // Fallback: if login failed, see if this email exists in 'admins' or 'parents' with a default password
      try {
        final firestore = ref.read(firestoreProvider);
        
        // 1) Try admins by email
        final adminQ = await firestore
            .collection('admins')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();
        if (adminQ.docs.isNotEmpty) {
          final data = adminQ.docs.first.data();
          final defaultPassword = (data['defaultPassword'] ?? '') as String;
          if (defaultPassword.isNotEmpty && password == defaultPassword) {
            final auth = ref.read(firebaseAuthProvider);
            final created = await auth.createUserWithEmailAndPassword(email: email, password: defaultPassword);
            await firestore.collection('users').doc(created.user!.uid).set({
              'role': 'admin',
              'mustChangePassword': true,
              'provisionedFrom': 'admins',
              'provisionedAdminDocId': adminQ.docs.first.id,
              'createdAt': FieldValue.serverTimestamp(),
            });
            state = AsyncValue.data(created.user);
            return;
          }
        }

        // 2) Try parents by email
        final parentQ = await firestore
            .collection('parents')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();
        if (parentQ.docs.isNotEmpty) {
          final data = parentQ.docs.first.data();
          final defaultPassword = (data['defaultPassword'] ?? '') as String;
          if (defaultPassword.isNotEmpty && password == defaultPassword) {
            // Auto-provision Firebase Auth user for this parent and sign them in
            final auth = ref.read(firebaseAuthProvider);
            final created = await auth.createUserWithEmailAndPassword(email: email, password: defaultPassword);
            // Also persist role mapping for convenience
            await firestore.collection('users').doc(created.user!.uid).set({
              'role': 'parent',
              'mustChangePassword': true,
              'provisionedFrom': 'parents',
              'provisionedParentDocId': parentQ.docs.first.id,
              'createdAt': FieldValue.serverTimestamp(),
            });
            state = AsyncValue.data(created.user);
            return;
          }
        }
        // If we get here, fallback path not applicable
        state = AsyncValue.error(e.message ?? 'Authentication failed', st);
      } catch (fallbackErr, fallbackSt) {
        state = AsyncValue.error('Authentication failed', fallbackSt);
      }
    } catch (e, st) {
      state = AsyncValue.error('Authentication failed', st);
    }
  }

  Future<void> signOut() async {
    await ref.read(firebaseAuthProvider).signOut();
    state = const AsyncValue.data(null);
  }

  Future<void> registerWithEmail({required String email, required String password, required String role}) async {
    state = const AsyncValue.loading();
    try {
      final auth = ref.read(firebaseAuthProvider);
      final cred = await auth.createUserWithEmailAndPassword(email: email, password: password);
      final user = cred.user;
      if (user != null) {
        final firestore = ref.read(firestoreProvider);
        await firestore.collection('users').doc(user.uid).set({'role': role});
      }
      state = AsyncValue.data(user);
    } on FirebaseAuthException catch (e, st) {
      state = AsyncValue.error(e.message ?? 'Registration failed', st);
    } catch (e, st) {
      state = AsyncValue.error('Registration failed', st);
    }
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, User?>(
  () => AuthController(),
);


