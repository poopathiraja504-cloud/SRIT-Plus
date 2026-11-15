import 'dart:async';
import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

import '../services/activity_analytics_service.dart';

@JS('sritInstallPlatform')
external JSString _installPlatform();

@JS('sritIsStandalone')
external JSBoolean _isStandalone();

@JS('sritCanPromptInstall')
external JSBoolean _canPromptInstall();

@JS('sritWasInstallDismissed')
external JSBoolean _wasInstallDismissed();

@JS('sritDismissInstall')
external void _dismissInstall();

@JS('sritPromptInstall')
external JSPromise<JSString> _promptInstall();

class PlatformInstallBanner extends StatefulWidget {
  const PlatformInstallBanner({super.key});

  @override
  State<PlatformInstallBanner> createState() => _PlatformInstallBannerState();
}

class _PlatformInstallBannerState extends State<PlatformInstallBanner> {
  late final web.EventListener _stateChangeListener;
  String _platform = 'desktop';
  bool _isInstalled = false;
  bool _isDismissed = false;
  bool _canInstall = false;
  bool _isPrompting = false;
  bool _isAwaitingInstallConfirmation = false;

  @override
  void initState() {
    super.initState();
    _stateChangeListener = ((web.Event _) {
      if (mounted) setState(_readBrowserState);
    }).toJS;
    web.window.addEventListener(
      'srit-install-state-change',
      _stateChangeListener,
    );
    _readBrowserState();
  }

  @override
  void dispose() {
    web.window.removeEventListener(
      'srit-install-state-change',
      _stateChangeListener,
    );
    super.dispose();
  }

  void _readBrowserState() {
    _platform = _installPlatform().toDart;
    _isInstalled = _isStandalone().toDart;
    _isDismissed = _wasInstallDismissed().toDart;
    _canInstall = _canPromptInstall().toDart;
    if (_isInstalled) _isAwaitingInstallConfirmation = false;
  }

  void _dismiss() {
    unawaited(
      ActivityAnalyticsService.instance.logActivity(
        eventName: 'app_install_interaction',
        page: 'installation',
        feature: _platform == 'ios' || _platform == 'ios-tablet'
            ? 'ios_home_screen'
            : 'install_pwa',
      ),
    );
    _dismissInstall();
    setState(() => _isDismissed = true);
  }

  Future<void> _installOrExplain() async {
    unawaited(
      ActivityAnalyticsService.instance.logActivity(
        eventName: 'app_install_interaction',
        page: 'installation',
        feature: 'install_pwa',
      ),
    );
    if (_canInstall) {
      setState(() => _isPrompting = true);
      final outcome = (await _promptInstall().toDart).toDart;
      if (!mounted) return;
      setState(() {
        _isPrompting = false;
        _isAwaitingInstallConfirmation = outcome == 'accepted' && !_isInstalled;
        _canInstall = _canPromptInstall().toDart;
      });
      if (outcome == 'accepted' && !_isInstalled) {
        _showMessage(
          'Chrome accepted the request. Follow its confirmation to finish '
          'adding SRIT PORTAL.',
        );
      } else if (outcome == 'dismissed') {
        _showMessage('Installation was cancelled. No app was installed.');
      } else if (outcome == 'unavailable') {
        await _showAndroidUnavailableInstructions();
      } else if (outcome == 'error') {
        _showMessage(
          'Chrome could not open the installation prompt. Try the '
          'browser menu instead.',
        );
      }
      return;
    }

    await _showAndroidUnavailableInstructions();
  }

  Future<void> _showAndroidUnavailableInstructions() {
    return _showInstructions(
      title: 'Android installation prompt unavailable',
      steps: const [
        'Chrome has not provided the beforeinstallprompt event on this visit, '
            'so this button cannot open a native install prompt right now.',
        'The browser does not disclose a more specific reason. Check that you '
            'are using Chrome on Android, the site is open over HTTPS, and '
            'SRIT PORTAL is not already installed.',
        'You can still open Chrome’s menu (⋮), choose Install app or Add to '
            'Home screen, and follow the browser instructions if that option '
            'is available.',
      ],
    );
  }

  Future<void> _showIosInstructions() {
    unawaited(
      ActivityAnalyticsService.instance.logActivity(
        eventName: 'app_install_interaction',
        page: 'installation',
        feature: 'ios_home_screen',
      ),
    );
    return _showInstructions(
      title: 'Add SRIT PORTAL to your Home Screen',
      steps: const [
        'Open this page in Safari.',
        'Tap Share (the square with an upward arrow).',
        'Choose Add to Home Screen, then confirm Add.',
      ],
    );
  }

  Future<void> _showInstructions({
    required String title,
    required List<String> steps,
    String footer =
        'The browser adds the SRIT PORTAL website to your Home Screen; '
        'this does not install a separate native app.',
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var index = 0; index < steps.length; index++)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text('${index + 1}. ${steps[index]}'),
              ),
            Text(footer),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.maybeOf(
      context,
    )?.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    if (_isDismissed ||
        (_platform != 'android' &&
            _platform != 'ios' &&
            _platform != 'ios-tablet')) {
      return const SizedBox.shrink();
    }

    final isAndroid = _platform == 'android';
    final isIPad = _platform == 'ios-tablet';
    final isIos = !isAndroid;
    return SafeArea(
      bottom: false,
      child: Material(
        color: const Color(0xFFE8F5EF),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/srit_logo.png',
                  width: 46,
                  height: 46,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isAndroid
                          ? 'Install SRIT PORTAL Android App'
                          : isIPad
                          ? 'Install SRIT PORTAL on Your iPad'
                          : 'Install SRIT PORTAL on Your iPhone',
                      style: const TextStyle(
                        color: Color(0xFF004B39),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isAndroid
                          ? 'Install the SRIT PORTAL website as a PWA for quick '
                                'access. The native Android APK is available '
                                'separately below the sign-in form.'
                          : 'Access your college portal directly from your '
                                'Home Screen.',
                      style: const TextStyle(
                        color: Color(0xFF52665B),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                    if (isAndroid && !_isInstalled) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'Website PWA — installed to your Home Screen, not a '
                        'separate native APK.',
                        style: TextStyle(
                          color: Color(0xFF004B39),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    if (isAndroid && _isInstalled) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'SRIT PORTAL website is installed on this device.',
                        style: TextStyle(
                          color: Color(0xFF006B50),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        if (isAndroid && !_isInstalled)
                          FilledButton(
                            onPressed:
                                _isPrompting || _isAwaitingInstallConfirmation
                                ? null
                                : _installOrExplain,
                            child: Text(
                              _isPrompting
                                  ? 'Opening…'
                                  : _isAwaitingInstallConfirmation
                                  ? 'Confirming installation…'
                                  : 'Install Now',
                            ),
                          ),
                        if (isIos)
                          FilledButton(
                            onPressed: _showIosInstructions,
                            child: const Text('Add to Home Screen'),
                          ),
                        if (isIos)
                          TextButton(
                            onPressed: _showIosInstructions,
                            child: const Text('How to Install'),
                          ),
                        TextButton(
                          onPressed: _dismiss,
                          child: const Text('Not Now'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
