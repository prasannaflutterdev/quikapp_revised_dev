import 'package:flutter/material.dart';

class BottomMenuItem {
  final String label;
  final String icon;
  final String url;
  final IconData? iconData;

  BottomMenuItem({
    required this.label,
    required this.icon,
    required this.url,
    this.iconData,
  });

  factory BottomMenuItem.fromJson(Map<String, dynamic> json) {
    return BottomMenuItem(
      label: json['label'] ?? '',
      icon: json['icon'] ?? '',
      url: json['url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'icon': icon,
      'url': url,
    };
  }
}
