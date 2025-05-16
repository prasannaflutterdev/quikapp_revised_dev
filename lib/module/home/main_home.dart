import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'bottom_nav_config.dart';
import 'icon_handler.dart';

class MainHome extends StatefulWidget {
  final String initialUrl;
  final List<Map<String, dynamic>> bottomMenuItems;
  final bool isBottomMenu;
  final Color bottomMenuBgColor;
  final Color bottomMenuIconColor;
  final Color bottomMenuTextColor;
  final Color bottomMenuActiveTabColor;
  final String bottomMenuIconPosition;
  final List<String> bottomMenuVisibleOn;

  const MainHome({
    Key? key,
    required this.initialUrl,
    required this.bottomMenuItems,
    required this.isBottomMenu,
    required this.bottomMenuBgColor,
    required this.bottomMenuIconColor,
    required this.bottomMenuTextColor,
    required this.bottomMenuActiveTabColor,
    required this.bottomMenuIconPosition,
    required this.bottomMenuVisibleOn,
  }) : super(key: key);

  @override
  State<MainHome> createState() => _MainHomeState();
}

class _MainHomeState extends State<MainHome> {
  late final WebViewController webViewController;
  int _currentIndex = 0;
  bool _isLoading = true;
  String _currentUrl = '';

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.initialUrl;
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
              _currentUrl = url;
            });
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('Web resource error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.initialUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          WebViewWidget(controller: webViewController),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
      bottomNavigationBar: widget.isBottomMenu
          ? BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
                final item = widget.bottomMenuItems[index];
                webViewController.loadUrl(
                  urlRequest: URLRequest(url: WebUri(item['url'])),
                );
              },
              backgroundColor: widget.bottomMenuBgColor,
              selectedItemColor: widget.bottomMenuActiveTabColor,
              unselectedItemColor: widget.bottomMenuIconColor,
              type: BottomNavigationBarType.fixed,
              items: widget.bottomMenuItems.map((item) {
                return BottomNavigationBarItem(
                  icon: Icon(
                    IconHandler.getIconByName(item['icon']),
                    color: widget.bottomMenuIconColor,
                  ),
                  activeIcon: Icon(
                    IconHandler.getIconByName(item['icon']),
                    color: widget.bottomMenuActiveTabColor,
                  ),
                  label: item['label'],
                );
              }).toList(),
            )
          : null,
    );
  }
}
