import 'package:coaching_client/models/task.dart';
import 'package:coaching_client/utils/format_date_time.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coaching_client/providers/task_provider.dart';
import 'package:coaching_client/widgets/tasks/task_widget.dart';

class Tasks extends StatefulWidget {
  final String userId;

  const Tasks({super.key, required this.userId});

  @override
  State<Tasks> createState() => _TasksState();
}

class _TasksState extends State<Tasks> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Add scroll listener for pagination
    _scrollController.addListener(() {
      if (_scrollController.position.atEdge) {
        if (_scrollController.position.pixels != 0) {
          Provider.of<TaskProvider>(context, listen: false)
              .loadMoreTasks(widget.userId);
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<void>(
      stream: Provider.of<TaskProvider>(context, listen: false)
          .listenToTasks(widget.userId),
      builder: (context, snapshot) {
        // if (snapshot.connectionState == ConnectionState.waiting) {
        //   return const Center(child: Text('Loading...'));
        // }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return Consumer<TaskProvider>(
            builder: (context, taskProvider, child) {
              if (!taskProvider.isInitialized) {
                return const Center(child: Text('Loading...'));
              }
              if (taskProvider.tasksByDeadline.isEmpty) {
                return Center(
                  child: Container(
                      margin: const EdgeInsets.only(bottom: 40),
                      width: 320,
                      height: 320,
                      child: ColorFiltered(
                          colorFilter: const ColorFilter.mode(
                            Color.fromRGBO(128, 205, 237, 0.8),
                            BlendMode.srcIn,
                          ),
                          child: Image.asset('assets/images/checklist.png'))),
                );
              }

              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.only(bottom: 24, top: 8),
                itemCount: taskProvider.tasksByDeadline.length +
                    (taskProvider.isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == taskProvider.tasksByDeadline.length) {
                    return const Center(
                        child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 3),
                    ));
                  }

                  String deadline =
                      taskProvider.tasksByDeadline.keys.elementAt(index);
                  List<Task> tasks = taskProvider.tasksByDeadline[deadline]!;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Text(
                            'Deadline: ${formattedDate(DateTime.parse(deadline))}',
                            style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.italic),
                          ),
                        ),
                        ...tasks.map((task) {
                          return TaskCard(task: task);
                        }),
                      ],
                    ),
                  );
                },
              );
            },
          );
        }
      },
    );
  }
}
