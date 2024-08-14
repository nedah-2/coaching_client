import 'package:coaching_client/models/task.dart';
import 'package:coaching_client/pages/tasks/task_detail.dart';
import 'package:coaching_client/providers/auth_provider.dart';
import 'package:coaching_client/providers/task_provider.dart';
import 'package:coaching_client/widgets/dialogs/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  const TaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Card(
      // elevation: 4,
      //shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      // surfaceTintColor: const Color(0x00f9f9f9),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(4, 8, 16, 8),
        horizontalTitleGap: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => TaskDetailPage(task: task)));
        },
        leading: Checkbox(
          activeColor: Colors.green,
          value: task.isDone,
          onChanged: (value) async {
            bool? isDone = await showDialog(
              context: context,
              builder: (BuildContext context) {
                return ConfirmDialog(
                  title: 'Mark as ${task.isDone ? 'Incomplete ' : 'Complete'}',
                  content:
                      'Do you want to mark this task as ${task.isDone ? 'incomplete ' : 'complete'}?',
                );
              },
            );
            print(isDone);
            if (isDone != null && isDone) {
              if (context.mounted) {
                String uid =
                    Provider.of<AuthManager>(context, listen: false).user!.uid;
                await Provider.of<TaskProvider>(context, listen: false)
                    .toggleTaskStatus(
                        uid, task.id!, task.isDone, task.deadline);
              }
            }
          },
        ),
        title: Text(
          task.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 16),
        ),
        trailing: Text(task.duration!),
      ),
    );
  }
}
