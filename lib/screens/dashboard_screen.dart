import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../services/campus_links.dart';
import '../models/campus_update.dart';
import '../providers/campus_content_provider.dart';
import '../providers/theme_provider.dart';
import '../services/push_notification_service.dart';
import '../widgets/brand_mark.dart';
import '../widgets/official_srit_gallery.dart';
import 'web_portal_shell.dart';
import 'campus_pages.dart';
import 'website_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  CampusSection? _selectedSection;
  bool _isSigningOut = false;
  late final PushNotificationService _pushNotificationService;
  StreamSubscription<RemoteMessage>? _messageOpenedSubscription;
  StreamSubscription<RemoteMessage>? _foregroundMessageSubscription;

  @override
  void initState() {
    super.initState();
    _pushNotificationService = PushNotificationService();
    _messageOpenedSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
      _openNotificationSection,
    );
    _foregroundMessageSubscription = FirebaseMessaging.onMessage.listen(
      _showForegroundNotification,
    );
    unawaited(_openInitialNotification());
    _openSectionFromWebUrl();
  }

  Future<void> _signOut() async {
    setState(() => _isSigningOut = true);
    try {
      await _pushNotificationService.unregisterCurrentDevice(
        AuthService().currentUser,
      );
      await AuthService().signOut();
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AuthService.messageForFirebaseError(error))),
        );
      }
    } on AuthServiceException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } on FirebaseException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not remove this device from push notifications: '
              '${error.message ?? error.code}. Try signing out again.',
            ),
          ),
        );
      }
    } on PushNotificationException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => _isSigningOut = false);
    }
  }

  Future<void> _enableNotifications() async {
    final user = AuthService().currentUser;
    if (user == null) return;
    try {
      await _pushNotificationService.enableForUser(user);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('SRIT Plus notifications are enabled.')),
        );
      }
    } on PushNotificationException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } on FirebaseException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not register this device for notifications: '
              '${error.message ?? error.code}.',
            ),
          ),
        );
      }
    }
  }

  Future<void> _openInitialNotification() async {
    if (!await FirebaseMessaging.instance.isSupported()) return;
    try {
      final message = await FirebaseMessaging.instance.getInitialMessage();
      if (message != null) _openNotificationSection(message);
    } on FirebaseException catch (error, stackTrace) {
      debugPrint('Could not read the initial push notification: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  void _openSectionFromWebUrl() {
    if (!kIsWeb) return;
    final title = Uri.base.queryParameters['section'];
    if (title != null) _openSection(title);
  }

  void _openNotificationSection(RemoteMessage message) {
    final title = message.data['section'];
    if (title is String) _openSection(title);
  }

  void _openSection(String title) {
    for (final section in campusSections) {
      if (section.title == title) {
        if (mounted) setState(() => _selectedSection = section);
        return;
      }
    }
    if (title == 'Home' && mounted) {
      setState(() => _selectedSection = null);
    }
  }

  void _showForegroundNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null || !mounted) return;
    final title = message.data['section'];
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          [
            if (notification.title?.isNotEmpty == true) notification.title,
            if (notification.body?.isNotEmpty == true) notification.body,
          ].join('\n'),
        ),
        action: title is String
            ? SnackBarAction(
                label: 'Open',
                onPressed: () => _openSection(title),
              )
            : null,
      ),
    );
  }

  @override
  void dispose() {
    unawaited(_messageOpenedSubscription?.cancel());
    unawaited(_foregroundMessageSubscription?.cancel());
    unawaited(_pushNotificationService.dispose());
    super.dispose();
  }

  void _selectSection(CampusSection? section) {
    Navigator.of(context).pop();
    setState(() => _selectedSection = section);
  }

  void _openWebsite() {
    Navigator.of(context).pop();
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const WebsiteScreen()));
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return WebPortalShell(
        homeBuilder: (onSelectSection) => DashboardHome(
          onSelectSection: onSelectSection,
          onOpenWebsite: _openWebsiteFromHome,
        ),
        onSignOut: _signOut,
        onEnableNotifications: _enableNotifications,
        initialSection: _selectedSection,
      );
    }

    final user = AuthService().currentUser;
    final selectedTitle = _selectedSection?.title ?? 'Home';
    final isCompact = MediaQuery.sizeOf(context).width < 700;
    final selectedNavigationIndex = switch (selectedTitle) {
      'Programs and Courses' => 1,
      'Attendance' => 2,
      'Student Profile' => 3,
      _ => 0,
    };
    return Scaffold(
      appBar: AppBar(
        title: Text(
          selectedTitle == 'Home' ? 'SRIT Plus' : selectedTitle,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          if (_isSigningOut)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              _ProfileHeader(user: user),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                  children: [
                    _DrawerItem(
                      icon: Icons.home_rounded,
                      title: 'Home',
                      selected: _selectedSection == null,
                      onTap: () => _selectSection(null),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(14, 14, 14, 8),
                      child: Text(
                        'CAMPUS',
                        style: TextStyle(
                          color: Color(0xFF8492A6),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    ...campusSections.map(
                      (section) => _DrawerItem(
                        icon: section.icon,
                        title: section.title == 'Online Fee Payment'
                            ? 'Fee Payment'
                            : section.title == 'COE'
                            ? 'Centre of Excellence'
                            : section.title,
                        selected: _selectedSection == section,
                        onTap: () => _selectSection(section),
                      ),
                    ),
                    _DrawerItem(
                      icon: Icons.language_rounded,
                      title: 'SRIT Website',
                      onTap: _openWebsite,
                    ),
                    _DrawerItem(
                      icon: Icons.notifications_active_outlined,
                      title: 'Enable notifications',
                      onTap: () {
                        Navigator.of(context).pop();
                        _enableNotifications();
                      },
                    ),
                    const Divider(height: 24),
                    SwitchListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                      ),
                      secondary: Icon(
                        context.watch<ThemeProvider>().isDarkMode
                            ? Icons.dark_mode_outlined
                            : Icons.light_mode_outlined,
                      ),
                      title: const Text('Dark mode'),
                      value: context.watch<ThemeProvider>().isDarkMode,
                      onChanged: context.read<ThemeProvider>().toggleDarkMode,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.logout_rounded),
                title: Text(_isSigningOut ? 'Signing out…' : 'Log out'),
                enabled: !_isSigningOut,
                onTap: () {
                  Navigator.of(context).pop();
                  _signOut();
                },
              ),
            ],
          ),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        child: _selectedSection == null
            ? DashboardHome(
                key: const ValueKey('home'),
                onSelectSection: (section) =>
                    setState(() => _selectedSection = section),
                onOpenWebsite: _openWebsiteFromHome,
              )
            : CampusSectionContent(
                key: ValueKey(_selectedSection!.title),
                section: _selectedSection!,
              ),
      ),
      bottomNavigationBar: isCompact
          ? NavigationBar(
              selectedIndex: selectedNavigationIndex,
              onDestinationSelected: (index) {
                final title = switch (index) {
                  1 => 'Programs and Courses',
                  2 => 'Attendance',
                  3 => 'Student Profile',
                  _ => null,
                };
                setState(
                  () => _selectedSection = title == null
                      ? null
                      : campusSections.firstWhere(
                          (section) => section.title == title,
                        ),
                );
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.menu_book_outlined),
                  selectedIcon: Icon(Icons.menu_book_rounded),
                  label: 'Academics',
                ),
                NavigationDestination(
                  icon: Icon(Icons.fact_check_outlined),
                  selectedIcon: Icon(Icons.fact_check_rounded),
                  label: 'Student',
                ),
                NavigationDestination(
                  icon: Icon(Icons.account_circle_outlined),
                  selectedIcon: Icon(Icons.account_circle_rounded),
                  label: 'Profile',
                ),
              ],
            )
          : null,
    );
  }

  void _openWebsiteFromHome() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const WebsiteScreen()));
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});

  final User? user;

  @override
  Widget build(BuildContext context) {
    final name = user?.displayName?.trim();
    final email = user?.email?.trim();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E5BB1), Color(0xFF123B72)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BrandMark(size: 58),
          const SizedBox(height: 18),
          Text(
            name?.isNotEmpty == true ? name! : 'Campus community',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email?.isNotEmpty == true ? email! : 'SRIT Plus',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: ListTile(
        selected: selected,
        selectedColor: const Color(0xFF174A8B),
        selectedTileColor: const Color(0xFFEAF2FF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        leading: Icon(icon, size: 21),
        title: Text(title, style: const TextStyle(fontSize: 14)),
        onTap: onTap,
      ),
    );
  }
}

