import '../../domain/entities/bible_resource.dart';
import '../../domain/entities/verse.dart';

class BibleResources {
  static final List<BibleResource> _resources = [
    // Commentary Resources
    BibleResource(
      name: 'BibleHub Commentary',
      baseUrl: 'https://biblehub.com/commentaries',
      type: ResourceType.commentary,
      description: 'Comprehensive biblical commentaries',
    ),
    BibleResource(
      name: 'StudyLight',
      baseUrl: 'https://www.studylight.org/commentary',
      type: ResourceType.commentary,
      description: 'Multiple commentary collections',
    ),
    BibleResource(
      name: 'Blue Letter Bible Commentary',
      baseUrl: 'https://www.blueletterbible.org/kjv',
      type: ResourceType.commentary,
      description: 'In-depth verse-by-verse commentary',
    ),
    
    // Lexicon Resources
    BibleResource(
      name: 'BibleHub Lexicon',
      baseUrl: 'https://biblehub.com/lexicon',
      type: ResourceType.lexicon,
      description: 'Hebrew and Greek word definitions',
    ),
    
    // Interlinear Resources
    BibleResource(
      name: 'BibleHub Interlinear',
      baseUrl: 'https://biblehub.com/interlinear',
      type: ResourceType.interlinear,
      description: 'Word-by-word Hebrew/Greek analysis',
    ),
    
    // Strong's Resources
    BibleResource(
      name: 'BibleHub Strongs',
      baseUrl: 'https://biblehub.com/strongs',
      type: ResourceType.strongs,
      description: 'Strongs concordance numbers',
    ),
    
    // Context Resources
    BibleResource(
      name: 'BibleHub Context',
      baseUrl: 'https://biblehub.com/context',
      type: ResourceType.context,
      description: 'Historical and cultural context',
    ),
    BibleResource(
      name: 'Blue Letter Bible Context',
      baseUrl: 'https://www.blueletterbible.org/kjv',
      type: ResourceType.context,
      description: 'Parallel passages and context',
    ),
    

    
    // Miscellaneous Aid Resources
    BibleResource(
      name: 'Blue Letter Bible Misc',
      baseUrl: 'https://www.blueletterbible.org/kjv',
      type: ResourceType.miscellaneous,
      description: 'Miscellaneous study aids and tools',
    ),
    
    // Early Church Fathers Resources
    BibleResource(
      name: 'BibleHub Early Fathers',
      baseUrl: 'https://biblehub.com/library',
      type: ResourceType.earlyFathers,
      description: 'Early Church Fathers writings and references',
    ),
    BibleResource(
      name: 'Contributions',
      baseUrl: 'https://contributions.blackbirdapp.dev',
      type: ResourceType.contributions,
      description: 'Community contributions and resources',
    ),
  ];

  static List<BibleResource> getResourcesByType(ResourceType type) {
    return _resources.where((r) => r.type == type).toList();
  }

  static List<ResourceUrl> generateUrls(Verse verse, ResourceType type) {
    final resources = getResourcesByType(type);
    return resources.map((resource) {
      final url = _buildUrl(resource, verse);
      return ResourceUrl(resource: resource, url: url);
    }).toList();
  }

  static String _buildUrl(BibleResource resource, Verse verse) {
    final reference = _formatReference(verse, resource);
    
    switch (resource.name) {
      case 'BibleHub Commentary':
      case 'BibleHub Lexicon':
      case 'BibleHub Interlinear':
      case 'BibleHub Strongs':
      case 'BibleHub Context':
      case 'BibleHub Early Fathers':
        return '${resource.baseUrl}/$reference.htm';
        

        
      case 'Blue Letter Bible Commentary':
        return '${resource.baseUrl}/${_getBlbBookCode(verse.bookName)}/${verse.chapterNumber}/${verse.verseNumber}/t_comms_${_getBlbVerseId(verse)}';
        
      case 'Blue Letter Bible Context':
        return '${resource.baseUrl}/${_getBlbBookCode(verse.bookName)}/${verse.chapterNumber}/${verse.verseNumber}/t_misc_${_getBlbVerseId(verse)}';
      case 'Blue Letter Bible Misc':
        return '${resource.baseUrl}/${_getBlbBookCode(verse.bookName)}/${verse.chapterNumber}/${verse.verseNumber}/t_misc_${_getBlbVerseId(verse)}';
        
      case 'StudyLight':
        return '${resource.baseUrl}/${verse.bookName.toLowerCase()}/${verse.chapterNumber}-${verse.verseNumber}.html';
        
      case 'BibleHub Topical':
        return 'https://biblehub.com/topical/${_formatReference(verse, resource)}.htm';
        
      default:
        return resource.baseUrl;
    }
  }

