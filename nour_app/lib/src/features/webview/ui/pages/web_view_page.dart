import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Generic in-app browser. Renders [url] inside a [WebViewWidget] under the
/// shared [UIAppBar] titled [title]. Used for legal / info pages (terms of
/// use, privacy policy, about) so users never leave the app.
@RoutePage()
class WebViewPage extends StatefulWidget {
  const WebViewPage({
    super.key,
    @QueryParam('url') this.url = '',
    @QueryParam('title') this.title = '',
  });

  final String url;
  final String title;

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(UIColorsToken.bgPrimary)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _loading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          UIAppBar(
            title: widget.title,
            onBack: () => context.router.maybePop(),
          ),
          Expanded(
            child: Stack(
              children: [
                WebViewWidget(controller: _controller),
                if (_loading)
                  const Center(
                    child: CircularProgressIndicator(
                      color: UIColorsToken.textYellow,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
