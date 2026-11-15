import 'package:flutter/material.dart';

import '../services/activity_analytics_service.dart';

class AnalyticsConsentBanner extends StatelessWidget {
  const AnalyticsConsentBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool?>(
      valueListenable: ActivityAnalyticsService.instance.consent,
      builder: (context, consent, _) {
        if (consent != null) return const SizedBox.shrink();
        return Material(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.privacy_tip_outlined),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Optional usage analytics help improve SRIT PORTAL. '
                          'They record feature use, not passwords or tokens.',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Wrap(
                      spacing: 8,
                      children: [
                        TextButton(
                          onPressed: () => _saveConsent(context, false),
                          child: const Text('Not now'),
                        ),
                        FilledButton(
                          onPressed: () => _saveConsent(context, true),
                          child: const Text('Allow'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Future<void> _saveConsent(
    BuildContext context,
    bool enabled,
  ) async {
    try {
      await ActivityAnalyticsService.instance.setConsent(enabled);
    } catch (error, stackTrace) {
      debugPrint('Could not save analytics preference: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (context.mounted) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          const SnackBar(
            content: Text(
              'Your analytics preference could not be saved. Please try again.',
            ),
          ),
        );
      }
    }
  }
}

Future<void> showAnalyticsConsentDialog(BuildContext context) {
  final service = ActivityAnalyticsService.instance;
  final enabled = service.isEnabled;
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Usage analytics preferences'),
      content: Text(
        'Optional analytics are currently ${enabled ? 'enabled' : 'disabled'}. '
        'When enabled, SRIT PORTAL records sign-in outcomes and feature visits. '
        'Passwords and authentication tokens are never recorded.',
      ),
      actions: [
        TextButton(
          onPressed: () => _updateDialogConsent(dialogContext, service, false),
          child: const Text('Disable'),
        ),
        FilledButton(
          onPressed: () => _updateDialogConsent(dialogContext, service, true),
          child: const Text('Allow'),
        ),
      ],
    ),
  );
}

Future<void> _updateDialogConsent(
  BuildContext context,
  ActivityAnalyticsService service,
  bool enabled,
) async {
  try {
    await service.setConsent(enabled);
    if (context.mounted) Navigator.of(context).pop();
  } catch (error, stackTrace) {
    debugPrint('Could not update analytics preference: $error');
    debugPrintStack(stackTrace: stackTrace);
    if (context.mounted) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(
          content: Text(
            'Your analytics preference could not be saved. Please try again.',
          ),
        ),
      );
    }
  }
}
