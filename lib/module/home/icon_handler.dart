import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class IconHandler {
  static IconData getIconByName(String? name) {
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

  static IconData? _getIconByExactName(String name) {
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

  static IconData? _findSimilarIcon(String name) {
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
}
