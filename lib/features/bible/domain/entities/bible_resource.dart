class BibleResource {
  final String name;
  final String baseUrl;
  final ResourceType type;
  final String description;

  BibleResource({
    required this.name,
    required this.baseUrl,
    required this.type,
    required this.description,
  });
}

enum ResourceType {
  commentary,
  lexicon,
  interlinear,
  strongs,
  context,
  theological,
  miscellaneous,
  earlyFathers,
  contributions
}

class ResourceUrl {
  final BibleResource resource;
  final String url;

  ResourceUrl({required this.resource, required this.url});
}