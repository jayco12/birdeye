import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/verse_model.dart';

class BibleApiService {
final http.Client client;

  BibleApiService(this.client);

 Future<List<VerseModel>> fetchVerses(String query, {String translation = 'KJV'}) async {
  final encodedQuery = Uri.encodeComponent(query);
  final url = Uri.parse('https://bible-api.com/$encodedQuery?translation=$translation');

  final response = await client.get(url);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    if (data['verses'] != null) {
      final versesJson = data['verses'] as List;
      return versesJson
          .map((v) => VerseModel.fromJson(v as Map<String, dynamic>, translation))
          .toList();
    } else if (data['text'] != null) {
      // Some results may return just 'text' for a single verse or passage
      return [
        VerseModel.fromJson(data as Map<String, dynamic>, translation)
      ];
    } else {
      throw Exception('No verses found for query.');
    }
  } else if (response.statusCode == 404) {
    // Gracefully handle no results for keyword search
    return [];
  } else {
    throw Exception('Failed to search verses');
  }
}
}
