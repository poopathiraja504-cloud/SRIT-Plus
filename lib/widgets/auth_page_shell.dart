import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'brand_mark.dart';

class AuthPageShell extends StatelessWidget {
  const AuthPageShell({
    required this.title,
    required this.subtitle,
    required this.child,
    super.key,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              if (!kIsWeb) {
                return Image.asset(
                  'assets/images/srit_campus_background.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                      const ColoredBox(color: Color(0xFF123B72)),
                );
              }

              final sourceWidth =
                  constraints.maxWidth * MediaQuery.devicePixelRatioOf(context);
              final imageVariant = switch (sourceWidth) {
                <= 1600 => '-p-1600.webp',
                <= 3200 => '-p-3200.webp',
                _ => '.webp',
              };
              final imageUrl =
                  'https://cdn.prod.website-files.com/69ba31e796b16c01f4b12199/'
                  '69d8ee3042adfe8a6271fa19_1L1A9569-Edit_resized$imageVariant';

              return Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) => progress == null
                    ? child
                    : const ColoredBox(color: Color(0xFF123B72)),
                errorBuilder: (_, _, _) => Image.asset(
                  'assets/images/srit_campus_background.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                      const ColoredBox(color: Color(0xFF123B72)),
                ),
              );
            },
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xCC06172B),
                  Color(0xA6123152),
                  Color(0xE6091728),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final content = _AuthContent(
                  title: title,
                  subtitle: subtitle,
                  child: child,
                );
                if (!kIsWeb || constraints.maxWidth < 900) {
                  return Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 24,
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 460),
                        child: content,
                      ),
                    ),
                  );
                }

                final panelWidth = (constraints.maxWidth * 0.4)
                    .clamp(420.0, 480.0)
                    .toDouble();
                final rightInset = (constraints.maxWidth * 0.055)
                    .clamp(32.0, 88.0)
                    .toDouble();
                return Align(
                  alignment: Alignment.centerRight,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(24, 24, rightInset, 24),
                    child: SizedBox(width: panelWidth, child: content),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthContent extends StatelessWidget {
  const _AuthContent({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Center(child: BrandMark(size: 78)),
        const SizedBox(height: 18),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white.withValues(alpha: 0.86),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 26),
        ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 28,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: child,
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'SRI RAMAKRISHNA INSTITUTE OF TECHNOLOGY',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: const Color(0xFFFFD978),
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }
}
