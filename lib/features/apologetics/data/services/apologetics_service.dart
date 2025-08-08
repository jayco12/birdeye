import 'dart:convert';
import 'package:http/http.dart' as http;

class ApologeticsService {
  static const String _youtubeApiKey = 'AIzaSyD-JvPJfe9CkfXHobCt3o1QGaBXMgiIuoo';
  static const String _youtubeBaseUrl = 'https://www.googleapis.com/youtube/v3';
  
  Future<List<ApologeticsResource>> searchResources(String topic) async {
    final resources = <ApologeticsResource>[];
    
    // Search YouTube videos
    final videos = await _searchYouTubeVideos(topic);
    resources.addAll(videos);
    
    // Add curated apologetics channels/content
    final curatedContent = await _getCuratedContent(topic);
    resources.addAll(curatedContent);
    
    // Add books and articles
    final books = await _getBooks(topic);
    resources.addAll(books);
    
    // Add articles and writings
    final articles = await _getArticles(topic);
    resources.addAll(articles);
    
    return resources;
  }
  
  Future<List<ApologeticsResource>> _searchYouTubeVideos(String topic) async {
    try {
      final query = Uri.encodeComponent('$topic christian apologetics');
      final url = '$_youtubeBaseUrl/search?part=snippet&q=$query&type=video&maxResults=10&key=$_youtubeApiKey';
      
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final items = data['items'] as List;
        
        return items.map((item) => ApologeticsResource(
          title: item['snippet']['title'],
          description: item['snippet']['description'],
          thumbnailUrl: item['snippet']['thumbnails']['medium']['url'],
          videoUrl: 'https://www.youtube.com/watch?v=${item['id']['videoId']}',
          videoId: item['id']['videoId'],
          channelName: item['snippet']['channelTitle'],
          type: ResourceType.video,
          source: 'YouTube',
        )).toList();
      }
    } catch (e) {
      print('YouTube API Error: $e');
    }
    
