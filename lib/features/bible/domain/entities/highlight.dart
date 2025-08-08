class Highlight {
  final String id;
  final String verseReference;
  final int startIndex;
  final int endIndex;
  final HighlightColor color;
  final DateTime createdAt;

  Highlight({
    required this.id,
    required this.verseReference,
    required this.startIndex,
    required this.endIndex,
    required this.color,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'verseReference': verseReference,
    'startIndex': startIndex,
    'endIndex': endIndex,
    'color': color.name,
    'createdAt': createdAt.millisecondsSinceEpoch,
  };

  factory Highlight.fromJson(Map<String, dynamic> json) => Highlight(
    id: json['id'],
    verseReference: json['verseReference'],
    startIndex: json['startIndex'],
    endIndex: json['endIndex'],
    color: HighlightColor.values.firstWhere((c) => c.name == json['color']),
    createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
  );
}

enum HighlightColor {
  yellow,
  green,
  blue,
  pink,
  orange
}

class VerseNote {
  final String id;
  final String verseReference;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  VerseNote({
    required this.id,
    required this.verseReference,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'verseReference': verseReference,
    'content': content,
    'createdAt': createdAt.millisecondsSinceEpoch,
    'updatedAt': updatedAt.millisecondsSinceEpoch,
  };

  factory VerseNote.fromJson(Map<String, dynamic> json) => VerseNote(
    id: json['id'],
    verseReference: json['verseReference'],
    content: json['content'],
    createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(json['updatedAt']),
  );
}