import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

const String kAndroidApkPath = '/downloads/app-release.apk';
const String kAndroidApkFileName = 'SRIT-Plus-1.0.0.apk';
const String kAndroidApkVersion = '1.0.0';
const String kAndroidApkSize = '49.4 MB';
const String kAndroidPackageName = 'com.srit.app';

void triggerAndroidApkDownload() {
  final body = web.document.body;
  if (body == null) return;
  final anchor = web.HTMLAnchorElement()
    ..href = kAndroidApkPath
    ..download = kAndroidApkFileName
    ..style.display = 'none';
  body.append(anchor);
  try {
    anchor.click();
  } finally {
    anchor.remove();
  }
}

Future<void> showAndroidApkInstallInstructions(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/images/srit_logo.png',
              width: 34,
              height: 34,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Install SRIT Plus Android App',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Follow these simple steps on your Android device to install the official native app:',
              style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
            ),
            const SizedBox(height: 16),
            _instructionStep(
              stepNumber: '1',
              title: 'Download the APK',
              description:
                  'Click "Download Android App" to save $kAndroidApkFileName ($kAndroidApkSize).',
            ),
            _instructionStep(
              stepNumber: '2',
              title: 'Open Downloaded File',
              description:
                  'When the download completes, tap the notification in your notification tray or find the file in your phone\'s Files/Downloads app.',
            ),
            _instructionStep(
              stepNumber: '3',
              title: 'Allow Unknown Apps (if asked)',
              description:
                  'If Android displays "For your security, your phone is not allowed to install unknown apps", tap Settings and switch on "Allow from this source".',
            ),
            _instructionStep(
              stepNumber: '4',
              title: 'Complete Installation',
              description:
                  'Tap "Install". Once finished, tap "Open" to launch SRIT Plus.',
            ),
            const Divider(height: 24),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.verified, color: Color(0xFF0F766E), size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Official Android Package: $kAndroidPackageName\nVersion: $kAndroidApkVersion • Size: $kAndroidApkSize',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF334155),
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        FilledButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
            triggerAndroidApkDownload();
          },
          icon: const Icon(Icons.download, size: 18),
          label: const Text('Download APK Now'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

Widget _instructionStep({
  required String stepNumber,
  required String title,
  required String description,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Color(0xFF1E5BB1),
            shape: BoxShape.circle,
          ),
          child: Text(
            stepNumber,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

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
    final bgColor = darkTheme
        ? const Color(0xFF0F2B52).withValues(alpha: 0.92)
        : Colors.white;
    final borderColor = darkTheme
        ? const Color(0xFF2A5082)
        : const Color(0xFFDCE6F3);
    final titleColor = darkTheme ? Colors.white : const Color(0xFF123B72);
    final subtitleColor = darkTheme
        ? const Color(0xFFD2E1F5)
        : const Color(0xFF52657D);
    final metaColor = darkTheme
        ? const Color(0xFFFFDA82)
        : const Color(0xFF0F766E);

    return Container(
      padding: EdgeInsets.all(compact ? 12 : 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: darkTheme ? 0.25 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/images/srit_logo.png',
                  width: compact ? 36 : 44,
                  height: compact ? 36 : 44,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SRIT Plus',
                      style: TextStyle(
                        color: titleColor,
                        fontWeight: FontWeight.w800,
                        fontSize: compact ? 15 : 17,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Official Native Android Application',
                      style: TextStyle(
                        color: subtitleColor,
                        fontSize: compact ? 11 : 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: darkTheme
                  ? const Color(0xFF173868)
                  : const Color(0xFFF1F6FD),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.android,
                  size: 16,
                  color: metaColor,
                ),
                const SizedBox(width: 6),
                Text(
                  'v$kAndroidApkVersion  •  $kAndroidApkSize  •  Native APK',
                  style: TextStyle(
                    color: metaColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: triggerAndroidApkDownload,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF0F766E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.download, size: 18),
                label: const Text(
                  'Download Android App',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              TextButton.icon(
                onPressed: () => showAndroidApkInstallInstructions(context),
                style: TextButton.styleFrom(
                  foregroundColor: darkTheme
                      ? const Color(0xFFFFDA82)
                      : const Color(0xFF1E5BB1),
                ),
                icon: const Icon(Icons.help_outline, size: 16),
                label: const Text('Install instructions'),
              ),
            ],
          ),
        ],
      ),
    );
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
    return FilledButton.icon(
      onPressed: triggerAndroidApkDownload,
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF0F766E),
        foregroundColor: Colors.white,
      ),
      icon: const Icon(Icons.download, size: 18),
      label: Text(label),
    );
  }
}
