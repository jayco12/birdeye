import 'package:http/http.dart' as http;
import '../../../../tools/scripture_data_generator.dart';
import '../datasources/scripture_database.dart';

class ScriptureGeneratorService {
  static const String geminiApiKey = 'AIzaSyDhvYjjCg_JiwV7ZRch-Akaf2BLdIk8lG4';
  
  static Future<void> generateIfNeeded() async {
    final db = ScriptureDatabase();
    
    // Check if data already exists
    if (await db.hasData()) {
      print('Scripture data already exists');
      return;
    }
    
    print('Starting scripture data generation...');
    final generator = ScriptureDataGenerator(http.Client(), geminiApiKey);
    await generator.generateAllScriptureData();
    
    // Import generated data
    await db.importFromJson('complete_scripture_data.json');
    print('Scripture data generation complete!');
  }
  
  static Future<void> forceRegenerate() async {
    print('Force regenerating scripture data...');
    final generator = ScriptureDataGenerator(http.Client(), geminiApiKey);
    await generator.generateAllScriptureData();
    
    final db = ScriptureDatabase();
    await db.importFromJson('complete_scripture_data.json');
    print('Force regeneration complete!');
  }
}