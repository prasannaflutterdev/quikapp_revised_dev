import 'package:flutter/material.dart';
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
    super.key,
    required this.initialUrl,
    required this.bottomMenuItems,
    required this.isBottomMenu,
    required this.bottomMenuBgColor,
    required this.bottomMenuIconColor,
    required this.bottomMenuTextColor,
    required this.bottomMenuActiveTabColor,
    required this.bottomMenuIconPosition,
    required this.bottomMenuVisibleOn,
  });

  @override
  State<MainHome> createState() => _MainHomeState();
}

class _MainHomeState extends State<MainHome> {
  InAppWebViewController? webViewController;
  int _currentIndex = 0;
  bool _isLoading = true;
  String _currentUrl = '';

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.initialUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(widget.initialUrl)),
            onWebViewCreated: (controller) {
              webViewController = controller;
            },
            onLoadStart: (controller, url) {
              setState(() {
                _isLoading = true;
                _currentUrl = url?.toString() ?? '';
              });
            },
            onLoadStop: (controller, url) {
              setState(() {
                _isLoading = false;
                _currentUrl = url?.toString() ?? '';
              });
            },
            onLoadError: (controller, url, code, message) {
              debugPrint('Web resource error: $message');
            },
          ),
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
          webViewController?.loadUrl(
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
