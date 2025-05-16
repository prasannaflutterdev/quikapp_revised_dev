import 'dart:convert';
import 'package:flutter/material.dart';
import 'bottom_menu_item.dart';

class BottomNavConfig {
  final bool isEnabled;
  final List<BottomMenuItem> menuItems;
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;
  final Color activeTabColor;
  final String iconPosition;
  final List<String> visibleOn;

  BottomNavConfig({
    required this.isEnabled,
    required this.menuItems,
    required this.backgroundColor,
    required this.iconColor,
    required this.textColor,
    required this.activeTabColor,
    required this.iconPosition,
    required this.visibleOn,
  });

  static Color _parseHexColor(String hexColor) {
    try {
      hexColor = hexColor.toUpperCase().replaceAll('#', '');
      if (hexColor.length == 6) {
        hexColor = 'FF$hexColor';
      }
      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      return Colors.white; // Default color
    }
  }

  factory BottomNavConfig.fromEnvironment() {
    final isEnabled =
        const String.fromEnvironment('IS_BOTTOMMENU', defaultValue: 'false') ==
            'true';
    final menuItemsJson =
        const String.fromEnvironment('BOTTOMMENU_ITEMS', defaultValue: '[]');
    final List<dynamic> menuItemsList = json.decode(menuItemsJson);

    return BottomNavConfig(
      isEnabled: isEnabled,
      menuItems:
          menuItemsList.map((item) => BottomMenuItem.fromJson(item)).toList(),
      backgroundColor: _parseHexColor(const String.fromEnvironment(
          'BOTTOMMENU_BG_COLOR',
          defaultValue: '#FFFFFF')),
      iconColor: _parseHexColor(const String.fromEnvironment(
          'BOTTOMMENU_ICON_COLOR',
          defaultValue: '#888888')),
      textColor: _parseHexColor(const String.fromEnvironment(
          'BOTTOMMENU_TEXT_COLOR',
          defaultValue: '#000000')),
      activeTabColor: _parseHexColor(const String.fromEnvironment(
          'BOTTOMMENU_ACTIVE_TAB_COLOR',
          defaultValue: '#FF2D55')),
      iconPosition: const String.fromEnvironment('BOTTOMMENU_ICON_POSITION',
          defaultValue: 'above'),
      visibleOn: const String.fromEnvironment('BOTTOMMENU_VISIBLE_ON',
              defaultValue: '')
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
    );
  }

  bool isVisibleOnPage(String page) {
    return visibleOn.isEmpty || visibleOn.contains(page.toLowerCase());
  }
}
