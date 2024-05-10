import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

import '../domain/date.dart';
import '../domain/diary/consumed_drink.dart';
import '../domain/diary/diary_entry.dart';

class DiaryRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  CollectionReference<DiaryEntry> get _collection => _firestore.collection('diaries').withConverter(
        fromFirestore: DiaryEntry.fromFirestore,
        toFirestore: (value, _) => value.toFirestore(_auth.currentUser!.uid),
      );

  DiaryRepository(this._auth, this._firestore);

  Stream<List<DiaryEntry>> observeEntriesAfter(Date date) {
    return _collection
        .where('userId', isEqualTo: _auth.currentUser!.uid)
        .where('date', isGreaterThanOrEqualTo: date.toDateTime())
        .snapshots()
        .toDiaryEntries(_firestore);
  }

  Stream<DiaryEntry?> observeEntryOnDate(Date date) {
    return _collection
        .where('userId', isEqualTo: _auth.currentUser!.uid)
        .where('date', isEqualTo: date.toDateTime())
        .limit(1)
        .snapshots()
        .toDiaryEntries(_firestore)
        .map((event) => event.singleOrNull);
  }

  Stream<List<DiaryEntry>> observeEntriesBetween(Date startDate, Date endDate) {
    return _collection
        .where('userId', isEqualTo: _auth.currentUser!.uid)
        .where('date', isGreaterThanOrEqualTo: startDate.toDateTime())
        .where('date', isLessThanOrEqualTo: endDate.toDateTime())
        .snapshots()
        .toDiaryEntries(_firestore);
  }

  Future<DiaryEntry?> findEntryOnDate(Date date) async {
    return _collection
        .where('userId', isEqualTo: _auth.currentUser!.uid)
        .where('date', isEqualTo: date.toDateTime())
        .limit(1)
        .get()
        .toDiaryEntries(_firestore)
        .then((value) => value.singleOrNull);
  }

  Future<void> saveDiaryEntry(DiaryEntry diaryEntry) async {
    await _collection.doc(diaryEntry.id).set(diaryEntry);
  }

  Future<void> deleteDiaryEntry(DiaryEntry diaryEntry) async {
    await _collection.doc(diaryEntry.id).delete();
  }

  Future<void> saveDrinkForDiaryEntry(DiaryEntry diaryEntry, ConsumedDrink drink) async {
    final diaryRef = _collection.doc(diaryEntry.id);
    await diaryRef.set(diaryEntry);
    await diaryRef.drinks.doc(drink.id).set(drink);
  }

  Future<void> removeDrinkFromDiaryEntry(DiaryEntry diaryEntry, ConsumedDrink drink) async {
    final diaryRef = _collection.doc(diaryEntry.id);
    await diaryRef.drinks.doc(drink.id).delete();
  }
}

extension _DrinksSubcollection on DocumentReference<DiaryEntry> {
  CollectionReference<ConsumedDrink> get drinks => collection('drinks').withConverter(
        fromFirestore: ConsumedDrink.fromFirestore,
        toFirestore: (value, _) => value.toFirestore(),
      );
}

extension _DiaryEntryStreamExtension on Stream<QuerySnapshot<DiaryEntry>> {
  Stream<List<DiaryEntry>> toDiaryEntries(FirebaseFirestore firestore) {
    return map((event) => event.docs).flatMap((diaryEntriesDocs) => Rx.combineLatestList(diaryEntriesDocs
        .map((diaryEntryDoc) => diaryEntryDoc.reference.drinks
            .snapshots()
            .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList())
            .map((drinks) => DiaryEntry.withDrinks(diaryEntryDoc.data(), drinks: drinks)))
        .toList()));
  }
}

extension _DiaryEntryFutureExtension on Future<QuerySnapshot<DiaryEntry>> {
  Future<List<DiaryEntry>> toDiaryEntries(FirebaseFirestore firestore) {
    return then((value) => Future.wait(value.docs.map((diaryEntriesDoc) => diaryEntriesDoc.reference.drinks
        .get()
        .then((drinksSnapshot) => drinksSnapshot.docs.map((doc) => doc.data()).toList())
        .then((drinks) => DiaryEntry.withDrinks(diaryEntriesDoc.data(), drinks: drinks)))));
  }
}
