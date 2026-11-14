import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

const sritWebsite = 'https://www.sritcbe.ac.in/';
const sritCampusImage =
    'https://cdn.prod.website-files.com/69ba31e796b16c01f4b12199/'
    '69d8f02bc37234276b20bed7__J8A8766-Edit-2-Edit_resized.webp';

Future<void> openCampusLink(BuildContext context, Uri uri) async {
  final didLaunch = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!didLaunch && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not open this link on your device.')),
    );
  }
}
