import 'package:http/http.dart' as http;
import 'scripture_data_generator.dart';

void main() async {
  const geminiApiKey = 'AIzaSyDhvYjjCg_JiwV7ZRch-Akaf2BLdIk8lG4'; // Replace with your key
  
  final generator = ScriptureDataGenerator(http.Client(), geminiApiKey);
  
  print('Starting scripture data generation...');
  print('This will generate insights, study questions, and word analysis for all ~31,000 Bible verses');
  print('Estimated time: 10-15 hours');
  
  await generator.generateAllScriptureData();
  
  print('Generation complete!');
}