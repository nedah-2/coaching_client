import 'package:coaching_client/models/meeting.dart';
import 'package:coaching_client/utils/format_date_time.dart';
import 'package:coaching_client/utils/launch_url.dart';
import 'package:coaching_client/utils/show_snackbar.dart';
import 'package:coaching_client/widgets/dialogs/launching_zoom.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MeetingCard extends StatelessWidget {
  final Meeting meeting;
  const MeetingCard({super.key, required this.meeting});

  bool _isWithinOneHour(DateTime dateTimeUtc) {
    final now = DateTime.now().toUtc();
    final difference = dateTimeUtc.difference(now).inMinutes;
    return difference >= 0 && difference <= 60;
  }

  Future<void> _launchZoom(BuildContext context) async {
    final zoomUrl =
        'https://us05web.zoom.us/j/${meeting.mid}?pwd=${meeting.passcode}';
    try {
      await launchURL(context, zoomUrl);
      await Future.delayed(const Duration(seconds: 6));
    } catch (e) {
      print(e);
    }
    // if (await canLaunchUrl(zoomUrl)) {
    //   await launchUrl(zoomUrl);
    // } else {
    //   // Handle the error or fallback
    //   final fallbackUrl =
    //       Uri.parse('https://zoom.us/j/${meeting.mid}?pwd=${meeting.passcode}');
    //   if (await canLaunchUrl(fallbackUrl)) {
    //     await launchUrl(fallbackUrl);
    //   } else {
    //     throw 'Could not launch Zoom';
    //   }
    // }
  }

  void _showMeetingDialog(BuildContext context, bool isEnabled) {
    showDialog(
      context: context,
      builder: (BuildContext contex) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          insetPadding: const EdgeInsets.all(24),
          titlePadding: const EdgeInsets.fromLTRB(24, 44, 24, 16),
          contentPadding: const EdgeInsets.only(left: 24, right: 16),
          actionsPadding: isEnabled
              ? const EdgeInsets.fromLTRB(24, 16, 24, 40)
              : const EdgeInsets.only(bottom: 48),
          title: const Text("Meeting id and passcode",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _buildCopyableRow(
                    context, Icons.meeting_room_rounded, meeting.mid),
                const SizedBox(height: 8),
                _buildCopyableRow(context, Icons.password, meeting.passcode),
              ],
            ),
          ),
          actions: <Widget>[
            SizedBox(
              width: double.infinity,
              child: isEnabled
                  ? ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade900,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                      onPressed: () async {
                        Navigator.of(contex).pop(true);
                        await showLaunchingZoom(contex, _launchZoom(context));
                        if (context.mounted) Navigator.pop(context);
                      },
                      child: const Text(
                        "Join Now",
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  : null,
            ),
          ],
        );
      },
    );
  }

  Widget _buildCopyableRow(BuildContext context, IconData icon, String value) {
    return SizedBox(
      height: 40,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: Colors.black87),
          const SizedBox(width: 12),
          SelectableText(value, style: TextStyle(color: Colors.blue[900])),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.copy, size: 16),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              Navigator.of(context, rootNavigator: true).pop();
              showSnackBar(context, 'Copied to clipboard');
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWithinOneHour = _isWithinOneHour(meeting.dateTimeUtc);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: isWithinOneHour
            ? BorderSide(color: Colors.blue.shade900, width: 2)
            : BorderSide.none,
      ),
      elevation: 6.0,
      shadowColor: Colors.black54,
      child: ListTile(
        onTap: () => _showMeetingDialog(context, isWithinOneHour),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        title: Text(
          "${formattedDate(meeting.getLocalDateTime())} at ${formattedTime(meeting.getLocalTimeOfDay())}",
          style: TextStyle(
              fontWeight: FontWeight.normal,
              color: Colors.blue[900],
              fontSize: 15),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2.0),
          child: Text(
            meeting.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
        ),
        trailing: const Icon(Icons.open_in_new, size: 22),
      ),
    );
  }
}
