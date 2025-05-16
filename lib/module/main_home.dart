import 'dart:async';

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../config/env_config.dart';

import '../services/notification_service.dart';

class MainHome extends StatefulWidget {
  final String webUrl;
  final bool isBottomMenu;
  final List<Map<String, dynamic>> bottomMenuItems;
  final isDeeplink;
  final backgroundColor;
  final activeTabColor;
  final textColor;
  final iconColor;
  final iconPosition;
  final taglineColor;
  final isLoadIndicator;
  const MainHome(
      {super.key,
      required this.webUrl,
      required this.isBottomMenu,
      required this.bottomMenuItems,
      required this.isDeeplink,
      required this.backgroundColor,
      required this.activeTabColor,
      required this.textColor,
      required this.iconColor,
      required this.iconPosition,
      required this.taglineColor,
      required this.isLoadIndicator});

  @override
  State<MainHome> createState() => _MainHomeState();
}

class _MainHomeState extends State<MainHome> {
  final GlobalKey webViewKey = GlobalKey();

  late bool isBottomMenu;

  // final Color taglineColor = _parseHexColor(const String.fromEnvironment('SPLASH_TAGLINE_COLOR', defaultValue: "#000000"));
  int _currentIndex = 0;

  InAppWebViewController? webViewController;
  WebViewEnvironment? webViewEnvironment;
  late PullToRefreshController? pullToRefreshController;

  static Color _parseHexColor(String hexColor) {
    hexColor = hexColor.replaceFirst('#', '');
    if (hexColor.length == 6) hexColor = 'FF$hexColor';
    return Color(int.parse('0x$hexColor'));
  }

  bool? hasInternet;
// Convert the JSON string into a List of menu objects
  List<Map<String, dynamic>> bottomMenuItems = [];

  String url = "";
  double progress = 0;
  final urlController = TextEditingController();
  DateTime? _lastBackPressed;
  String? _pendingInitialUrl; // 🔹 NEW
  StreamSubscription? _linkSub;
  String myDomain = "";
  bool _initialUriIsHandled = false;

  // String? _pendingInitialUrl;

  InAppWebViewSettings settings = InAppWebViewSettings(
    isInspectable: kDebugMode,
    mediaPlaybackRequiresUserGesture: false,
    allowsInlineMediaPlayback: true,
    iframeAllow: "camera; microphone",
    iframeAllowFullscreen: true,
  );

  void requestPermissions() async {
    if (isCameraEnabled) await Permission.camera.request();
    if (isLocationEnabled) await Permission.location.request(); // GPS
    if (isMicEnabled) await Permission.microphone.request();
    if (isContactEnabled) await Permission.contacts.request();
    if (isCalendarEnabled) await Permission.calendar.request();
    if (isNotificationEnabled) await Permission.notification.request();

    // Always request storage (as per your logic)
    await Permission.storage.request();
    if (isBiometricEnabled) {
      if (Platform.isIOS) {
        // Use raw value 33 for faceId (iOS)
        await Permission.byValue(33).request();
      } else if (Platform.isAndroid) {
        // No need to request biometric permission manually on Android
        // It's requested automatically by biometric plugins like local_auth
      }
    }
  }

  @override
  void initState() {
    super.initState();
    requestPermissions();

    if (pushNotify == true) {
      setupFirebaseMessaging();
      // ✅ Modified: Handle terminated state
      var then = FirebaseMessaging.instance.getInitialMessage().then((message) async {
        if (message != null) {
          final internalUrl = message.data['url'];
          if (internalUrl != null && internalUrl.isNotEmpty) {
            _pendingInitialUrl = internalUrl; // 🔹 Save for later navigation
          }
          await _showLocalNotification(message);
        }
      });
    }

    isBottomMenu = widget.isBottomMenu;
    if (isBottomMenu == true) {
      try {
        bottomMenuItems = widget.bottomMenuItems;
      } catch (e) {
        if (kDebugMode) {
          print("Invalid bottom menu JSON: $e");
        }
      }
    }

    Connectivity().onConnectivityChanged.listen((_) {
      _checkInternetConnection();
    });

    _checkInternetConnection();

    if (!kIsWeb &&
        [TargetPlatform.android, TargetPlatform.iOS]
            .contains(defaultTargetPlatform) &&
        isPullDown) {
      pullToRefreshController = PullToRefreshController(
          settings:
              PullToRefreshSettings(color: _parseHexColor(widget.taglineColor)),
          onRefresh: () async {
            try {
              if (defaultTargetPlatform == TargetPlatform.android) {
                await webViewController?.reload();
              } else if (defaultTargetPlatform == TargetPlatform.iOS) {
                final currentUrl = await webViewController?.getUrl();
                if (currentUrl != null) {
                  await webViewController?.loadUrl(
                    urlRequest: URLRequest(url: currentUrl),
                  );
                }
              }
            } catch (e) {
              debugPrint('❌ Refresh error: $e');
            } finally {
              pullToRefreshController?.endRefreshing(); // ✅ Important!
            }
          });
    } else {
      pullToRefreshController = null;
    }

    Uri parsedUri = Uri.parse(widget.webUrl);
    myDomain = parsedUri.host;
    if (myDomain.startsWith('www.')) {
      myDomain = myDomain.substring(4);
    }
  }

