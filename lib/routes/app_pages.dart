import 'package:get/get.dart';
import '../features/bible/presentation/screens/bible_screen.dart';
import '../features/bible/application/bible_binding.dart';
import 'app_routes.dart';

final List<GetPage> appPages = [
  GetPage(
    name: AppRoutes.bible,
    page: () =>  BibleScreen(),
    binding: BibleBinding(),
  ),
];
