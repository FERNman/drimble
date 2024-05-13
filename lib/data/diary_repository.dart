import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../domain/date.dart';
import '../domain/diary/diary_entry.dart';

class DiaryRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  CollectionReference<DiaryEntry> get _collection => _firestore.collection('diaries').withConverter(
        fromFirestore: DiaryEntry.fromFirestore,
        toFirestore: (value, _) => value.toFirestore(_auth.currentUser!.uid),
      );

  DiaryRepository(this._auth, this._firestore);

  Stream<DiaryEntry> observeEntryById(String id) {
    return _collection.doc(id).snapshots().map((event) => event.data()!);
  }

  Stream<List<DiaryEntry>> observeEntriesBetween(Date startDate, Date endDate) {
    return _collection
        .where('userId', isEqualTo: _auth.currentUser!.uid)
        .where('date', isGreaterThanOrEqualTo: startDate.toDateTime())
        .where('date', isLessThanOrEqualTo: endDate.toDateTime())
        .snapshots()
        .map((event) => event.docs.map((doc) => doc.data()).toList());
  }

  Future<void> saveDiaryEntry(DiaryEntry diaryEntry) async {
    await _collection.doc(diaryEntry.id).set(diaryEntry);
  }

  Future<void> deleteDiaryEntry(DiaryEntry diaryEntry) async {
    await _collection.doc(diaryEntry.id).delete();
  }
}