    return [];
  }
  
  Future<List<ApologeticsResource>> _getCuratedContent(String topic) async {
    // Curated apologetics resources from known channels/sources
    final curatedChannels = {
      'William Lane Craig': 'UCqXKVgKNrQlVd2IVUsz47ow',
      'Cross Examined': 'UCqXKVgKNrQlVd2IVUsz47ow', 
      'Reasonable Faith': 'UCqXKVgKNrQlVd2IVUsz47ow',
      'Stand to Reason': 'UCqXKVgKNrQlVd2IVUsz47ow',
      'Cold Case Christianity': 'UCqXKVgKNrQlVd2IVUsz47ow',
      'Michael Heiser': 'UCqXKVgKNrQlVd2IVUsz47ow',
    };
    
    final resources = <ApologeticsResource>[];
    
    for (final entry in curatedChannels.entries) {
      try {
        final channelVideos = await _getChannelVideos(entry.value, topic);
        resources.addAll(channelVideos.map((video) => video.copyWith(
          channelName: entry.key,
          source: 'Curated',
        )));
      } catch (e) {
        print('Error fetching from ${entry.key}: $e');
      }
    }
    
    return resources;
  }
  
  Future<List<ApologeticsResource>> _getChannelVideos(String channelId, String topic) async {
    try {
      final query = Uri.encodeComponent(topic);
      final url = '$_youtubeBaseUrl/search?part=snippet&channelId=$channelId&q=$query&type=video&maxResults=3&key=$_youtubeApiKey';
      
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final items = data['items'] as List;
        
        return items.map((item) => ApologeticsResource(
          title: item['snippet']['title'],
          description: item['snippet']['description'],
          thumbnailUrl: item['snippet']['thumbnails']['medium']['url'],
          videoUrl: 'https://www.youtube.com/watch?v=${item['id']['videoId']}',
          videoId: item['id']['videoId'],
          channelName: item['snippet']['channelTitle'],
          type: ResourceType.video,
          source: 'Curated',
        )).toList();
      }
    } catch (e) {
      print('Channel search error: $e');
    }
    
    return [];
  }
  
  Future<List<ApologeticsResource>> _getBooks(String topic) async {
    final books = {
      'Existence of God': [
        {'title': 'Reasonable Faith', 'author': 'William Lane Craig', 'url': 'https://www.amazon.com/dp/1433501155'},
        {'title': 'The Reason for God', 'author': 'Timothy Keller', 'url': 'https://www.amazon.com/dp/0525950494'},
      ],
      'Problem of Evil': [
        {'title': 'The Problem of Pain', 'author': 'C.S. Lewis', 'url': 'https://www.amazon.com/dp/0060652969'},
        {'title': 'Hard Sayings of the Bible', 'author': 'Walter Kaiser', 'url': 'https://www.amazon.com/dp/0830817476'},
      ],
      'Biblical Reliability': [
        {'title': 'The Unseen Realm', 'author': 'Michael Heiser', 'url': 'https://www.amazon.com/dp/1683441705'},
        {'title': 'Supernatural', 'author': 'Michael Heiser', 'url': 'https://www.amazon.com/dp/1683442083'},
        {'title': 'The New Testament Documents', 'author': 'F.F. Bruce', 'url': 'https://www.amazon.com/dp/0802822193'},
      ],
    };
    
    final topicBooks = books[topic] ?? [];
    return topicBooks.map((book) => ApologeticsResource(
      title: book['title']!,
      description: 'By ${book['author']}',
      thumbnailUrl: 'https://via.placeholder.com/300x400/4A90E2/FFFFFF?text=Book',
      videoUrl: book['url']!,
      videoId: '',
      channelName: book['author']!,
      type: ResourceType.book,
      source: 'Books',
    )).toList();
  }
  
  Future<List<ApologeticsResource>> _getArticles(String topic) async {
    final articles = {
      'Biblical Reliability': [
        {'title': 'The Divine Council Worldview', 'author': 'Michael Heiser', 'url': 'https://drmsh.com/the-divine-council/'},
        {'title': 'Demons: What the Bible Really Says', 'author': 'Michael Heiser', 'url': 'https://drmsh.com/demons/'},
      ],
      'Existence of God': [
        {'title': 'The Kalam Cosmological Argument', 'author': 'William Lane Craig', 'url': 'https://www.reasonablefaith.org/writings/popular-writings/existence-nature-of-god/the-kalam-cosmological-argument/'},
      ],
    };
    
    final topicArticles = articles[topic] ?? [];
    return topicArticles.map((article) => ApologeticsResource(
      title: article['title']!,
      description: 'Article by ${article['author']}',
      thumbnailUrl: 'https://via.placeholder.com/300x200/28A745/FFFFFF?text=Article',
      videoUrl: article['url']!,
      videoId: '',
      channelName: article['author']!,
      type: ResourceType.article,
      source: 'Articles',
    )).toList();
  }

  List<String> getPopularTopics() {
    return [
      'Existence of God',
      'Problem of Evil',
      'Historical Jesus',
      'Resurrection Evidence',
      'Biblical Reliability',
      'Science and Faith',
      'Moral Argument',
      'Fine-Tuning Universe',
      'Archaeological Evidence',
      'Prophecy Fulfillment',
    ];
  }
}

class ApologeticsResource {
  final String title;
  final String description;
  final String thumbnailUrl;
  final String videoUrl;
  final String videoId;
  final String channelName;
  final ResourceType type;
  final String source;
  
  ApologeticsResource({
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.videoUrl,
    required this.videoId,
    required this.channelName,
    required this.type,
    required this.source,
  });
  
  ApologeticsResource copyWith({
    String? channelName,
    String? source,
  }) {
    return ApologeticsResource(
      title: title,
      description: description,
      thumbnailUrl: thumbnailUrl,
      videoUrl: videoUrl,
      videoId: videoId,
      channelName: channelName ?? this.channelName,
      type: type,
      source: source ?? this.source,
    );
  }
}

enum ResourceType { video, article, podcast, book }