class DashboardHome extends StatelessWidget {
  const DashboardHome({
    required this.onSelectSection,
    required this.onOpenWebsite,
    super.key,
  });

  final ValueChanged<CampusSection> onSelectSection;
  final VoidCallback onOpenWebsite;

  @override
  Widget build(BuildContext context) {
    final greeting = AuthService().currentUser?.displayName?.trim();
    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
              children: [
                _HeroBanner(
                  greeting: greeting?.isNotEmpty == true
                      ? 'Welcome, $greeting'
                      : 'Welcome to SRIT',
                  onOpenWebsite: onOpenWebsite,
                ),
                const SizedBox(height: 26),
                _SectionHeading(
                  title: 'Quick access',
                  trailing: 'Explore campus',
                  onTap: () => onSelectSection(campusSections.first),
                ),
                const SizedBox(height: 13),
                _QuickLinks(onSelectSection: onSelectSection),
                const SizedBox(height: 28),
                const _SectionHeading(title: 'Latest announcements'),
                const SizedBox(height: 13),
                const _LiveCampusContent(
                  type: CampusUpdateType.announcement,
                  emptyMessage: 'No published announcements yet.',
                ),
                const SizedBox(height: 22),
                const _SectionHeading(title: 'Latest news'),
                const SizedBox(height: 13),
                const _LiveCampusContent(
                  type: CampusUpdateType.news,
                  emptyMessage: 'No published news yet.',
                ),
                const SizedBox(height: 22),
                const _SectionHeading(title: 'Upcoming events'),
                const SizedBox(height: 13),
                const _LiveCampusContent(
                  type: CampusUpdateType.event,
                  emptyMessage: 'No upcoming events have been announced.',
                ),
                const SizedBox(height: 28),
                _SectionHeading(title: 'A message from our Principal'),
                const SizedBox(height: 13),
                _PrincipalCard(onReadMessage: onOpenWebsite),
                const SizedBox(height: 28),
                _SectionHeading(title: 'Department highlights'),
                const SizedBox(height: 13),
                _DepartmentHighlights(onSelectSection: onSelectSection),
                const SizedBox(height: 24),
                _FactsStrip(
                  onTap: () => onSelectSection(
                    campusSections.firstWhere(
                      (section) => section.title == 'About Us',
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                const _SectionHeading(title: 'About SRIT'),
                const SizedBox(height: 13),
                _InstitutionOverview(onOpenWebsite: onOpenWebsite),
                const SizedBox(height: 28),
                _SectionHeading(title: 'Explore college life'),
                const SizedBox(height: 13),
                _CampusSectionGrid(
                  sections: campusSections,
                  onSelectSection: onSelectSection,
                ),
                if (kIsWeb) ...[
                  const SizedBox(height: 28),
                  const OfficialSritGallery(),
                ],
                const SizedBox(height: 28),
                _PortalFooter(onOpenWebsite: onOpenWebsite),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.greeting, required this.onOpenWebsite});

  final String greeting;
  final VoidCallback onOpenWebsite;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: SizedBox(
        height: 230,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/srit_campus_background.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const ColoredBox(
                color: Color(0xFF123B72),
                child: Center(
                  child: Icon(
                    Icons.account_balance_rounded,
                    size: 84,
                    color: Colors.white24,
                  ),
                ),
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xE6091B34), Color(0x0B091B34)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'SRI RAMAKRISHNA INSTITUTE OF TECHNOLOGY',
                    style: TextStyle(
                      color: Color(0xFFFFD978),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    greeting,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.surface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Learn. Innovate. Make an impact.',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  const SizedBox(height: 15),
                  OutlinedButton.icon(
                    onPressed: onOpenWebsite,
                    icon: const Icon(Icons.language_rounded, size: 17),
                    label: const Text('Explore SRIT'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white70),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveCampusContent extends StatelessWidget {
  const _LiveCampusContent({required this.type, required this.emptyMessage});

  final CampusUpdateType type;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    return Consumer<CampusContentProvider>(
      builder: (context, content, _) {
        final (items, isLoading, error) = switch (type) {
          CampusUpdateType.announcement => (
            content.announcements,
            content.isLoadingAnnouncements,
            content.announcementsError,
          ),
          CampusUpdateType.news => (
            content.news,
            content.isLoadingNews,
            content.newsError,
          ),
          CampusUpdateType.event => (
            content.events,
            content.isLoadingEvents,
            content.eventsError,
          ),
        };
        if (error != null) {
          return Card(
            child: ListTile(
              leading: Icon(
                Icons.cloud_off_outlined,
                color: Theme.of(context).colorScheme.error,
              ),
              title: const Text('Campus updates unavailable'),
              subtitle: Text('$error'),
              trailing: IconButton(
                tooltip: 'Retry campus updates',
                onPressed: content.refresh,
                icon: const Icon(Icons.refresh_rounded),
              ),
            ),
          );
        }
        if (isLoading) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: LinearProgressIndicator(),
            ),
          );
        }
        if (items.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Text(
                emptyMessage,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          );
        }
        return Column(
          children: [
            for (final item in items) ...[
              _CampusUpdateCard(item: item),
              if (item != items.last) const SizedBox(height: 10),
            ],
          ],
        );
      },
    );
  }
}

class _CampusUpdateCard extends StatelessWidget {
  const _CampusUpdateCard({required this.item});

  final CampusUpdate item;

  @override
  Widget build(BuildContext context) {
    final date = item.publishedAt;
    final dateLabel = date == null
        ? null
        : '${date.toLocal().year}-'
              '${date.toLocal().month.toString().padLeft(2, '0')}-'
              '${date.toLocal().day.toString().padLeft(2, '0')}';
    final icon = switch (item.type) {
      CampusUpdateType.announcement => Icons.campaign_outlined,
      CampusUpdateType.news => Icons.newspaper_outlined,
      CampusUpdateType.event => Icons.event_available_outlined,
    };

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: item.link == null
            ? null
            : () => openCampusLink(context, item.link!),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF2467CF).withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: const Color(0xFF2467CF)),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (dateLabel != null) ...[
                      Text(
                        dateLabel,
                        style: const TextStyle(
                          color: Color(0xFFAD8132),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                    ],
                    Text(
                      item.title,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      item.description,
                      style: const TextStyle(
                        color: Color(0xFF65758A),
                        fontSize: 12,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              if (item.link != null)
                const Icon(Icons.open_in_new_rounded, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, this.trailing, this.onTap});

  final String title;
  final String? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        if (trailing != null)
          TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              foregroundColor: const Color(0xFF245EA9),
            ),
            child: Text(trailing!),
          ),
      ],
    );
  }
}

