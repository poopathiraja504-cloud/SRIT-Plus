import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web/web.dart' as web;

import '../services/campus_links.dart';

class WebsiteScreen extends StatefulWidget {
  const WebsiteScreen({super.key});

  @override
  State<WebsiteScreen> createState() => _WebsiteScreenWebState();
}

class _WebsiteScreenWebState extends State<WebsiteScreen> {
  late final String _viewType;
  late final web.HTMLIFrameElement _frame;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _viewType = 'srit-website-${identityHashCode(this)}';
    _frame = web.HTMLIFrameElement()
      ..src = sritWebsite
      ..title = 'Sri Ramakrishna Institute of Technology website'
      ..referrerPolicy = 'strict-origin-when-cross-origin'
      ..allowFullscreen = true
      ..style.border = '0'
      ..style.width = '100%'
      ..style.height = '100%';
    _frame.onLoad.listen((_) {
      if (mounted) setState(() => _isLoading = false);
    });
    ui_web.platformViewRegistry.registerViewFactory(
      _viewType,
      (int _) => _frame,
    );
  }

  void _refresh() {
    setState(() => _isLoading = true);
    _frame.src = sritWebsite;
  }

  Future<void> _openInBrowser() async {
    final didLaunch = await launchUrl(
      Uri.parse(sritWebsite),
      mode: LaunchMode.externalApplication,
    );
    if (!didLaunch && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the SRIT website.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back to SRIT PORTAL',
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text(
          'SRIT Website',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh website',
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
          IconButton(
            tooltip: 'Open in browser',
            onPressed: _openInBrowser,
            icon: const Icon(Icons.open_in_browser_rounded),
          ),
        ],
      ),
      body: Stack(
        children: [
          HtmlElementView(viewType: _viewType),
          if (_isLoading)
            const Align(
              alignment: Alignment.topCenter,
              child: LinearProgressIndicator(minHeight: 2),
            ),
          const Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: IgnorePointer(
              child: Align(
                alignment: Alignment.bottomRight,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Color(0xDD123B72),
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Text(
                      'Use the browser button if this site blocks embedding.',
                      style: TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
