import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_strings.dart';
import 'features/bible/application/bible_binding.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

void main() {
    WidgetsFlutterBinding.ensureInitialized();
  WebViewPlatform.instance = WebKitWebViewPlatform(); // Add this line

  runApp(const BibleApp());
}

class BibleApp extends StatelessWidget {
  const BibleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.primary,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        fontFamily: 'Inter',
      ),
       darkTheme: ThemeData.dark(),
  themeMode: ThemeMode.system, 
      initialBinding: BibleBinding(),
      initialRoute: AppRoutes.bible,
      getPages: appPages,
    );
  }
}
