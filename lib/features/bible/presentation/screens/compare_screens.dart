import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BibleCompareScreen extends StatefulWidget {
  const BibleCompareScreen({super.key});

  @override
  State<BibleCompareScreen> createState() => _BibleCompareScreenState();
}

class _BibleCompareScreenState extends State<BibleCompareScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..loadRequest(Uri.parse('https://biblehub.com/'))
      ..setJavaScriptMode(JavaScriptMode.unrestricted);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Compare Translations')),
      body: WebViewWidget(controller: _controller),
    );
  }
}
