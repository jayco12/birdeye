import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class VerseWebViewScreen extends StatelessWidget {
  final String title;
  final String url;

  const VerseWebViewScreen({required this.title, required this.url, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: WebViewWidget(controller: WebViewController()..loadRequest(Uri.parse(url))),
    );
  }
}
