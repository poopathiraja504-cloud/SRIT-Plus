import 'package:cloud_firestore/cloud_firestore.dart';

enum CampusUpdateType { announcement, news, event }

class CampusUpdate {
  const CampusUpdate({
    required this.id,
    required this.title,
    required this.description,
    required this.publishedAt,
    required this.type,
    this.link,
  });

  final String id;
  final String title;
  final String description;
  final DateTime? publishedAt;
  final CampusUpdateType type;
  final Uri? link;

  factory CampusUpdate.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document, {
    required CampusUpdateType type,
    required String dateField,
  }) {
    final data = document.data();
    if (data == null) {
      throw FormatException('Campus update ${document.id} has no data.');
    }

    final title = data['title'];
    final description = data['description'];
    if (title is! String || title.trim().isEmpty) {
      throw FormatException('Campus update ${document.id} has no title.');
    }
    if (description is! String || description.trim().isEmpty) {
      throw FormatException('Campus update ${document.id} has no description.');
    }

    final rawDate = data[dateField];
    final date = switch (rawDate) {
      Timestamp value => value.toDate(),
      DateTime value => value,
      _ => null,
    };
    final rawLink = data['url'];
    final link = rawLink is String ? Uri.tryParse(rawLink) : null;

    return CampusUpdate(
      id: document.id,
      title: title.trim(),
      description: description.trim(),
      publishedAt: date,
      type: type,
      link: link != null && link.scheme == 'https' ? link : null,
    );
  }
}
