class ApologeticsResource {
  final String title;
  final String description;
  final String category;
  final List<String> articles;
  final List<String> videos;
  final List<String> books;
  final String keyPoints;

  ApologeticsResource({
    required this.title,
    required this.description,
    required this.category,
    required this.articles,
    required this.videos,
    required this.books,
    required this.keyPoints,
  });
}

class ApologeticsDatabase {
  static final Map<String, ApologeticsResource> resources = {
    'existence_of_god': ApologeticsResource(
      title: 'Existence of God',
      description: 'Classical arguments for God\'s existence',
      category: 'Natural Theology',
      articles: [
        'https://www.reasonablefaith.org/writings/popular-writings/existence-nature-of-god/the-kalam-cosmological-argument',
        'https://www.desiringgod.org/articles/the-argument-from-design',
        'https://www.gotquestions.org/cosmological-argument.html',
        'https://www.str.org/w/the-moral-argument-for-god-s-existence',
      ],
      videos: [
        'https://www.youtube.com/watch?v=6CulBuMCLg0',
        'https://www.youtube.com/watch?v=FPCzEP0oD7I',
        'https://www.youtube.com/watch?v=ybjG3tdArE0',
        'https://www.youtube.com/watch?v=EE76nwimuT0',
      ],
      books: [
        'Reasonable Faith by William Lane Craig',
        'The Case for a Creator by Lee Strobel',
        'God\'s Undertaker by John Lennox',
        'The Return of the God Hypothesis by Stephen Meyer',
      ],
      keyPoints: '''• Kalam Cosmological Argument: Everything that begins has a cause
• Fine-Tuning Argument: Universe appears designed for life
• Moral Argument: Objective moral values require God
• Ontological Argument: God as the greatest conceivable being''',
    ),
    
    'problem_of_evil': ApologeticsResource(
      title: 'Problem of Evil',
      description: 'Addressing suffering and God\'s goodness',
      category: 'Theodicy',
      articles: [
        'https://www.reasonablefaith.org/writings/popular-writings/existence-nature-of-god/the-problem-of-evil',
        'https://www.desiringgod.org/articles/why-does-god-allow-evil-and-suffering',
        'https://www.gotquestions.org/problem-of-evil.html',
        'https://www.str.org/w/the-problem-of-evil-and-suffering',
      ],
      videos: [
        'https://www.youtube.com/watch?v=vx8ZMkWL8hw',
        'https://www.youtube.com/watch?v=yqIFy6lUhQs',
        'https://www.youtube.com/watch?v=QJ1NInWXN5E',
        'https://www.youtube.com/watch?v=IsakkMKv1SA',
      ],
      books: [
        'The Problem of Pain by C.S. Lewis',
        'Where Is God When It Hurts? by Philip Yancey',
        'Evil and the Justice of God by N.T. Wright',
        'God, Freedom, and Evil by Alvin Plantinga',
      ],
      keyPoints: '''• Free Will Defense: Evil results from human free choice
• Soul-Making Theodicy: Suffering develops character
• Greater Good Defense: God permits evil for greater purposes
• Skeptical Theism: We can't judge God's reasons''',
    ),

    'biblical_reliability': ApologeticsResource(
      title: 'Biblical Reliability',
      description: 'Manuscript evidence and historical accuracy',
      category: 'Biblical Studies',
      articles: [
        'https://www.reasonablefaith.org/writings/popular-writings/jesus-of-nazareth/the-historical-reliability-of-the-new-testament',
        'https://www.str.org/w/is-the-new-testament-reliable-a-christian-apologist-answers-seven-questions',
        'https://www.gotquestions.org/Bible-reliable.html',
        'https://www.desiringgod.org/articles/can-we-trust-the-bible',
      ],
      videos: [
        'https://www.youtube.com/watch?v=ay_Db4RwZ_M',
        'https://www.youtube.com/watch?v=G1XJ7DeR5fc',
        'https://www.youtube.com/watch?v=rml5Cif01g4',
        'https://www.youtube.com/watch?v=A0iDNLxmWVM',
      ],
      books: [
        'The New Testament Documents by F.F. Bruce',
        'Reinventing Jesus by Komoszewski, Sawyer & Wallace',
        'The Historical Reliability of the Gospels by Craig Blomberg',
        'Jesus and the Eyewitnesses by Richard Bauckham',
      ],
      keyPoints: '''• 5,800+ Greek NT manuscripts (more than any ancient text)
• Early dating: Some fragments within 50 years of originals
• 99.5% textual accuracy across manuscripts
• Archaeological confirmation of biblical details''',
    ),
  };
}