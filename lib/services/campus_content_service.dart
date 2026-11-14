import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/campus_update.dart';

class CampusContentService {
  CampusContentService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<CampusUpdate>> watchAnnouncements() => _watch(
    collection: 'announcements',
    type: CampusUpdateType.announcement,
    dateField: 'publishedAt',
    descending: true,
  );

  Stream<List<CampusUpdate>> watchNews() => _watch(
    collection: 'news',
    type: CampusUpdateType.news,
    dateField: 'publishedAt',
    descending: true,
  );

  Stream<List<CampusUpdate>> watchEvents() => _watch(
    collection: 'events',
    type: CampusUpdateType.event,
    dateField: 'eventDate',
    descending: false,
  );

  Stream<List<CampusUpdate>> _watch({
    required String collection,
    required CampusUpdateType type,
    required String dateField,
    required bool descending,
  }) {
    return _firestore
        .collection(collection)
        .where('published', isEqualTo: true)
        .orderBy(dateField, descending: descending)
        .limit(5)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (document) => CampusUpdate.fromDocument(
                  document,
                  type: type,
                  dateField: dateField,
                ),
              )
              .toList(growable: false),
        );
  }
}
