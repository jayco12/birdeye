class TheologyQuestion {
  final String category;
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String explanation;
  final String reference;
  final String difficulty;

  TheologyQuestion({
    required this.category,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.reference,
    required this.difficulty,
  });
}

class TheologyQuestionBank {
  static final List<TheologyQuestion> questions = [
    // SOTERIOLOGY (Doctrine of Salvation)
    TheologyQuestion(
      category: 'soteriology',
      question: 'What is the doctrine of salvation by grace through faith?',
      options: [
        'We earn salvation through good works',
        'Salvation is a gift from God received by faith',
        'Salvation comes through religious rituals',
        'We save ourselves through moral living'
      ],
      correctAnswer: 1,
      explanation: 'Ephesians 2:8-9 teaches that salvation is by grace through faith, not by works, so that no one may boast.',
      reference: 'Ephesians 2:8-9',
      difficulty: 'beginner',
    ),
    
    TheologyQuestion(
      category: 'soteriology',
      question: 'What does "justification" mean in Christian theology?',
      options: [
        'Being made righteous through good deeds',
        'God declaring a sinner righteous based on Christ\'s work',
        'Gradually becoming more holy over time',
        'Earning God\'s favor through obedience'
      ],
      correctAnswer: 1,
      explanation: 'Justification is God\'s legal declaration that a sinner is righteous, based on Christ\'s imputed righteousness, not our own works.',
      reference: 'Romans 3:21-26',
      difficulty: 'intermediate',
    ),

    TheologyQuestion(
      category: 'soteriology',
      question: 'What is the ordo salutis (order of salvation)?',
      options: [
        'Faith, repentance, baptism, good works',
        'Election, calling, regeneration, faith, justification, sanctification, glorification',
        'Baptism, confirmation, communion, marriage',
        'Hearing, believing, confessing, being baptized'
      ],
      correctAnswer: 1,
      explanation: 'The ordo salutis describes the logical order of God\'s work in salvation, beginning with election and ending with glorification.',
      reference: 'Romans 8:29-30',
      difficulty: 'advanced',
    ),

    // BIBLIOLOGY (Doctrine of Scripture)
    TheologyQuestion(
      category: 'bibliology',
      question: 'What does "inspiration of Scripture" mean?',
      options: [
        'The Bible is merely human wisdom',
        'God breathed out Scripture through human authors',
        'Only parts of the Bible are from God',
        'The Bible contains God\'s word but isn\'t God\'s word'
      ],
      correctAnswer: 1,
      explanation: '2 Timothy 3:16 - "All Scripture is God-breathed" (theopneustos), meaning God superintended the writing process.',
      reference: '2 Timothy 3:16',
      difficulty: 'beginner',
    ),

    TheologyQuestion(
      category: 'bibliology',
      question: 'What is the difference between general and special revelation?',
      options: [
        'General is for everyone, special is for clergy only',
        'General is through nature, special is through Scripture',
        'General is Old Testament, special is New Testament',
        'General is symbolic, special is literal'
      ],
      correctAnswer: 1,
      explanation: 'General revelation is God\'s self-disclosure through creation (Romans 1:20), while special revelation is through Scripture and Christ.',
      reference: 'Romans 1:20, Hebrews 1:1-2',
      difficulty: 'intermediate',
    ),

    TheologyQuestion(
      category: 'bibliology',
      question: 'What is the principle of "Scripture interprets Scripture"?',
      options: [
        'Every verse has multiple meanings',
        'Unclear passages should be understood in light of clear ones',
        'Only scholars can interpret the Bible',
        'Each book of the Bible contradicts others'
      ],
      correctAnswer: 1,
      explanation: 'The analogy of faith principle states that Scripture is its own best interpreter, with clear passages illuminating unclear ones.',
      reference: '2 Peter 1:20-21',
      difficulty: 'advanced',
    ),

    // HAMARTIOLOGY (Doctrine of Sin)
    TheologyQuestion(
      category: 'hamartiology',
      question: 'What is the biblical definition of sin?',
      options: [
        'Only major crimes and violations',
        'Missing the mark of God\'s perfect standard',
        'Cultural taboos and social wrongs',
        'Only intentional wrongdoing'
      ],
      correctAnswer: 1,
      explanation: 'Sin (hamartia) means "missing the mark" - falling short of God\'s glory and perfect standard.',
      reference: 'Romans 3:23',
      difficulty: 'beginner',
    ),

    TheologyQuestion(
      category: 'hamartiology',
      question: 'What is original sin?',
      options: [
        'The first sin committed by each person',
        'Adam\'s sin and its effects on all humanity',
        'Sins that are particularly serious',
        'Sins committed in ignorance'
      ],
      correctAnswer: 1,
      explanation: 'Original sin refers to Adam\'s first sin and the corruption of human nature that resulted, affecting all his descendants.',
      reference: 'Romans 5:12-21',
      difficulty: 'intermediate',
    ),

    TheologyQuestion(
      category: 'hamartiology',
      question: 'What is total depravity?',
      options: [
        'Humans are as evil as they could possibly be',
        'Every aspect of human nature is affected by sin',
        'Some people are completely good',
        'Only certain people are sinful'
      ],
      correctAnswer: 1,
      explanation: 'Total depravity means sin affects every part of human nature (mind, will, emotions), though not to the maximum degree possible.',
      reference: 'Jeremiah 17:9, Romans 3:10-18',
      difficulty: 'advanced',
    ),

    // PNEUMATOLOGY (Doctrine of the Holy Spirit)
    TheologyQuestion(
      category: 'pneumatology',
      question: 'Who is the Holy Spirit?',
      options: [
        'An impersonal force from God',
        'The third person of the Trinity',
        'Another name for Jesus',
        'A created being like an angel'
      ],
      correctAnswer: 1,
      explanation: 'The Holy Spirit is the third person of the Trinity, fully God, co-equal and co-eternal with the Father and Son.',
      reference: 'Matthew 28:19, 2 Corinthians 13:14',
      difficulty: 'beginner',
    ),

    TheologyQuestion(
      category: 'pneumatology',
      question: 'What is the primary work of the Holy Spirit in salvation?',
      options: [
        'Giving spiritual gifts to believers',
        'Regenerating the heart and giving new life',
        'Helping believers pray better',
        'Providing comfort during trials'
      ],
      correctAnswer: 1,
      explanation: 'The Holy Spirit\'s primary work in salvation is regeneration - giving spiritual life to those who are spiritually dead.',
      reference: 'John 3:5-8, Titus 3:5',
      difficulty: 'intermediate',
    ),

    // CHRISTOLOGY (Doctrine of Christ)
    TheologyQuestion(
      category: 'christology',
      question: 'What does the hypostatic union refer to?',
      options: [
        'The union of believers with Christ',
        'Jesus having both divine and human natures in one person',
        'The unity between Father and Son',
        'The joining of Old and New Testaments'
      ],
      correctAnswer: 1,
      explanation: 'The hypostatic union is the doctrine that Jesus Christ has two natures (divine and human) united in one person.',
      reference: 'John 1:14, Philippians 2:6-8',
      difficulty: 'advanced',
    ),

    TheologyQuestion(
      category: 'christology',
      question: 'What is the significance of Jesus being called "the Word" (Logos)?',
      options: [
        'He spoke many important teachings',
        'He is God\'s ultimate revelation and communication',
        'He wrote parts of the Bible',
        'He was a great preacher'
      ],
      correctAnswer: 1,
      explanation: 'Jesus as the Logos means He is God\'s ultimate word/revelation to humanity - the perfect communication of God\'s nature and will.',
      reference: 'John 1:1-14, Hebrews 1:1-3',
      difficulty: 'intermediate',
    ),

    // ESCHATOLOGY (Doctrine of Last Things)
    TheologyQuestion(
      category: 'eschatology',
      question: 'What is the "blessed hope" that Christians await?',
      options: [
        'Going to heaven when we die',
        'The second coming of Jesus Christ',
        'World peace and prosperity',
        'The end of all suffering'
      ],
      correctAnswer: 1,
      explanation: 'The "blessed hope" specifically refers to the glorious appearing of our great God and Savior Jesus Christ at His second coming.',
      reference: 'Titus 2:13',
      difficulty: 'beginner',
    ),

    TheologyQuestion(
      category: 'eschatology',
      question: 'What happens to believers immediately after death?',
      options: [
        'Soul sleep until the resurrection',
        'Immediate presence with Christ',
        'Purgatory for purification',
        'Reincarnation into new life'
      ],
      correctAnswer: 1,
      explanation: 'Scripture teaches that believers go immediately into the presence of Christ upon death, awaiting the resurrection of the body.',
      reference: '2 Corinthians 5:8, Philippians 1:23',
      difficulty: 'intermediate',
    ),

    TheologyQuestion(
      category: 'eschatology',
      question: 'What is the difference between the rapture and the second coming?',
      options: [
        'They are the same event',
        'Rapture is for the church, second coming is Christ\'s return to earth',
        'Rapture is symbolic, second coming is literal',
        'There is no difference in timing'
      ],
      correctAnswer: 1,
      explanation: 'Many hold that the rapture is when Christ comes for His church, while the second coming is when He returns with His church to establish His kingdom.',
      reference: '1 Thessalonians 4:16-17, Revelation 19:11-16',
      difficulty: 'advanced',
    ),
  ];

  static List<TheologyQuestion> getQuestionsByCategory(String category) {
    return questions.where((q) => q.category == category).toList();
  }

  static List<TheologyQuestion> getQuestionsByDifficulty(String difficulty) {
    return questions.where((q) => q.difficulty == difficulty).toList();
  }

  static List<TheologyQuestion> getRandomQuestions(int count) {
    final shuffled = List<TheologyQuestion>.from(questions)..shuffle();
    return shuffled.take(count).toList();
  }
}