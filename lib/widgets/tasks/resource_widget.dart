import 'package:coaching_client/models/task.dart';
import 'package:coaching_client/utils/format_minutes.dart';
import 'package:coaching_client/utils/launch_url.dart';
import 'package:flutter/material.dart';

class ResourceCard extends StatelessWidget {
  final Resource resource;
  const ResourceCard({super.key, required this.resource});

  static final Map<String, Icon> icons = {
    'article': Icon(Icons.article, color: Colors.blue.shade900),
    'video': Icon(Icons.video_file, color: Colors.blue.shade900),
    'podcast': Icon(Icons.podcasts, color: Colors.blue.shade900),
  };

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        onTap: () {
          launchURL(context, resource.link);
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        leading: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: const BorderRadius.all(Radius.circular(4)),
            ),
            child: icons[resource.type]),
        title: Text(
          resource.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(formatDurationFromTotalMinutes(resource.duration)),
        trailing: const Icon(Icons.open_in_new),
      ),
    );
  }
}