class _QuickLinks extends StatelessWidget {
  const _QuickLinks({required this.onSelectSection});

  final ValueChanged<CampusSection> onSelectSection;

  @override
  Widget build(BuildContext context) {
    const titles = [
      'Academics',
      'Admission',
      'Placement',
      'Online Fee Payment',
      'Attendance',
      'Internal Marks',
      'Exam Results',
      'Timetable',
      'Study Materials',
      'Library',
      'Internships',
      'Student Profile',
    ];
    final quickSections = titles
        .map(
          (title) =>
              campusSections.firstWhere((section) => section.title == title),
        )
        .toList(growable: false);
    return LayoutBuilder(
      builder: (context, constraints) {
        return _CampusSectionGrid(
          sections: quickSections,
          onSelectSection: onSelectSection,
          width: constraints.maxWidth,
        );
      },
    );
  }
}

class _CampusSectionGrid extends StatelessWidget {
  const _CampusSectionGrid({
    required this.sections,
    required this.onSelectSection,
    this.width,
  });

  final List<CampusSection> sections;
  final ValueChanged<CampusSection> onSelectSection;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = width ?? constraints.maxWidth;
        final columns = availableWidth >= 900
            ? 4
            : availableWidth >= 600
            ? 3
            : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sections.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 76,
          ),
          itemBuilder: (context, index) {
            final section = sections[index];
            return Material(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(17),
              child: InkWell(
                borderRadius: BorderRadius.circular(17),
                onTap: () => onSelectSection(section),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 13),
                  child: Row(
                    children: [
                      Icon(section.icon, color: section.color),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          section.title == 'Online Fee Payment'
                              ? 'Fee Payment'
                              : section.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right, size: 18),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _PrincipalCard extends StatelessWidget {
  const _PrincipalCard({required this.onReadMessage});

  final VoidCallback onReadMessage;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/images/srit_principal.jpg',
                width: 76,
                height: 88,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  width: 76,
                  height: 88,
                  color: const Color(0xFFE9F0FA),
                  child: const Icon(
                    Icons.person_outline_rounded,
                    color: Color(0xFF245EA9),
                    size: 38,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dr. J. David Rathnaraj',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Principal, SRIT',
                    style: TextStyle(
                      color: Color(0xFFAD8132),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 9),
                  Text(
                    'SRIT’s vision is to deliver quality, value-based '
                    'education and build centres of excellence.',
                    style: TextStyle(
                      color: Color(0xFF65758A),
                      fontSize: 12,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _PrincipalMessageLink(onTap: onReadMessage),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrincipalMessageLink extends StatelessWidget {
  const _PrincipalMessageLink({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
        ),
        child: const Text('Read Principal’s message'),
      ),
    );
  }
}

class _DepartmentHighlights extends StatelessWidget {
  const _DepartmentHighlights({required this.onSelectSection});

  final ValueChanged<CampusSection> onSelectSection;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 128,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: sritDepartmentSections.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final department = sritDepartmentSections[index];
          return SizedBox(
            width: 170,
            child: Material(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => onSelectSection(department),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(department.icon, color: department.color, size: 24),
                      Text(
                        department.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _InstitutionOverview extends StatelessWidget {
  const _InstitutionOverview({required this.onOpenWebsite});

  final VoidCallback onOpenWebsite;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sri Ramakrishna Institute of Technology',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Established in 2002, SRIT is an autonomous engineering '
              'institution affiliated to Anna University and governed by the '
              'SNR Sons Charitable Trust. The official profile describes a '
              '49.99-acre campus in Coimbatore.',
              style: TextStyle(height: 1.5),
            ),
            const SizedBox(height: 18),
            const Text('Vision', style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            const Text(
              'To develop into a World Class Technological Institute with '
              'centres of excellence in various disciplines.',
              style: TextStyle(height: 1.45),
            ),
            const SizedBox(height: 14),
            const Text(
              'Mission',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            const Text(
              'To produce Quality Engineers, Scientists and Managers equipped '
              'with unbounded technical skills, domain knowledge and excellent '
              'moral values.',
              style: TextStyle(height: 1.45),
            ),
            const SizedBox(height: 14),
            const Text(
              'Management',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            const Text(
              'Governed by the SNR Sons Charitable Trust. The official '
              'management page identifies Shri Sundar Ramakrishnan as '
              'Managing Trustee.',
              style: TextStyle(height: 1.45),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: onOpenWebsite,
                icon: const Icon(Icons.open_in_new_rounded),
                label: const Text('Visit the official SRIT website'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PortalFooter extends StatelessWidget {
  const _PortalFooter({required this.onOpenWebsite});

  final VoidCallback onOpenWebsite;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF123B72),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sri Ramakrishna Institute of Technology',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pachapalayam (Post), Perur Chettipalayam, '
              'Coimbatore - 641 010, India',
              style: TextStyle(color: Colors.white70, height: 1.4),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                TextButton(
                  onPressed: onOpenWebsite,
                  child: const Text(
                    'Official website',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: () => openCampusLink(
                    context,
                    Uri.parse(
                      'https://www.facebook.com/people/'
                      'Sri-Ramakrishna-Institute-of-Technology-Coimbatore/'
                      '61574831909063/',
                    ),
                  ),
                  child: const Text(
                    'Facebook',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: () => openCampusLink(
                    context,
                    Uri.parse('https://www.instagram.com/snr_srit/'),
                  ),
                  child: const Text(
                    'Instagram',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: () => openCampusLink(
                    context,
                    Uri.parse(
                      'https://www.linkedin.com/school/'
                      'sri-ramakrishna-institute-of-technology/',
                    ),
                  ),
                  child: const Text(
                    'LinkedIn',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FactsStrip extends StatelessWidget {
  const _FactsStrip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _Fact(value: '2002', label: 'Established'),
              _Fact(value: '49.99', label: 'Campus acres'),
              _Fact(value: '65,117', label: 'Built-up sq.m'),
            ],
          ),
        ),
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF174A8B),
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}
