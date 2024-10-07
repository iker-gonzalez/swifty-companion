import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WebViewPage extends StatelessWidget {
  final String initialUrl;
  final Function(String) onCodeReceived;

  const WebViewPage({super.key, required this.initialUrl, required this.onCodeReceived});

  @override
  Widget build(BuildContext context) {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onHttpError: (HttpResponseError error) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith(dotenv.env['REDIRECT_URI']!)) {
              final uri = Uri.parse(request.url);
              final code = uri.queryParameters['code'];
              if (code != null) {
                onCodeReceived(code);
                // Instead of popping here, we'll let the onCodeReceived callback handle navigation
                return NavigationDecision.prevent;
              }
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(initialUrl));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: WebViewWidget(controller: controller),
    );
  }
}