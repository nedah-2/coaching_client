import 'package:coaching_client/models/task.dart';
import 'package:coaching_client/providers/auth_provider.dart';
import 'package:coaching_client/providers/task_provider.dart';
import 'package:coaching_client/widgets/dialogs/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TaskToggleButton extends StatelessWidget {
  final Task task;

  const TaskToggleButton({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthManager, TaskProvider>(
      builder: (context, authManager, taskProvider, child) {
        return IconButton(
          onPressed: () async {
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
            if (isDone != null && isDone) {
              if (context.mounted) {
                String uid = authManager.user!.uid;
                await taskProvider.toggleTaskStatus(
                    uid, task.id!, task.isDone, task.deadline);
              }
            }
          },
          icon: task.isDone ? const Icon(Icons.undo) : const Icon(Icons.check),
        );
      },
    );
  }
}
