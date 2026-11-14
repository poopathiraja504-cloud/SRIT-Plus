import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

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
    _dismissInstall();
    setState(() => _isDismissed = true);
  }

  Future<void> _installOrExplain() async {
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
          'adding SRIT Plus.',
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
            'SRIT Plus is not already installed.',
        'You can still open Chrome’s menu (⋮), choose Install app or Add to '
            'Home screen, and follow the browser instructions if that option '
            'is available.',
      ],
    );
  }

  Future<void> _showIosInstructions() {
    return _showInstructions(
      title: 'Add SRIT Plus to your Home Screen',
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
            const Text(
              'The browser adds the SRIT Plus website to your Home Screen; '
              'this does not install a separate native app.',
            ),
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
    if (_isInstalled ||
        _isDismissed ||
        (_platform != 'android' &&
            _platform != 'ios' &&
            _platform != 'ios-tablet')) {
      return const SizedBox.shrink();
    }

    final isAndroid = _platform == 'android';
    final isIPad = _platform == 'ios-tablet';
    return SafeArea(
      bottom: false,
      child: Material(
        color: const Color(0xFFEAF2FF),
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
                          ? 'SRIT Plus — Official College App'
                          : isIPad
                          ? 'Install SRIT Plus on Your iPad'
                          : 'Install SRIT Plus on Your iPhone',
                      style: const TextStyle(
                        color: Color(0xFF123B72),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isAndroid
                          ? 'Get quick access to: Attendance • Internal Marks • '
                                'Semester Results • Timetable • Academics • '
                                'College Announcements • Student Profile'
                          : 'Access your college portal directly from your '
                                'Home Screen.',
                      style: const TextStyle(
                        color: Color(0xFF52657D),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                    if (isAndroid) ...[
                      const SizedBox(height: 4),
                      const Text(
                        'Install Website as PWA. No native Android APK is '
                        'currently published.',
                        style: TextStyle(
                          color: Color(0xFF52657D),
                          fontSize: 11,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        FilledButton(
                          onPressed:
                              _isPrompting || _isAwaitingInstallConfirmation
                              ? null
                              : isAndroid
                              ? _installOrExplain
                              : _showIosInstructions,
                          child: Text(
                            isAndroid
                                ? _isPrompting
                                      ? 'Opening…'
                                      : _isAwaitingInstallConfirmation
                                      ? 'Confirming installation…'
                                      : 'Install App'
                                : 'Add to Home Screen',
                          ),
                        ),
                        if (!isAndroid)
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
