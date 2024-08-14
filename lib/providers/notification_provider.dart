import 'package:coaching_client/services/notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService;
  int _currentIndex = 0;
  bool _isNotificationTapped = false;
  Map<String, dynamic> _notificationData = {};
  bool _hasUnreadTasksNotification = false;
  bool _hasUnreadMeetingsNotification = false;

  int get currentIndex => _currentIndex;
  bool get isNotificationTapped => _isNotificationTapped;
  Map<String, dynamic> get notificationData => _notificationData;
  bool get hasUnreadTasksNotification => _hasUnreadTasksNotification;
  bool get hasUnreadMeetingsNotification => _hasUnreadMeetingsNotification;

  NotificationProvider(this._notificationService) {
     _notificationService.setProvider(this);
    _loadUnreadNotifications();
    initializeNotifications();
  }

  void setTabIndex(int index) {
    _currentIndex = index;

    // Mark notifications as read when the tab is viewed
    if (index == 0) {
      _hasUnreadTasksNotification = false;
    } else if (index == 1) {
      _hasUnreadMeetingsNotification = false;
    }

    _saveUnreadNotifications();
    notifyListeners();
  }

  void setNotificationTapped(bool isTapped, [Map<String, dynamic>? data]) {
    _isNotificationTapped = isTapped;
    if (data != null) {
      _notificationData = data;
    }
    notifyListeners();
  }

  void initializeNotifications() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received a message while in foreground: ${message.messageId}');
      _notificationService.showNotification(
        message.notification?.title ?? '',
        message.notification?.body ?? '',
        message.data,
      );

      int tabIndex = int.parse(message.data['tabIndex'] ?? 0);

      print(tabIndex);

      // Update unread notifications count based on the tabIndex, only if not viewing the tab
      if (tabIndex == 1 && _currentIndex != 0) {
        _hasUnreadTasksNotification = true;
      } else if (tabIndex == 2 && _currentIndex != 1) {
        _hasUnreadMeetingsNotification = true;
      }

      notifyListeners();
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationTap(message.data);
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  void _handleNotificationTap(Map<String, dynamic> data) {
    int tabIndex = int.parse(data['tabIndex'] ?? 0);

    // Update unread notifications state based on the tabIndex
    if (tabIndex == 1 && _currentIndex != 1) {
      _hasUnreadTasksNotification = true;
    } else if (tabIndex == 2 && _currentIndex != 2) {
      _hasUnreadMeetingsNotification = true;
    }

    _saveUnreadNotifications();
    setNotificationTapped(true, data);
    setTabIndex(tabIndex - 1);
  }

  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    print('Handling a background message: ${message.messageId}');
    int tabIndex = int.parse(message.data['tabIndex'] ?? 0);

    // Use SharedPreferences to persist the unread state
    final prefs = await SharedPreferences.getInstance();
    if (tabIndex == 1) {
      prefs.setBool('hasUnreadTasksNotification', true);
    } else if (tabIndex == 2) {
      prefs.setBool('hasUnreadMeetingsNotification', true);
    }
  }

  Future<void> _loadUnreadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    _hasUnreadTasksNotification =
        prefs.getBool('hasUnreadTasksNotification') ?? false;
    _hasUnreadMeetingsNotification =
        prefs.getBool('hasUnreadMeetingsNotification') ?? false;
    notifyListeners();
  }

  Future<void> _saveUnreadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('hasUnreadTasksNotification', _hasUnreadTasksNotification);
    prefs.setBool(
        'hasUnreadMeetingsNotification', _hasUnreadMeetingsNotification);
  }
}
