import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Opens [authorizeUrl] in a full-screen in-app WebView.
///
/// Returns the callback URL string when NetSuite redirects to
/// [callbackScheme]://, or null if the user dismisses the dialog.
Future<String?> showNetSuiteAuthWebView(
  BuildContext context,
  String authorizeUrl,
  String callbackScheme,
) {
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _NetSuiteAuthDialog(
      authorizeUrl: authorizeUrl,
      callbackScheme: callbackScheme,
    ),
  );
}

class _NetSuiteAuthDialog extends StatefulWidget {
  final String authorizeUrl;
  final String callbackScheme;

  const _NetSuiteAuthDialog({
    required this.authorizeUrl,
    required this.callbackScheme,
  });

  @override
  State<_NetSuiteAuthDialog> createState() => _NetSuiteAuthDialogState();
}

class _NetSuiteAuthDialogState extends State<_NetSuiteAuthDialog> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _loading = true),
          onPageFinished: (_) => setState(() => _loading = false),
          onNavigationRequest: (request) {
            // Intercept the OAuth callback redirect
            if (request.url.startsWith('${widget.callbackScheme}://')) {
              Navigator.of(context).pop(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.authorizeUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Sign in to NetSuite'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Cancel',
            onPressed: () => Navigator.of(context).pop(null),
          ),
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_loading)
              const LinearProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
