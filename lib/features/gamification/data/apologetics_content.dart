class ApologeticsContent {
  final String title;
  final String description;
  final String category;
  final String content;
  final List<String> keyPoints;
  final List<String> commonObjections;
  final List<String> responses;
  final List<String> scriptures;

  ApologeticsContent({
    required this.title,
    required this.description,
    required this.category,
    required this.content,
    required this.keyPoints,
    required this.commonObjections,
    required this.responses,
    required this.scriptures,
  });
}

class ApologeticsContentDatabase {
  static final Map<String, ApologeticsContent> content = {
    'existence_of_god': ApologeticsContent(
      title: 'Existence of God',
      description: 'Classical arguments for God\'s existence',
      category: 'Natural Theology',
      content: '''
The existence of God can be demonstrated through several rational arguments that have been developed and refined over centuries by philosophers and theologians.

**The Kalam Cosmological Argument**
1. Everything that begins to exist has a cause
2. The universe began to exist
3. Therefore, the universe has a cause

Modern cosmology supports premise 2 through Big Bang theory, showing the universe had a beginning. Since the universe cannot cause itself, it requires a transcendent cause - God.

**The Fine-Tuning Argument**
The universe appears precisely calibrated for life. Constants like gravitational force, electromagnetic force, and cosmological constant fall within incredibly narrow ranges that permit life. This suggests intelligent design rather than chance.

**The Moral Argument**
1. If God does not exist, objective moral values do not exist
2. Objective moral values do exist
3. Therefore, God exists

Our universal recognition of moral obligations and values points to a transcendent moral lawgiver.
      ''',
      keyPoints: [
        'Kalam Cosmological Argument: Everything that begins has a cause',
        'Fine-Tuning Argument: Universe appears designed for life',
        'Moral Argument: Objective moral values require God',
        'Ontological Argument: God as the greatest conceivable being',
      ],
      commonObjections: [
        'Who created God?',
        'The universe could be eternal',
        'Evolution explains apparent design',
        'Morality is subjective/cultural',
      ],
      responses: [
        'God is eternal and uncaused by definition - only things that begin need causes',
        'Scientific evidence strongly supports a cosmic beginning (Big Bang)',
        'Evolution cannot account for fine-tuning of physical constants',
        'Cross-cultural moral agreement suggests objective moral truths',
      ],
      scriptures: [
        'Romans 1:20 - God\'s invisible qualities are clearly seen in creation',
        'Psalm 19:1 - The heavens declare the glory of God',
        'Acts 17:24-25 - God made the world and everything in it',
      ],
    ),

    'problem_of_evil': ApologeticsContent(
      title: 'Problem of Evil',
      description: 'Addressing suffering and God\'s goodness',
      category: 'Theodicy',
      content: '''
The problem of evil asks: If God is all-good and all-powerful, why does evil exist? This challenge requires careful theological and philosophical consideration.

**The Free Will Defense**
God created beings with genuine free will because love requires freedom. Evil often results from the misuse of this freedom. A world with free creatures capable of love is better than a world of programmed robots, even if it includes the possibility of evil.

**The Soul-Making Theodicy**
Some suffering serves to develop character, compassion, and spiritual growth. Challenges can produce virtues like courage, patience, and empathy that wouldn't exist without adversity.

**The Greater Good Defense**
God may permit evil to achieve greater goods that we cannot see. Our finite perspective limits our ability to judge God's purposes.

**Natural Evil and the Fall**
Scripture teaches that creation itself was affected by human sin (Romans 8:20-22), explaining natural disasters and disease as consequences of living in a fallen world.
      ''',
      keyPoints: [
        'Free Will Defense: Evil results from human free choice',
        'Soul-Making Theodicy: Suffering develops character',
        'Greater Good Defense: God permits evil for greater purposes',
        'The Fall affected all creation, not just humanity',
      ],
      commonObjections: [
        'Why doesn\'t God stop all evil?',
        'What about natural disasters?',
        'Innocent children suffer',
        'Too much evil exists',
      ],
      responses: [
        'Stopping all evil would eliminate free will and genuine love',
        'Natural disasters result from living in a fallen, physical world',
        'God\'s justice will ultimately address all injustice',
        'We lack the perspective to judge what amount of evil is "too much"',
      ],
      scriptures: [
        'Romans 8:28 - God works all things for good',
        'Job 42:2 - No purpose of God can be thwarted',
        'Genesis 50:20 - What was meant for evil, God meant for good',
      ],
    ),

    'biblical_reliability': ApologeticsContent(
      title: 'Biblical Reliability',
      description: 'Manuscript evidence and historical accuracy',
      category: 'Biblical Studies',
      content: '''
The Bible stands as the most well-attested ancient document in history, with overwhelming manuscript evidence supporting its reliability.

**Manuscript Evidence**
The New Testament has over 5,800 Greek manuscripts, far exceeding any other ancient work. Homer's Iliad, the second-best attested ancient text, has only 643 manuscripts.

**Early Dating**
Some New Testament fragments date within 50 years of the originals. The John Rylands Papyrus (P52) containing John 18:31-33 dates to 125-130 AD, proving John's Gospel was in circulation by the early 2nd century.

**Textual Accuracy**
Despite minor variations in manuscripts, 99.5% of the text is certain. No major doctrine depends on disputed passages. The variations are mostly spelling differences or word order changes.

**Archaeological Confirmation**
Archaeology consistently confirms biblical details. The Pool of Bethesda, Pontius Pilate's inscription, and numerous other discoveries validate the historical accuracy of biblical accounts.

**Historical Method**
Using standard historical criteria, the Gospels meet the tests for historical reliability: multiple attestation, early dating, embarrassing details, and coherence with known history.
      ''',
      keyPoints: [
        '5,800+ Greek NT manuscripts (more than any ancient text)',
        'Early dating: Some fragments within 50 years of originals',
        '99.5% textual accuracy across manuscripts',
        'Archaeological confirmation of biblical details',
      ],
      commonObjections: [
        'The Bible was written too late',
        'Manuscripts have too many variations',
        'The Bible contradicts history',
        'The canon was decided by politics',
      ],
      responses: [
        'NT books were written within living memory of eyewitnesses',
        'Variations are minor and don\'t affect core doctrines',
        'Archaeology consistently confirms biblical accuracy',
        'The canon was recognized, not created, based on apostolic authority',
      ],
      scriptures: [
        '2 Timothy 3:16 - All Scripture is God-breathed',
        '2 Peter 1:21 - Men spoke from God as carried by the Holy Spirit',
        'Luke 1:1-4 - Careful investigation of eyewitness accounts',
      ],
    ),
  };
}