  static String _formatReference(Verse verse, BibleResource resource) {
    if (resource.name.startsWith('BibleHub')) {
      return '${verse.bookName.toLowerCase().replaceAll(' ', '_')}/${verse.chapterNumber}-${verse.verseNumber}';
    }
    return '${verse.bookAbbreviation}/${verse.chapterNumber}/${verse.verseNumber}';
  }

  static String _getBlbBookCode(String bookName) {
    final bookCodes = {
      'Genesis': 'gen', 'Exodus': 'exo', 'Leviticus': 'lev', 'Numbers': 'num',
      'Deuteronomy': 'deu', 'Joshua': 'jos', 'Judges': 'jdg', 'Ruth': 'rut',
      '1 Samuel': '1sa', '2 Samuel': '2sa', '1 Kings': '1ki', '2 Kings': '2ki',
      '1 Chronicles': '1ch', '2 Chronicles': '2ch', 'Ezra': 'ezr', 'Nehemiah': 'neh',
      'Esther': 'est', 'Job': 'job', 'Psalms': 'psa', 'Proverbs': 'pro',
      'Ecclesiastes': 'ecc', 'Song of Solomon': 'sng', 'Isaiah': 'isa', 'Jeremiah': 'jer',
      'Lamentations': 'lam', 'Ezekiel': 'eze', 'Daniel': 'dan', 'Hosea': 'hos',
      'Joel': 'joe', 'Amos': 'amo', 'Obadiah': 'oba', 'Jonah': 'jon',
      'Micah': 'mic', 'Nahum': 'nah', 'Habakkuk': 'hab', 'Zephaniah': 'zep',
      'Haggai': 'hag', 'Zechariah': 'zec', 'Malachi': 'mal',
      'Matthew': 'mat', 'Mark': 'mar', 'Luke': 'luk', 'John': 'jhn',
      'Acts': 'act', 'Romans': 'rom', '1 Corinthians': '1co', '2 Corinthians': '2co',
      'Galatians': 'gal', 'Ephesians': 'eph', 'Philippians': 'phi', 'Colossians': 'col',
      '1 Thessalonians': '1th', '2 Thessalonians': '2th', '1 Timothy': '1ti', '2 Timothy': '2ti',
      'Titus': 'tit', 'Philemon': 'phm', 'Hebrews': 'heb', 'James': 'jam',
      '1 Peter': '1pe', '2 Peter': '2pe', '1 John': '1jo', '2 John': '2jo',
      '3 John': '3jo', 'Jude': 'jud', 'Revelation': 'rev',
    };
    return bookCodes[bookName] ?? bookName.toLowerCase().substring(0, 3);
  }

  static String _getBlbVerseId(Verse verse) {
    // Generate Blue Letter Bible verse ID based on examples
    return '1000${verse.verseNumber.toString().padLeft(3, '0')}';
  }

  // static int _getBookNumber(String bookName) {
  //   final bookNumbers = {
  //     'Genesis': 1, 'Exodus': 2, 'Leviticus': 3, 'Numbers': 4, 'Deuteronomy': 5,
  //     'Joshua': 6, 'Judges': 7, 'Ruth': 8, '1 Samuel': 9, '2 Samuel': 10,
  //     '1 Kings': 11, '2 Kings': 12, '1 Chronicles': 13, '2 Chronicles': 14,
  //     'Ezra': 15, 'Nehemiah': 16, 'Esther': 17, 'Job': 18, 'Psalms': 19,
  //     'Proverbs': 20, 'Ecclesiastes': 21, 'Song of Solomon': 22, 'Isaiah': 23,
  //     'Jeremiah': 24, 'Lamentations': 25, 'Ezekiel': 26, 'Daniel': 27,
  //     'Hosea': 28, 'Joel': 29, 'Amos': 30, 'Obadiah': 31, 'Jonah': 32,
  //     'Micah': 33, 'Nahum': 34, 'Habakkuk': 35, 'Zephaniah': 36, 'Haggai': 37,
  //     'Zechariah': 38, 'Malachi': 39, 'Matthew': 40, 'Mark': 41, 'Luke': 42,
  //     'John': 43, 'Acts': 44, 'Romans': 45, '1 Corinthians': 46, '2 Corinthians': 47,
  //     'Galatians': 48, 'Ephesians': 49, 'Philippians': 50, 'Colossians': 51,
  //     '1 Thessalonians': 52, '2 Thessalonians': 53, '1 Timothy': 54, '2 Timothy': 55,
  //     'Titus': 56, 'Philemon': 57, 'Hebrews': 58, 'James': 59, '1 Peter': 60,
  //     '2 Peter': 61, '1 John': 62, '2 John': 63, '3 John': 64, 'Jude': 65,
  //     'Revelation': 66,
  //   };
  //   return bookNumbers[bookName] ?? 1;
  // }
}