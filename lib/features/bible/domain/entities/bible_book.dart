enum Testament { old, newTestament }

class BibleBook {
  final String name;
  final String abbreviation; // e.g., Gen, Exod
  final int chaptersCount;
  final Testament testament;
  final int order; // Canonical order

  BibleBook({
    required this.name,
    required this.abbreviation,
    required this.chaptersCount,
    required this.testament,
    required this.order,
  });
}
