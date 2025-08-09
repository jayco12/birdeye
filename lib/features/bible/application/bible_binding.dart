import 'package:get/get.dart';
import 'bible_controller.dart';
import '../../bible/data/datasources/bible_api_service.dart';
import '../../bible/data/repositories/bible_repository_impl.dart';
import '../../bible/domain/repositories/bible_repository.dart';
import 'package:http/http.dart' as http;

class BibleBinding extends Bindings {
  @override
   void dependencies() {
    // Provide http.Client first
    Get.lazyPut<http.Client>(() => http.Client());

    // Provide API service with injected client
    Get.lazyPut<BibleApiService>(() => BibleApiService(Get.find<http.Client>()));

    // Provide repository implementation with injected API service
    Get.lazyPut<BibleRepository>(() => BibleRepositoryImpl(Get.find<BibleApiService>()));

    // Provide controllers
    Get.lazyPut<BibleController>(() => BibleController(repository: Get.find<BibleRepository>()));
  
  }
}