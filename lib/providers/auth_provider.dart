import 'dart:async';

import 'package:coaching_client/services/fcm_token_service.dart';
import 'package:coaching_client/widgets/dialogs/fake_loading.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuthManager extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FcmTokenService _fcm = FcmTokenService();
  User? _user;
  bool _isLoading = false;
  bool _isStudent = false;
  bool _isInitialized = false;
  StreamSubscription<DocumentSnapshot>? _studentDocSubscription;

  AuthManager() {
    _initAuth();
  }

  final List<String> imagePaths = [
    'assets/images/backgroud.jpg',
    'assets/images/checklist.png',
    'assets/images/calendar.png',
    // Add all your image paths here
  ];

  Future<void> _initAuth() async {
    _auth.authStateChanges().listen((User? user) async {
      _user = user;
      if (user != null) {
        await _checkStudentExist(user.uid);
      }
      await _preloadImages(); // Preload images here
      _isInitialized = true;
      notifyListeners();
    });

    _fcm.initialize();
  }

  Future<void> _preloadImages() async {
    for (String path in imagePaths) {
      await precacheImage(AssetImage(path), _preloadContext);
    }
  }

  // Provide a BuildContext for preloading images
  late BuildContext _preloadContext;

  void setPreloadContext(BuildContext context) {
    _preloadContext = context;
  }

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isStudent => _isStudent;
  bool get isInitialized => _isInitialized;

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      await Future.delayed(const Duration(seconds: 2));

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = userCredential.user;
      final id = _user!.uid;

      DocumentSnapshot userSnapshot =
          await _firestore.collection('students').doc(id).get();

      if (userSnapshot.exists) {
        await _fcm.onUserLogin(id);
      } else {
        throw Exception('No student found');
      }
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      await Future.delayed(const Duration(seconds: 2));
      if (_user == null) return;
      DocumentSnapshot userSnapshot =
          await _firestore.collection('students').doc(_user!.uid).get();
      if (userSnapshot.exists) await _fcm.onUserLogout(_user!.uid);
      await _auth.signOut();
      _user = null;
      _isStudent = false;
      _studentDocSubscription?.cancel();
    } catch (e) {
      debugPrint('Error signing out: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _checkStudentExist(String uid) async {
    try {
      _studentDocSubscription?.cancel();
      DocumentSnapshot userSnapshot =
          await _firestore.collection('students').doc(uid).get();
      if (userSnapshot.exists) {
        _isStudent = true;
        listenToStudentDoc(uid);
      } else {
        _isStudent = false;

        await signOut();
      }
    } catch (e) {
      debugPrint('Error checking student existence: $e');
      _isStudent = false;
      await signOut();
    } finally {
      notifyListeners();
    }
  }

  Future<void> listenToStudentDoc(String uid, {BuildContext? context}) async {
    _studentDocSubscription = _firestore
        .collection('students')
        .doc(uid)
        .snapshots()
        .listen((DocumentSnapshot snapshot) async {
      if (!snapshot.exists) {
        if (context != null) {
          await showLoadingDialog(context, signOut());
        }
        signOut();
      }
    });
  }
}
