import 'package:flutter/material.dart';

class Meeting {
  String? id; // Nullable, obtained from document id
  String title;
  DateTime dateTimeUtc; // Combined date and time in UTC
  String? sid; // Nullable Student ID
  String? student; // Nullable Student name
  String mid; // Meeting ID
  String passcode;

  Meeting({
    this.id,
    required this.title,
    required this.dateTimeUtc,
    this.sid,
    this.student,
    required this.mid,
    required this.passcode,
  });

  // Convert Firestore snapshot to Meeting object
  factory Meeting.fromFirestore(Map<String, dynamic> json, String documentId) {
    return Meeting(
      id: documentId,
      title: json['title'],
      dateTimeUtc: DateTime.parse(json['dateTimeUtc']).toUtc(),
      sid: json['sid'],
      student: json['student'],
      mid: json['mid'],
      passcode: json['passcode'],
    );
  }

  // Convert Meeting object to Firestore compatible format
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'dateTimeUtc': dateTimeUtc
          .toUtc()
          .toIso8601String(), // Convert DateTime to ISO 8601 string in UTC
      'sid': sid,
      'student': student,
      'mid': mid,
      'passcode': passcode,
    };
  }

  // Helper method to get local date and time
  DateTime getLocalDateTime() {
    return dateTimeUtc.toLocal();
  }

  // Helper method to get local time of day
  TimeOfDay getLocalTimeOfDay() {
    final localDateTime = dateTimeUtc.toLocal();
    return TimeOfDay(hour: localDateTime.hour, minute: localDateTime.minute);
  }
}
