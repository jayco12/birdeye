import 'package:cloud_firestore/cloud_firestore.dart';

class VerseContribution {
  final String id;
  final String verseReference;
  final String content;
  final String contributorName;
  final DateTime createdAt;
  final DateTime updatedAt;

  VerseContribution({
    required this.id,
    required this.verseReference,
    required this.content,
    required this.contributorName,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'verseReference': verseReference,
      'content': content,
      'contributorName': contributorName,
      'createdAt': createdAt.toUtc(),
      'updatedAt': updatedAt.toUtc(),
    };
  }

  factory VerseContribution.fromMap(Map<String, dynamic> map) {
    return VerseContribution(
      id: map['id'] ?? '',
      verseReference: map['verseReference'] ?? '',
      content: map['content'] ?? '',
      contributorName: map['contributorName'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }
}
