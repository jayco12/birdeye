import 'package:get/get.dart';
import '../presentation/screens/offline_manager_screen.dart';

class OfflineController extends GetxController {
  final RxDouble storageUsed = 0.0.obs;
  final RxList<String> downloadedTranslations = <String>[].obs;
  final RxList<String> downloadingTranslations = <String>[].obs;
  
  final List<TranslationInfo> availableTranslations = [
    TranslationInfo(code: 'KJV', name: 'King James Version', size: 4.2),
    TranslationInfo(code: 'NIV', name: 'New International Version', size: 4.1),
    TranslationInfo(code: 'ESV', name: 'English Standard Version', size: 4.3),
    TranslationInfo(code: 'NASB', name: 'New American Standard Bible', size: 4.4),
    TranslationInfo(code: 'NLT', name: 'New Living Translation', size: 4.0),
  ];

  @override
  void onInit() {
    super.onInit();
    _loadDownloadedTranslations();
  }

  void _loadDownloadedTranslations() {
    // Load from local storage
    downloadedTranslations.addAll(['KJV']); // Default
    _calculateStorageUsed();
  }

  void _calculateStorageUsed() {
    double total = 0;
    for (String code in downloadedTranslations) {
      final translation = availableTranslations.firstWhere((t) => t.code == code);
      total += translation.size;
    }
    storageUsed.value = total;
  }

  Future<void> downloadTranslation(String code) async {
    downloadingTranslations.add(code);
    
    // Simulate download
    await Future.delayed(const Duration(seconds: 3));
    
    downloadingTranslations.remove(code);
    downloadedTranslations.add(code);
    _calculateStorageUsed();
  }

  void deleteTranslation(String code) {
    if (code == 'KJV') return; // Don't delete default
    downloadedTranslations.remove(code);
    _calculateStorageUsed();
  }
}