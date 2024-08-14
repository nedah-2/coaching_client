import 'package:coaching_client/pages/tasks/archieve_tasks.dart';
import 'package:coaching_client/providers/auth_provider.dart';
import 'package:coaching_client/providers/notification_provider.dart';
import 'package:coaching_client/providers/task_provider.dart';
import 'package:coaching_client/widgets/dialogs/fake_loading.dart';
import 'package:coaching_client/pages/meetings.dart';
import 'package:coaching_client/pages/tasks/tasks.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  final String uid;
  const HomePage({super.key, required this.uid});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    _setupAuthListener();
    _setupNotiListener();
  }

  void _setupAuthListener() {
    final authManager = Provider.of<AuthManager>(context, listen: false);
    authManager.listenToStudentDoc(widget.uid, context: context);
  }

  void _setupNotiListener() {
    final notificationProvider =
        Provider.of<NotificationProvider>(context, listen: false);
    notificationProvider.initializeNotifications();
  }

  // void _onItemTapped(int index) {
  //   setState(() {
  //     _selectedIndex = index;
  //   });
  // }

  Future<void> signOut() async {
    await Provider.of<AuthManager>(context, listen: false).signOut();
    if (mounted) {
      Provider.of<TaskProvider>(context, listen: false).setInitialized(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notificationProvider =
        Provider.of<NotificationProvider>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lifestyle Coach',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            OldTasksPage(studentId: widget.uid)));
              },
              icon: const Icon(Icons.checklist, size: 28)),
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: IconButton(
                onPressed: () async {
                  await showLoadingDialog(
                      context,
                      Provider.of<AuthManager>(context, listen: false)
                          .signOut());
                  // if (context.mounted) {
                  //   await Provider.of<AuthManager>(context, listen: false)
                  //       .signOut();
                  // }
                },
                icon: const Icon(Icons.logout)),
          ),
        ],
      ),
      body: notificationProvider.currentIndex == 0
          ? Tasks(userId: widget.uid)
          : Meetings(
              id: widget.uid,
            ),
      bottomNavigationBar: BottomNavigationBar(
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.assignment),
                if (notificationProvider.hasUnreadTasksNotification)
                  Positioned(
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: const Text(
                        '!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.meeting_room),
                if (notificationProvider.hasUnreadMeetingsNotification)
                  Positioned(
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: const Text(
                        '!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Meetings',
          ),
          // BottomNavigationBarItem(
          //   icon: Padding(
          //     padding: EdgeInsets.all(4.0),
          //     child: Icon(Icons.assignment),
          //   ),
          //   label: 'Tasks',
          // ),
          // BottomNavigationBarItem(
          //   icon: Padding(
          //     padding: EdgeInsets.all(4.0),
          //     child: Icon(Icons.calendar_month),
          //   ),
          //   label: 'Meetings',
          // ),
        ],
        currentIndex: notificationProvider.currentIndex,
        selectedItemColor: Colors.blue.shade900,
        onTap: notificationProvider.setTabIndex,
      ),
    );
  }
}
