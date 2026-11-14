import 'package:flutter/material.dart';

import 'campus_pages.dart';

class WebPortalShell extends StatelessWidget {
  const WebPortalShell({
    required this.homeBuilder,
    required this.onSignOut,
    required this.onEnableNotifications,
    this.initialSection,
    super.key,
  });

  final Widget Function(ValueChanged<CampusSection> onSelectSection)
  homeBuilder;
  final Future<void> Function() onSignOut;
  final Future<void> Function() onEnableNotifications;
  final CampusSection? initialSection;

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
