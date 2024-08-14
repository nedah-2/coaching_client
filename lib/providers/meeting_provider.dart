import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:coaching_client/models/meeting.dart';

class MeetingProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<DateTime> _meetingDays = [];
  List<Meeting> _meetings = [];
  bool _isLoading = true;
  StreamSubscription<QuerySnapshot>? _subscription;

  List<DateTime> get meetingDays => _meetingDays;
  List<Meeting> get meetings => _meetings;
  bool get isLoading => _isLoading;

  void listenToMeetings(String userId) {
    _subscription = _firestore
        .collection('students')
        .doc(userId)
        .collection('meetings')
        .where('dateTimeUtc',
            isGreaterThanOrEqualTo: DateTime.now().toIso8601String())
        .orderBy('dateTimeUtc')
        .snapshots()
        .listen((snapshot) {
      _meetings = snapshot.docs
          .map((doc) => Meeting.fromFirestore(doc.data(), doc.id))
          .toList();
      _meetingDays = _extractMeetingDays(_meetings);
      setLoading(false);
    });
  }

  List<DateTime> _extractMeetingDays(List<Meeting> meetings) {
    return meetings.map((meeting) => meeting.dateTimeUtc).toList();
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
