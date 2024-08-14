import 'package:coaching_client/models/meeting.dart';
import 'package:coaching_client/providers/meeting_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:coaching_client/widgets/meetings/meeting_widget.dart';
import 'package:provider/provider.dart';

class MyCalendar extends StatefulWidget {
  final String id;
  const MyCalendar({super.key, required this.id});

  @override
  State<MyCalendar> createState() => _MyCalendarState();
}

class _MyCalendarState extends State<MyCalendar> {
  int currentMonthIndex = 0;

  @override
  void initState() {
    super.initState();

    Provider.of<MeetingProvider>(context, listen: false)
        .listenToMeetings(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MeetingProvider>(
      builder: (context, meetingProvider, child) {
        if (meetingProvider.isLoading) {
          return const Center(child: Text('Loading...'));
        }

        if (meetingProvider.meetings.isEmpty) {
          return Center(
            child: Container(
              margin: const EdgeInsets.only(bottom: 32),
              width: 264,
              height: 264,
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      opacity: 0.8,
                      image: AssetImage('assets/images/calendar.png'))),
            ),
          );
        }

        List<DateTime> meetingDates = meetingProvider.meetingDays;

        DateTime currentMonth =
            uniqueMeetingMonths(meetingDates)[currentMonthIndex];

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: currentMonthIndex > 0
                          ? () {
                              setState(() {
                                currentMonthIndex--;
                              });
                            }
                          : null,
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Text(
                      DateFormat('MMMM').format(currentMonth),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      onPressed: currentMonthIndex <
                              uniqueMeetingMonths(meetingDates).length - 1
                          ? () {
                              setState(() {
                                currentMonthIndex++;
                              });
                            }
                          : null,
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              ),
              _buildCalendar(currentMonth, meetingDates),
              const SizedBox(height: 24),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: meetingProvider.meetings.length,
                itemBuilder: (context, index) {
                  Meeting meeting = meetingProvider.meetings[index];
                  return MeetingCard(meeting: meeting);
                },
                separatorBuilder: (BuildContext context, int index) {
                  return const SizedBox(height: 8);
                },
              ),
            ],
          ),
        );
      },
    );
  }

// Helper method to build the calendar
  Widget _buildCalendar(DateTime month, List<DateTime> meetingDates) {
    int year = month.year;
    int monthNumber = month.month;
    DateTime firstDayOfMonth = DateTime(year, monthNumber, 1);
    DateTime lastDayOfMonth = (monthNumber < 12)
        ? DateTime(year, monthNumber + 1, 0)
        : DateTime(year + 1, 1, 0);

    int numberOfDays = lastDayOfMonth.day;
    int startingWeekday = firstDayOfMonth.weekday % 7;

    List<TableRow> calendarRows = [];

    calendarRows.add(
      TableRow(
        children: List.generate(
          7,
          (index) => Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                getAbbreviatedDayName(index), // Adjust day order
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );

    for (int i = 0; i < 6; i++) {
      List<Widget> weekWidgets = [];

      for (int j = 1; j <= 7; j++) {
        int dayValue = i * 7 + j - startingWeekday;

        if (dayValue > 0 && dayValue <= numberOfDays) {
          bool isMeetingDate = meetingDates.any(
              (date) => isSameDay(date, DateTime(year, monthNumber, dayValue)));
          weekWidgets.add(
            GestureDetector(
              onTap: () {},
              child: Stack(
                children: [
                  Container(
                    margin: const EdgeInsets.all(4),
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isMeetingDate
                          ? Colors.blue.shade900
                          : Colors.transparent,
                    ),
                    child: Text(
                      '$dayValue',
                      style: TextStyle(
                        color: isMeetingDate ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          weekWidgets.add(Container());
        }
      }

      calendarRows.add(TableRow(children: weekWidgets));
    }

    List<Widget> first = calendarRows[1].children;

    if ((first[4] is! GestureDetector || first[5] is! GestureDetector)) {
      List<Widget> first = calendarRows.removeAt(1).children;
      List<Widget> last = calendarRows.removeLast().children;

      for (int i = 0; i < first.length; i++) {
        if (last[i] is GestureDetector) {
          first[i] = last[i];
        }
      }
      calendarRows.insert(1, TableRow(children: first));
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 800),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      child: Table(
        children: calendarRows,
      ),
    );
  }

  List<DateTime> uniqueMeetingMonths(List<DateTime> meetingDates) {
    return meetingDates
        .map((date) => DateTime(date.year, date.month))
        .toSet()
        .toList()
      ..sort((a, b) => a.compareTo(b));
  }

  bool isSameMonth(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month;
  }

  String getAbbreviatedDayName(int day) {
    switch (day) {
      case 0:
        return 'Sun';
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      default:
        return '';
    }
  }

  bool isSameDay(DateTime date, DateTime day) {
    return date.year == day.year &&
        date.month == day.month &&
        date.day == day.day;
  }
}
