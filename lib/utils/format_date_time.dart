import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String formattedDate(DateTime date) {
  return DateFormat('MMM dd, yyyy').format(date);
}

String formattedTime(TimeOfDay? time) {
  if (time == null) return 'Not Set';
  final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
  final period = time.period == DayPeriod.am ? 'AM' : 'PM';
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute $period';
}
