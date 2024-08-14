import 'package:flutter/material.dart';

Future<void> showLaunchingZoom(
    BuildContext context, Future<void> launchZoom) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        content: const Row(
          children: [
            SizedBox(width: 28, height: 28, child: CircularProgressIndicator()),
            SizedBox(width: 24),
            Text("Launching Zoom..."),
          ],
        ),
      );
    },
  );

  // Delay for 2 seconds before closing the dialog
  await launchZoom;
}
