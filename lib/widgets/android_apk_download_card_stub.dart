import 'package:flutter/material.dart';

bool get isIosBrowser => false;

class AndroidApkDownloadCard extends StatelessWidget {
  const AndroidApkDownloadCard({
    this.compact = false,
    this.darkTheme = false,
    super.key,
  });

  final bool compact;
  final bool darkTheme;

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class AndroidApkDownloadButton extends StatelessWidget {
  const AndroidApkDownloadButton({
    this.label = 'Download Android App',
    super.key,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

Future<void> showAndroidApkInstallInstructions(BuildContext context) async {}
void triggerAndroidApkDownload() {}
