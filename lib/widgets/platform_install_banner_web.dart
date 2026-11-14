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
        if (outcome == 'accepted') _isInstalled = true;
        _canInstall = _canPromptInstall().toDart;
      });
      if (outcome == 'error') {
        _showMessage(
          'The browser could not open the installation prompt. Try the '
          'browser menu instead.',
        );
      }
      return;
    }

    await _showInstructions(
      title: 'Install SRIT Plus on Android',
      steps: const [
        'In Chrome, open the menu (⋮).',
        'Choose Install app or Add to Home screen.',
        'Confirm the browser prompt to add SRIT Plus.',
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
          padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/srit_logo.png',
                  width: 46,
                  height: 46,
                  fit: BoxFit.cover,
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
                          ? 'Official SRIT Plus App'
                          : isIPad
                          ? 'Install SRIT Plus on Your iPad'
                          : 'Install SRIT Plus on Your iPhone',
                      style: const TextStyle(
                        color: Color(0xFF123B72),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      isAndroid
                          ? 'Get the SRIT portal on Android. Explore academics, '
                                'campus information and available student '
                                'services.'
                          : 'Access your college portal directly from your '
                                'Home Screen.',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF52657D),
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        FilledButton(
                          onPressed: _isPrompting
                              ? null
                              : isAndroid
                              ? _installOrExplain
                              : _showIosInstructions,
                          child: Text(
                            isAndroid
                                ? _isPrompting
                                      ? 'Opening…'
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
