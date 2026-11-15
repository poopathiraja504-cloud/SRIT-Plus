import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'android_apk_download_card.dart';
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (kIsWeb && constraints.maxWidth >= 900) {
            return Row(
              children: [
                Expanded(flex: 65, child: _CampusWelcomePanel()),
                Expanded(
                  flex: 35,
                  child: ColoredBox(
                    color: Colors.white,
                    child: SafeArea(
                      child: LayoutBuilder(
                        builder: (context, panelConstraints) => Center(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 20,
                            ),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: (panelConstraints.maxHeight - 40)
                                    .clamp(0, double.infinity),
                                maxWidth: 460,
                              ),
                              child: Center(
                                child: _AuthContent(
                                  title: title,
                                  subtitle: subtitle,
                                  child: child,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          return Stack(
            fit: StackFit.expand,
            children: [
              const _CampusPhotograph(),
              const _CampusOverlay(),
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, mobileConstraints) => Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 20,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: (mobileConstraints.maxHeight - 40).clamp(
                            0,
                            double.infinity,
                          ),
                          maxWidth: 460,
                        ),
                        child: Center(
                          child: _AuthContent(
                            title: title,
                            subtitle: subtitle,
                            overPhotograph: true,
                            child: child,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CampusWelcomePanel extends StatelessWidget {
  const _CampusWelcomePanel();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const _CampusPhotograph(),
        const _CampusOverlay(),
        SafeArea(
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(56, 48, 48, 64),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SRI RAMAKRISHNA INSTITUTE OF TECHNOLOGY',
                      style: TextStyle(
                        color: Color(0xFFFFDA82),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.6,
                      ),
                    ),
                    SizedBox(height: 18),
                    Text(
                      'Welcome to SRIT Plus',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Your campus, connected.',
                      style: TextStyle(
                        color: Color(0xFFE6EDF5),
                        fontSize: 18,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CampusPhotograph extends StatelessWidget {
  const _CampusPhotograph();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
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
              : Image.asset(
                  'assets/images/srit_campus_background.jpg',
                  fit: BoxFit.cover,
                ),
          errorBuilder: (_, _, _) => Image.asset(
            'assets/images/srit_campus_background.jpg',
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) =>
                const ColoredBox(color: Color(0xFF123B72)),
          ),
        );
      },
    );
  }
}

class _CampusOverlay extends StatelessWidget {
  const _CampusOverlay();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0x5006172B), Color(0x66123152), Color(0xB3091728)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }
}

class _AuthContent extends StatelessWidget {
  const _AuthContent({
    required this.title,
    required this.subtitle,
    required this.child,
    this.overPhotograph = false,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final bool overPhotograph;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(child: BrandMark(size: overPhotograph ? 68 : 72)),
        const SizedBox(height: 14),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: overPhotograph ? Colors.white : const Color(0xFF172B45),
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: overPhotograph
                ? Colors.white.withValues(alpha: 0.9)
                : const Color(0xFF607086),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: overPhotograph
                ? Colors.white.withValues(alpha: 0.97)
                : const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: overPhotograph
                  ? Colors.white.withValues(alpha: 0.85)
                  : const Color(0xFFE4EAF2),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: overPhotograph ? 0.2 : 0.06,
                ),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: child,
        ),
        if (kIsWeb) ...[
          const SizedBox(height: 16),
          AndroidApkDownloadCard(
            compact: true,
            darkTheme: overPhotograph,
          ),
        ],
        if (overPhotograph) ...[
          const SizedBox(height: 16),
          Text(
            'SRI RAMAKRISHNA INSTITUTE OF TECHNOLOGY',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: const Color(0xFFFFDA82),
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ],
    );
  }
}
