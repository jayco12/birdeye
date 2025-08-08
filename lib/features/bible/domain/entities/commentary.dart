class Commentary {
  final String id;
  final String author;
  final String title;
  final String content;
  final String reference;
  final CommentaryType type;

  Commentary({
    required this.id,
    required this.author,
    required this.title,
    required this.content,
    required this.reference,
    required this.type,
  });
}

enum CommentaryType {
  verse,
  chapter,
  book,
  theological,
  historical,
  literal
}

class TheologicalView {
  final String id;
  final String title;
  final String author;
  final String content;
  final String reference;
  final TheologicalTradition tradition;

  TheologicalView({
    required this.id,
    required this.title,
    required this.author,
    required this.content,
    required this.reference,
    required this.tradition,
  });
}

enum TheologicalTradition {
  reformed,
  arminian,
  catholic,
  orthodox,
  pentecostal,
  baptist,
  lutheran,
  anglican,
  earlyFathers
}