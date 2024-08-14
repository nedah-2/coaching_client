import 'package:coaching_client/utils/show_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> launchURL(BuildContext context, String websiteUrl) async {
  final url = Uri.parse(websiteUrl);
  try {
    await launchUrl(url);
  } catch (e) {
    // Handle Error
    if (context.mounted) {
      showSnackBar(context, 'Something went wrong! Try again later...');
    }
    return;
  }
}
