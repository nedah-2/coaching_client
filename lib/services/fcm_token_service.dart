import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FcmTokenService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    try {
      String? token = await _messaging.getToken();
      if (token != null) {
        await _saveFcmTokenToFirestore(token);
      }
      _messaging.onTokenRefresh.listen((newToken) async {
        await _saveFcmTokenToFirestore(newToken);
      });
    } catch (e) {
      print('Error initializing FCM: $e');
    }
  }

  Future<void> _saveFcmTokenToFirestore(String token) async {
    try {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (userId.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('students')
            .doc(userId)
            .update({'fcmToken': token});
      }
    } catch (e) {
      print('Error saving FCM token: $e');
    }
  }

  Future<void> onUserLogin(String userId) async {
    try {
      String? token = await _messaging.getToken();
      if (token != null) {
        await FirebaseFirestore.instance
            .collection('students')
            .doc(userId)
            .update({'fcmToken': token});
      }
    } catch (e) {
      print('Error on user login: $e');
    }
  }

  Future<void> onUserLogout(String userId) async {
    try {
      await FirebaseFirestore.instance
          .collection('students')
          .doc(userId)
          .update({'fcmToken': FieldValue.delete()});
    } catch (e) {
      print('Error on user logout: $e');
    }
  }
}
