import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

const sritWebsite = 'https://www.sritcbe.ac.in/';

Future<void> openCampusLink(BuildContext context, Uri uri) async {
  final didLaunch = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!didLaunch && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not open this link on your device.')),
    );
  }
}
