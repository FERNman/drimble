import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../domain/user/user.dart';

class UserRepository {
  final firebase_auth.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  UserRepository(this._auth, this._firestore);

  Future<User?> loadUser() => _auth.currentUser == null ? Future.value(null) : _populateUser(_auth.currentUser!);

  Stream<User?> observeUser() => _auth.authStateChanges().asyncMap((user) => user == null ? null : _populateUser(user));

  bool isSignedIn() => _auth.currentUser != null;

  Future<void> signInWithCredential(firebase_auth.OAuthCredential credential) async {
    await _auth.signInWithCredential(credential);
  }

  Future<void> signInAnonymously() async {
    await _auth.signInAnonymously();
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<bool> didFinishOnboarding() async {
    if (_auth.currentUser == null) {
      return false;
    }

    final doc = await _userRef().get();
    return doc.exists;
  }

  Future<void> save(User user) async {
    if (_auth.currentUser == null) {
      throw Exception('User is not signed in');
    }

    // This is not necessary, but why not store it in the user as well?
    // Maybe it's useful long-term for things like marketing
    await _auth.currentUser?.updateDisplayName(user.name);
    await _userRef().set(user.toJson());
  }

  Future<void> update(User user) async {
    if (_auth.currentUser == null) {
      throw Exception('User is not signed in');
    }

    await _userRef().update(user.toJson());
  }

  Future<User> _populateUser(firebase_auth.User user) async {
    final userDoc = await _userRef().get();
    return User.fromJson(userDoc.data()!);
  }

  DocumentReference<Map<String, dynamic>> _userRef() {
    return _firestore.collection('users').doc(_auth.currentUser!.uid);
  }
}
