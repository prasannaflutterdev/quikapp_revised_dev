import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../config/env_config.dart';
import 'web_view_container.dart';
import 'bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool? hasInternet;
  int _currentIndex = 0;
  InAppWebViewController? webViewController;
  final List<Map<String, String>> bottomMenuItems = jsonDecode(
          const String.fromEnvironment('BOTTOMMENU_ITEMS', defaultValue: '[]'))
      .cast<Map<String, dynamic>>()
      .map((item) => item.map((key, value) => MapEntry(key, value.toString())))
      .toList();

  Color _parseHexColor(String hexColor) {
    try {
      hexColor = hexColor.replaceAll('#', '');
      if (hexColor.length == 6) {
        hexColor = 'FF$hexColor';
      }
      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      debugPrint('Error parsing color: $e');
      return Colors.black;
    }
  }

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    Connectivity().onConnectivityChanged.listen(_updateConnectivity);
  }

  Future<void> _checkConnectivity() async {
    final results = await Connectivity().checkConnectivity();
    _updateConnectivity(results);
  }

  void _updateConnectivity(List<ConnectivityResult> results) {
    if (!mounted) return;
    setState(() {
      hasInternet = !results.contains(ConnectivityResult.none);
    });
  }

  Future<bool> _onBackPressed() async {
    if (webViewController == null) return true;

    final canGoBack = await webViewController!.canGoBack();
    if (canGoBack) {
      webViewController!.goBack();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    const webUrl = String.fromEnvironment('WEB_URL', defaultValue: '');
    const isDeeplink =
        const String.fromEnvironment('IS_DEEPLINK', defaultValue: 'false') ==
            'true';
    const isLoadIndicator =
        const String.fromEnvironment('IS_LOAD_IND', defaultValue: 'true') ==
            'true';
    const isBottomMenu =
        const String.fromEnvironment('IS_BOTTOMMENU', defaultValue: 'false') ==
            'true';

    final config = EnvConfig.instance;

    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        body: SafeArea(
          child: Builder(
            builder: (context) {
              if (hasInternet == null) {
                return const Center(child: CircularProgressIndicator());
              }

              if (hasInternet == false) {
                return const Center(child: Text('📴 No Internet Connection'));
              }

              return WebViewContainer(
                initialUrl: webUrl.isNotEmpty ? webUrl : 'https://pixaware.co',
                isDeeplink: isDeeplink,
                isLoadIndicator: isLoadIndicator,
                onWebViewCreated: (controller) {
                  webViewController = controller;
                },
              );
            },
          ),
        ),
        bottomNavigationBar: isBottomMenu && bottomMenuItems.isNotEmpty
            ? CustomBottomNavBar(
                currentIndex: _currentIndex,
                menuItems: bottomMenuItems,
                onTap: (index) {
                  setState(() => _currentIndex = index);
                  final item = bottomMenuItems[index];
                  webViewController?.loadUrl(
                    urlRequest: URLRequest(url: WebUri(item['url'] ?? '')),
                  );
                },
                backgroundColor: _parseHexColor(
                  const String.fromEnvironment('BOTTOMMENU_BG_COLOR',
                      defaultValue: '#FFFFFF'),
                ),
                selectedItemColor: _parseHexColor(
                  const String.fromEnvironment('BOTTOMMENU_ACTIVE_TAB_COLOR',
                      defaultValue: '#FF2D55'),
                ),
                unselectedItemColor: _parseHexColor(
                  const String.fromEnvironment('BOTTOMMENU_ICON_COLOR',
                      defaultValue: '#888888'),
                ),
                fontFamily: config.bottomMenuFont,
                fontSize: config.bottomMenuFontSize,
                fontWeight: config.bottomMenuFontBold
                    ? FontWeight.bold
                    : FontWeight.normal,
                isItalic: config.bottomMenuFontItalic,
              )
            : null,
      ),
    );
  }
}