  IconData _getIconByName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return Icons.apps; // default icon when no name is provided
    }

    // Convert to snake_case format that matches Material Icons naming
    String iconName = name.toLowerCase().replaceAll(' ', '_');

    // Try to get the icon using reflection
    try {
      // First try exact match
      final IconData? exactMatch = _getIconByExactName(iconName);
      if (exactMatch != null) {
        return exactMatch;
      }

      // Then try common mappings
      switch (iconName) {
        case 'home':
          return Icons.home;
        case 'info':
        case 'about':
          return Icons.info;
        case 'phone':
          return Icons.phone;
        case 'lock':
          return Icons.lock;
        case 'settings':
          return Icons.settings;
        case 'contact':
          return Icons.contact_page;
        case 'shop':
        case 'store':
          return Icons.storefront;
        case 'cart':
        case 'shopping_cart':
          return Icons.shopping_cart;
        case 'orders':
        case 'order':
          return Icons.receipt_long;
        case 'wishlist':
        case 'favorite':
        case 'like':
          return Icons.favorite;
        case 'category':
          return Icons.category;
        case 'account':
        case 'profile':
          return Icons.account_circle;
        case 'help':
          return Icons.help_outline;
        case 'notifications':
          return Icons.notifications;
        case 'search':
          return Icons.search;
        case 'offer':
        case 'discount':
          return Icons.local_offer;
        case 'services':
          return Icons.miscellaneous_services;
        case 'blogs':
        case 'blog':
          return Icons.article;
        case 'company':
        case 'about_us':
          return Icons.business;
        case 'more':
        case 'menu':
          return Icons.more_horiz;
        // Add more mappings as needed
        default:
          // Try to find a similar icon by partial match
          final IconData? similarMatch = _findSimilarIcon(iconName);
          return similarMatch ?? Icons.apps;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting icon for name: $name - $e');
      }
      return Icons.apps;
    }
  }

  IconData? _getIconByExactName(String name) {
    try {
      switch (name) {
        case 'add':
          return Icons.add;
        case 'delete':
          return Icons.delete;
        case 'edit':
          return Icons.edit;
        case 'share':
          return Icons.share;
        case 'save':
          return Icons.save;
        case 'close':
          return Icons.close;
        case 'menu':
          return Icons.menu;
        case 'refresh':
          return Icons.refresh;
        case 'search':
          return Icons.search;
        case 'settings':
          return Icons.settings;
        case 'person':
          return Icons.person;
        case 'email':
          return Icons.email;
        case 'phone':
          return Icons.phone;
        case 'camera':
          return Icons.camera;
        case 'photo':
          return Icons.photo;
        case 'image':
          return Icons.image;
        case 'video':
          return Icons.video_call;
        case 'music':
          return Icons.music_note;
        case 'location':
          return Icons.location_on;
        case 'map':
          return Icons.map;
        case 'directions':
          return Icons.directions;
        case 'time':
          return Icons.access_time;
        case 'calendar':
          return Icons.calendar_today;
        case 'chat':
          return Icons.chat;
        case 'message':
          return Icons.message;
        case 'notification':
          return Icons.notifications;
        case 'favorite':
          return Icons.favorite;
        case 'bookmark':
          return Icons.bookmark;
        case 'star':
          return Icons.star;
        case 'warning':
          return Icons.warning;
        case 'error':
          return Icons.error;
        case 'info':
          return Icons.info;
        case 'help':
          return Icons.help;
        case 'security':
          return Icons.security;
        case 'lock':
          return Icons.lock;
        case 'unlock':
          return Icons.lock_open;
        case 'cloud':
          return Icons.cloud;
        case 'upload':
          return Icons.upload;
        case 'download':
          return Icons.download;
        case 'sync':
          return Icons.sync;
        case 'wifi':
          return Icons.wifi;
        case 'bluetooth':
          return Icons.bluetooth;
        case 'battery':
          return Icons.battery_full;
        case 'power':
          return Icons.power_settings_new;
        case 'settings_applications':
          return Icons.settings_applications;
        case 'account_circle':
          return Icons.account_circle;
        case 'person_add':
          return Icons.person_add;
        case 'group':
          return Icons.group;
        case 'business':
          return Icons.business;
        case 'work':
          return Icons.work;
        case 'home':
          return Icons.home;
        case 'apps':
          return Icons.apps;
        case 'arrow_back':
          return Icons.arrow_back;
        case 'arrow_forward':
          return Icons.arrow_forward;
        case 'arrow_upward':
          return Icons.arrow_upward;
        case 'arrow_downward':
          return Icons.arrow_downward;
        case 'menu_open':
          return Icons.menu_open;
        case 'more_vert':
          return Icons.more_vert;
        case 'more_horiz':
          return Icons.more_horiz;
        case 'check':
          return Icons.check;
        case 'check_circle':
          return Icons.check_circle;
        case 'close_circle':
          return Icons.cancel;
        case 'add_circle':
          return Icons.add_circle;
        case 'remove_circle':
          return Icons.remove_circle;
        case 'flag':
          return Icons.flag;
        case 'folder':
          return Icons.folder;
        case 'file':
          return Icons.file_present;
        case 'copy':
          return Icons.content_copy;
        case 'paste':
          return Icons.content_paste;
        case 'cut':
          return Icons.content_cut;
        case 'attach':
          return Icons.attach_file;
        case 'link':
          return Icons.link;
        case 'cloud_upload':
          return Icons.cloud_upload;
        case 'cloud_download':
          return Icons.cloud_download;
        case 'cloud_off':
          return Icons.cloud_off;
        case 'visibility':
          return Icons.visibility;
        case 'visibility_off':
          return Icons.visibility_off;
        case 'mic':
          return Icons.mic;
        case 'mic_off':
          return Icons.mic_off;
        case 'volume_up':
          return Icons.volume_up;
        case 'volume_down':
          return Icons.volume_down;
        case 'volume_mute':
          return Icons.volume_mute;
        case 'volume_off':
          return Icons.volume_off;
        default:
          return null;
      }
    } catch (e) {
      return null;
    }
  }

  IconData? _findSimilarIcon(String name) {
    try {
      // Try to find icons that contain the name as a substring
      if (name.contains('add')) return Icons.add;
      if (name.contains('delete')) return Icons.delete;
      if (name.contains('edit')) return Icons.edit;
      if (name.contains('share')) return Icons.share;
      if (name.contains('save')) return Icons.save;
      if (name.contains('close')) return Icons.close;
      if (name.contains('menu')) return Icons.menu;
      if (name.contains('refresh')) return Icons.refresh;
      if (name.contains('search')) return Icons.search;
      if (name.contains('setting')) return Icons.settings;
      if (name.contains('person')) return Icons.person;
      if (name.contains('user')) return Icons.person;
      if (name.contains('profile')) return Icons.account_circle;
      if (name.contains('account')) return Icons.account_circle;
      if (name.contains('email')) return Icons.email;
      if (name.contains('mail')) return Icons.email;
      if (name.contains('phone')) return Icons.phone;
      if (name.contains('call')) return Icons.phone;
      if (name.contains('camera')) return Icons.camera;
      if (name.contains('photo')) return Icons.photo;
      if (name.contains('image')) return Icons.image;
      if (name.contains('picture')) return Icons.image;
      if (name.contains('video')) return Icons.video_call;
      if (name.contains('music')) return Icons.music_note;
      if (name.contains('audio')) return Icons.music_note;
      if (name.contains('location')) return Icons.location_on;
      if (name.contains('map')) return Icons.map;
      if (name.contains('direction')) return Icons.directions;
      if (name.contains('time')) return Icons.access_time;
      if (name.contains('clock')) return Icons.access_time;
      if (name.contains('calendar')) return Icons.calendar_today;
      if (name.contains('date')) return Icons.calendar_today;
      if (name.contains('chat')) return Icons.chat;
      if (name.contains('message')) return Icons.message;
      if (name.contains('notification')) return Icons.notifications;
      if (name.contains('alert')) return Icons.notifications;
      if (name.contains('favorite')) return Icons.favorite;
      if (name.contains('like')) return Icons.favorite;
      if (name.contains('bookmark')) return Icons.bookmark;
      if (name.contains('star')) return Icons.star;
      if (name.contains('rate')) return Icons.star;
      if (name.contains('warning')) return Icons.warning;
      if (name.contains('error')) return Icons.error;
      if (name.contains('info')) return Icons.info;
      if (name.contains('help')) return Icons.help;
      if (name.contains('security')) return Icons.security;
      if (name.contains('lock')) return Icons.lock;
      if (name.contains('unlock')) return Icons.lock_open;
      if (name.contains('cloud')) return Icons.cloud;
      if (name.contains('upload')) return Icons.upload;
      if (name.contains('download')) return Icons.download;
      if (name.contains('sync')) return Icons.sync;
      if (name.contains('wifi')) return Icons.wifi;
      if (name.contains('bluetooth')) return Icons.bluetooth;
      if (name.contains('battery')) return Icons.battery_full;
      if (name.contains('power')) return Icons.power_settings_new;
      if (name.contains('home')) return Icons.home;
      if (name.contains('house')) return Icons.home;
      if (name.contains('work')) return Icons.work;
      if (name.contains('business')) return Icons.business;
      if (name.contains('company')) return Icons.business;
      if (name.contains('office')) return Icons.business;
      if (name.contains('group')) return Icons.group;
      if (name.contains('team')) return Icons.group;
      if (name.contains('people')) return Icons.group;
      if (name.contains('folder')) return Icons.folder;
      if (name.contains('file')) return Icons.file_present;
      if (name.contains('document')) return Icons.file_present;
      if (name.contains('attach')) return Icons.attach_file;
      if (name.contains('link')) return Icons.link;
      if (name.contains('visibility')) return Icons.visibility;
      if (name.contains('show')) return Icons.visibility;
      if (name.contains('hide')) return Icons.visibility_off;
      if (name.contains('mic')) return Icons.mic;
      if (name.contains('volume')) return Icons.volume_up;
      if (name.contains('sound')) return Icons.volume_up;
      if (name.contains('mute')) return Icons.volume_off;
    } catch (e) {
      return null;
    }
    return null;
  }

  /// ✅ Navigation from notification
  void _handleNotificationNavigation(RemoteMessage message) {
    final internalUrl = message.data['url'];
    if (internalUrl != null && webViewController != null) {
      webViewController?.loadUrl(
        urlRequest: URLRequest(url: WebUri(internalUrl)),
      );
    } else {
      debugPrint('🔗 No URL to navigate');
    }
  }

  /// ✅ Setup push notification logic
  void setupFirebaseMessaging() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    if (Platform.isIOS) {
      await messaging.requestPermission(alert: true, badge: true, sound: true);
    }

    await messaging.subscribeToTopic('all_users');
    if (Platform.isAndroid) {
      await messaging.subscribeToTopic('android_users');
    } else if (Platform.isIOS) {
      await messaging.subscribeToTopic('ios_users');
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      await _showLocalNotification(message);
      _handleNotificationNavigation(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("📲 Opened from background tap: ${message.data}");
      _handleNotificationNavigation(message);
    });
  }

  /// ✅ Local push with optional image
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final android = notification?.android;
    final imageUrl = notification?.android?.imageUrl ?? message.data['image'];

    AndroidNotificationDetails androidDetails;

    AndroidNotificationDetails defaultAndroidDetails() {
      return AndroidNotificationDetails(
        'default_channel',
        'Default',
        channelDescription: 'Default notification channel',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        icon: '@mipmap/ic_launcher',
      );
    }

    if (notification != null && android != null) {
      if (imageUrl != null && imageUrl.isNotEmpty) {
        try {
          final http.Response response = await http.get(Uri.parse(imageUrl));
          final tempDir = await getTemporaryDirectory();
          final filePath = '${tempDir.path}/notif_image.jpg';
          final file = File(filePath);
          await file.writeAsBytes(response.bodyBytes);

          androidDetails = AndroidNotificationDetails(
            'default_channel',
            'Default',
            channelDescription: 'Default notification channel',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            icon: '@mipmap/ic_launcher',
            styleInformation: BigPictureStyleInformation(
              FilePathAndroidBitmap(filePath),
              largeIcon: FilePathAndroidBitmap(filePath),
              contentTitle: '<b>${notification.title}</b>',
              summaryText: notification.body,
              htmlFormatContentTitle: true,
              htmlFormatSummaryText: true,
            ),
          );
        } catch (e) {
          if (kDebugMode) {
            print('❌ Failed to load image: $e');
          }
          androidDetails = defaultAndroidDetails();
        }
      } else {
        androidDetails = defaultAndroidDetails();
      }

      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(android: androidDetails),
      );
    }
  }

  /// ✅ Connectivity
  Future<void> _checkInternetConnection() async {
    final result = await Connectivity().checkConnectivity();
    final isOnline = result != ConnectivityResult.none;
    if (mounted) {
      setState(() {
        hasInternet = isOnline;
      });
    }
  }

  /// ✅ Back button double-press exit
  Future<bool> _onBackPressed() async {
    if (webViewController != null) {
      bool canGoBack = await webViewController!.canGoBack();
      if (canGoBack) {
        await webViewController!.goBack();
        return false; // Don't exit app
      }
    }

    DateTime now = DateTime.now();
    if (_lastBackPressed == null ||
        now.difference(_lastBackPressed!) > Duration(seconds: 2)) {
      _lastBackPressed = now;
      Fluttertoast.showToast(
        msg: "Press back again to exit",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
      );
      return false;
    }

    return true; // Exit app
  }

  bool isLoading = true;
  bool hasError = false;

  // int _currentIndex = 0;

  Widget _buildLabel(String label, bool isActive, String fontFamily,
      double fontSize, bool isBold, bool isItalic, Color color) {
    return Text(
      label,
      style: GoogleFonts.getFont(
        fontFamily,
        fontSize: fontSize,
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
        color: color,
      ),
    );
  }

  Widget _buildBottomNavItem(Map<String, dynamic> item, bool isActive) {
    final fontFamily =
        const String.fromEnvironment('BOTTOMMENU_FONT', defaultValue: 'Roboto');
    final fontSize = double.parse(const String.fromEnvironment(
        'BOTTOMMENU_FONT_SIZE',
        defaultValue: '12'));
    final isBold = const String.fromEnvironment('BOTTOMMENU_FONT_BOLD',
            defaultValue: 'false') ==
        'true';
    final isItalic = const String.fromEnvironment('BOTTOMMENU_FONT_ITALIC',
            defaultValue: 'false') ==
        'true';
    final iconPosition = const String.fromEnvironment(
        'BOTTOMMENU_ICON_POSITION',
        defaultValue: 'above');

    final icon = Icon(
      _getIconByName(item['icon']),
      color: isActive ? Colors.blue : Colors.grey,
    );
    final label = _buildLabel(item['label'], isActive, fontFamily, fontSize,
        isBold, isItalic, isActive ? Colors.blue : Colors.grey);

    switch (iconPosition) {
      case 'above':
        return Column(mainAxisSize: MainAxisSize.min, children: [icon, label]);
      case 'beside':
        return Row(
            mainAxisSize: MainAxisSize.min,
            children: [icon, const SizedBox(width: 6), label]);
      case 'only_icon':
        return icon;
      case 'only_text':
        return label;
      default:
        return Column(mainAxisSize: MainAxisSize.min, children: [icon, label]);
    }
  }

  Widget _buildMenuItem(Map<String, dynamic> item, bool isActive) {
    final icon = Icon(
      _getIconByName(item['icon']),
      color: isActive ? Colors.blue : Colors.grey,
    );
    final label = Text(item['label']);

    switch (widget.iconPosition) {
      case 'above':
        return Column(children: [icon, label]);
      case 'beside':
        return Row(children: [icon, label]);
      case 'only_icon':
        return icon;
      case 'only_text':
        return label;
      default:
        return Column(children: [icon, label]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WillPopScope(
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

                return Stack(
                  children: [
                    if (!hasError)
                      InAppWebView(
                        key: webViewKey,
                        webViewEnvironment: webViewEnvironment,
                        initialUrlRequest: URLRequest(
                          url: WebUri(widget.webUrl.isNotEmpty
                              ? widget.webUrl
                              : "https://pixaware.co"),
                        ),
                        pullToRefreshController: pullToRefreshController,
                        onWebViewCreated: (controller) {
                          webViewController = controller;
                          if (_pendingInitialUrl != null) {
                            controller.loadUrl(
                              urlRequest:
                                  URLRequest(url: WebUri(_pendingInitialUrl!)),
                            );
                            _pendingInitialUrl = null;
                          }
                        },
                        shouldOverrideUrlLoading:
                            (controller, navigationAction) async {
                          final uri = navigationAction.request.url;
                          // if (uri != null && !uri.toString().contains(widget.webUrl)) {
                          if (uri != null && !uri.host.contains(myDomain)) {
                            if (widget.isDeeplink) {
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri,
                                    mode: LaunchMode.externalApplication);
                                return NavigationActionPolicy.CANCEL;
                              }
                            } else {
                              // block all external URL loading if deeplink is disabled
                              Fluttertoast.showToast(
                                msg: "External links are disabled",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                              );
                              return NavigationActionPolicy.CANCEL;
                            }
                          }
                          return NavigationActionPolicy.ALLOW;
                        },
                        onLoadStart: (controller, url) {
                          setState(() {
                            isLoading = true;
                            hasError = false;
                          });
                        },
                        onLoadStop: (controller, url) async {
                          setState(() => isLoading = false);
                        },
                        onLoadError: (controller, url, code, message) {
                          debugPrint('Load error [$code]: $message');
                          setState(() {
                            hasError = true;
                            isLoading = false;
                          });
                        },
                        onLoadHttpError:
                            (controller, url, statusCode, description) {
                          debugPrint('HTTP error [$statusCode]: $description');
                          setState(() {
                            hasError = true;
                            isLoading = false;
                          });
                        },
                        onConsoleMessage: (controller, consoleMessage) {
                          debugPrint('Console: ${consoleMessage.message}');
                        },
                      ),

                    // Loading Indicator
                    if (widget.isLoadIndicator && isLoading)
                      const Center(child: CircularProgressIndicator()),

                    // Error Screen
                    if (hasError)
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline,
                                size: 64, color: Colors.red),
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
                                  urlRequest:
                                      URLRequest(url: WebUri(widget.webUrl)),
                                );
                              },
                              child: const Text("Retry"),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          bottomNavigationBar: isBottomMenu
              ? BottomNavigationBar(
                  currentIndex: _currentIndex,
                  onTap: (index) {
                    setState(() => _currentIndex = index);
                    final item = widget.bottomMenuItems[index];
                    webViewController?.loadUrl(
                      urlRequest: URLRequest(url: WebUri(item['url'])),
                    );
                  },
                  backgroundColor: _parseHexColor(const String.fromEnvironment(
                      'BOTTOMMENU_BG_COLOR',
                      defaultValue: '#FFFFFF')),
                  selectedItemColor: _parseHexColor(
                      const String.fromEnvironment(
                          'BOTTOMMENU_ACTIVE_TAB_COLOR',
                          defaultValue: '#FF2D55')),
                  unselectedItemColor: _parseHexColor(
                      const String.fromEnvironment('BOTTOMMENU_ICON_COLOR',
                          defaultValue: '#888888')),
                  type: BottomNavigationBarType.fixed,
                  items: widget.bottomMenuItems.map((item) {
                    final isActive =
                        _currentIndex == widget.bottomMenuItems.indexOf(item);
                    return BottomNavigationBarItem(
                      icon: Icon(
                        _getIconByName(item['icon']),
                        color: isActive
                            ? _parseHexColor(const String.fromEnvironment(
                                'BOTTOMMENU_ACTIVE_TAB_COLOR',
                                defaultValue: '#FF2D55'))
                            : _parseHexColor(const String.fromEnvironment(
                                'BOTTOMMENU_ICON_COLOR',
                                defaultValue: '#888888')),
                      ),
                      label: item['label'],
                      activeIcon: Icon(
                        _getIconByName(item['icon']),
                        color: _parseHexColor(const String.fromEnvironment(
                            'BOTTOMMENU_ACTIVE_TAB_COLOR',
                            defaultValue: '#FF2D55')),
                      ),
                    );
                  }).toList(),
                )
              : null,
        ),
      ),
    );
  }
}
