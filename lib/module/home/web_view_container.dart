import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';

class WebViewContainer extends StatefulWidget {
  final String initialUrl;
  final bool isDeeplink;
  final bool isLoadIndicator;
  final Function(InAppWebViewController)? onWebViewCreated;

  const WebViewContainer({
    Key? key,
    required this.initialUrl,
    this.isDeeplink = false,
    this.isLoadIndicator = true,
    this.onWebViewCreated,
  }) : super(key: key);

  @override
  State<WebViewContainer> createState() => _WebViewContainerState();
}

class _WebViewContainerState extends State<WebViewContainer> {
  final GlobalKey webViewKey = GlobalKey();
  InAppWebViewController? webViewController;
  PullToRefreshController? pullToRefreshController;
  bool isLoading = true;
  bool hasError = false;
  String? _pendingInitialUrl;
  String get myDomain => Uri.parse(widget.initialUrl).host;

  @override
  void initState() {
    super.initState();
    _initPullToRefresh();
  }

  void _initPullToRefresh() {
    pullToRefreshController = PullToRefreshController(
      onRefresh: () async {
        await webViewController?.reload();
        await pullToRefreshController?.endRefreshing();
      },
    );
  }

  Future<bool> _handleUrlLoading(
      InAppWebViewController controller, Uri? uri) async {
    if (uri == null) return true;

    if (!uri.host.contains(myDomain)) {
      if (widget.isDeeplink) {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          return false;
        }
      } else {
        Fluttertoast.showToast(
          msg: "External links are disabled",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InAppWebView(
          key: webViewKey,
          initialUrlRequest: URLRequest(url: WebUri(widget.initialUrl)),
          pullToRefreshController: pullToRefreshController,
          onWebViewCreated: (controller) {
            webViewController = controller;
            widget.onWebViewCreated?.call(controller);
            if (_pendingInitialUrl != null) {
              controller.loadUrl(
                urlRequest: URLRequest(url: WebUri(_pendingInitialUrl!)),
              );
              _pendingInitialUrl = null;
            }
          },
          shouldOverrideUrlLoading: (controller, navigationAction) async {
            final shouldLoad = await _handleUrlLoading(
                controller, navigationAction.request.url);
            return shouldLoad
                ? NavigationActionPolicy.ALLOW
                : NavigationActionPolicy.CANCEL;
          },
          onLoadStart: (_, __) => setState(() {
            isLoading = true;
            hasError = false;
          }),
          onLoadStop: (_, __) => setState(() => isLoading = false),
          onLoadError: (_, __, code, message) {
            debugPrint('Load error [$code]: $message');
            setState(() {
              hasError = true;
              isLoading = false;
            });
          },
          onLoadHttpError: (_, __, statusCode, description) {
            debugPrint('HTTP error [$statusCode]: $description');
            setState(() {
              hasError = true;
              isLoading = false;
            });
          },
          onConsoleMessage: (_, consoleMessage) {
            debugPrint('Console: ${consoleMessage.message}');
          },
        ),
        if (widget.isLoadIndicator && isLoading)
          const Center(child: CircularProgressIndicator()),
        if (hasError)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  "Oops! Couldn't load the App.",
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      hasError = false;
                      isLoading = true;
                    });
                    webViewController?.loadUrl(
                      urlRequest: URLRequest(url: WebUri(widget.initialUrl)),
                    );
                  },
                  child: const Text("Retry"),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
