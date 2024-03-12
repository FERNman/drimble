import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drimble/data/user_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'user_repository_test.mocks.dart';

@GenerateNiceMocks([MockSpec<FirebaseAuth>(), MockSpec<FirebaseFirestore>()])
void main() {
  group(UserRepository, () {
    final mockAuth = MockFirebaseAuth();
    final mockFirestore = MockFirebaseFirestore();

    final userRepository = UserRepository(mockAuth, mockFirestore);

    group('signInAnonymously', () {
      test('should create an anonymous user', () async {
        await userRepository.signInAnonymously();

        verify(mockAuth.signInAnonymously()).called(1);
      });
    });
  });
}
