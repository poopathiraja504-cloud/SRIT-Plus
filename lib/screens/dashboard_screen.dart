import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../services/campus_links.dart';
import '../models/campus_update.dart';
import '../providers/campus_content_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/brand_mark.dart';
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

  Future<void> _signOut() async {
    setState(() => _isSigningOut = true);
    try {
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
    } finally {
      if (mounted) setState(() => _isSigningOut = false);
    }
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
    final user = AuthService().currentUser;
    final selectedTitle = _selectedSection?.title ?? 'Home';
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
                const _DepartmentHighlights(),
                const SizedBox(height: 24),
                _FactsStrip(
                  onTap: () => onSelectSection(
                    campusSections.firstWhere(
                      (section) => section.title == 'About Us',
                    ),
                  ),
                ),
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
            Image.network(
              sritCampusImage,
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
    final quickSections = [
      campusSections.first,
      campusSections.firstWhere((section) => section.title == 'Admission'),
      campusSections.firstWhere((section) => section.title == 'Placement'),
      campusSections.firstWhere(
        (section) => section.title == 'Online Fee Payment',
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 700 ? 4 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: quickSections.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.45,
          ),
          itemBuilder: (context, index) {
            final section = quickSections[index];
            return Material(
              color: Colors.white,
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
              child: Image.network(
                'https://cdn.prod.website-files.com/69ba31e796b16c01f4b12199/'
                '6a683ff708e061caa75b1adf_SRIT%20Principal%20Image.png',
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
  const _DepartmentHighlights();

  @override
  Widget build(BuildContext context) {
    const departments = [
      ('Computer Science & Engineering', Icons.computer_rounded),
      ('Electronics & Communication', Icons.memory_rounded),
      ('Electrical & Electronics', Icons.electric_bolt_rounded),
      ('Mechanical Engineering', Icons.precision_manufacturing_rounded),
      ('Information Technology', Icons.devices_rounded),
    ];
    return SizedBox(
      height: 128,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: departments.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final (name, icon) = departments[index];
          return SizedBox(
            width: 150,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(icon, color: const Color(0xFF2467CF), size: 24),
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
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
              _Fact(value: '8', label: 'Programmes'),
              _Fact(value: '49.99', label: 'Campus acres'),
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
