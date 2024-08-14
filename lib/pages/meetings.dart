import 'package:coaching_client/widgets/meetings/calendar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Meetings extends StatelessWidget {
  final String id;
  const Meetings({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return MyCalendar(id: id);
  }
}
