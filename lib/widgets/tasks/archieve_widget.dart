import 'package:coaching_client/models/task.dart';
import 'package:coaching_client/pages/tasks/task_detail.dart';
import 'package:flutter/material.dart';

class ArchieveCard extends StatelessWidget {
  final Task task;
  const ArchieveCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.fromLTRB(6, 4, 4, 4),
      horizontalTitleGap: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TaskDetailPage(
              task: task,
              isArchieve: true,
            ),
          ),
        );
      },
      leading: !task.isDone
          ? IconButton(
              padding: EdgeInsets.zero,
              icon: Container(
                  width: 18,
                  height: 18,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(2)),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 18,
                  )),
              onPressed: null,
            )
          : Checkbox(
              activeColor: Colors.green,
              value: task.isDone,
              onChanged: null,
            ),
      title: Text(
        task.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
