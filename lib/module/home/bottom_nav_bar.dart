import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final List<Map<String, String>> menuItems;
  final Function(int) onTap;
  final Color backgroundColor;
  final Color selectedItemColor;
  final Color unselectedItemColor;
  final String fontFamily;
  final double fontSize;
  final FontWeight fontWeight;
  final bool isItalic;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.menuItems,
    required this.onTap,
    required this.backgroundColor,
    required this.selectedItemColor,
    required this.unselectedItemColor,
    required this.fontFamily,
    required this.fontSize,
    required this.fontWeight,
    required this.isItalic,
  });

  IconData _getIconByName(String? iconName) {
    switch (iconName?.toLowerCase()) {
      case 'home':
        return Icons.home;
      case 'services':
        return Icons.miscellaneous_services;
      case 'info':
        return Icons.info;
      case 'phone':
        return Icons.phone;
      case 'settings':
        return Icons.settings;
      case 'profile':
        return Icons.person;
      default:
        return Icons.web;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      backgroundColor: backgroundColor,
      selectedItemColor: selectedItemColor,
      unselectedItemColor: unselectedItemColor,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: TextStyle(
        fontFamily: fontFamily,
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: fontFamily,
        fontSize: fontSize,
        fontWeight: FontWeight.normal,
        fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
      ),
      items: menuItems.map((item) {
        final isActive = currentIndex == menuItems.indexOf(item);
        return BottomNavigationBarItem(
          icon: Icon(
            _getIconByName(item['icon']),
            color: isActive ? selectedItemColor : unselectedItemColor,
          ),
          label: item['label'],
          activeIcon: Icon(
            _getIconByName(item['icon']),
            color: selectedItemColor,
          ),
        );
      }).toList(),
    );
  }
}
