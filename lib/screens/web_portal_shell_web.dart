import 'dart:async';
import 'dart:js_interop';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web/web.dart' as web;

import '../models/campus_update.dart';
import '../providers/campus_content_provider.dart';
import '../providers/theme_provider.dart';
import '../services/auth_service.dart';
import '../services/activity_analytics_service.dart';
import '../services/campus_links.dart';
import '../widgets/analytics_consent_banner.dart';
import '../widgets/android_apk_download_card.dart';
import '../widgets/brand_mark.dart';
import '../widgets/official_srit_gallery.dart';
import 'campus_pages.dart';

typedef PortalHomeBuilder =
    Widget Function(ValueChanged<CampusSection> onSelectSection);

class WebPortalShell extends StatefulWidget {
  const WebPortalShell({
    required this.homeBuilder,
    required this.onSignOut,
    required this.onEnableNotifications,
    this.initialSection,
    super.key,
  });

  final PortalHomeBuilder homeBuilder;
  final Future<void> Function() onSignOut;
  final Future<void> Function() onEnableNotifications;
  final CampusSection? initialSection;

  @override
  State<WebPortalShell> createState() => _WebPortalShellState();
}

class _WebPortalShellState extends State<WebPortalShell> {
  static const _groups = <_NavGroup>[
    _NavGroup('DASHBOARD', [
      _NavEntry('dashboard', 'Home', Icons.home_outlined),
      _NavEntry('my-dashboard', 'My Dashboard', Icons.space_dashboard_outlined),
    ]),
    _NavGroup('MY ACCOUNT', [
      _NavEntry('profile', 'My Profile', Icons.account_circle_outlined),
      _NavEntry('personal-details', 'Personal Details', Icons.badge_outlined),
      _NavEntry('academic-details', 'Academic Details', Icons.school_outlined),
      _NavEntry('edit-profile', 'Edit Profile', Icons.edit_outlined),
      _NavEntry('settings', 'Settings', Icons.settings_outlined),
      _NavEntry('change-password', 'Change Password', Icons.password_outlined),
      _NavEntry('security', 'Security', Icons.security_outlined),
    ]),
    _NavGroup('ACADEMICS', [
      _NavEntry('attendance', 'Attendance', Icons.fact_check_outlined),
      _NavEntry('internal-marks', 'Internal Marks', Icons.grading_outlined),
      _NavEntry(
        'semester-results',
        'Semester Results',
        Icons.assessment_outlined,
      ),
      _NavEntry('exam-timetable', 'Exam Timetable', Icons.event_note_outlined),
      _NavEntry(
        'class-timetable',
        'Class Timetable',
        Icons.calendar_month_outlined,
      ),
      _NavEntry(
        'study-materials',
        'Study Materials',
        Icons.library_books_outlined,
      ),
    ]),
    _NavGroup('COLLEGE', [
      _NavEntry('departments', 'Departments', Icons.account_tree_outlined),
      _NavEntry('faculty', 'Faculty', Icons.people_alt_outlined),
      _NavEntry('placements', 'Placements', Icons.work_outline_rounded),
      _NavEntry('internship', 'Internship', Icons.work_history_outlined),
      _NavEntry('events', 'Events', Icons.event_available_outlined),
      _NavEntry('announcements', 'Announcements', Icons.campaign_outlined),
      _NavEntry('gallery', 'Campus Gallery', Icons.photo_library_outlined),
    ]),
    _NavGroup('SUPPORT', [
      _NavEntry('help-centre', 'Help Centre', Icons.help_outline_rounded),
      _NavEntry('contact-srit', 'Contact SRIT', Icons.contact_page_outlined),
      _NavEntry('feedback', 'Feedback', Icons.feedback_outlined),
    ]),
  ];

  static final _sectionRoutes = <String, CampusSection>{
    for (final section in campusSections) _slug(section.title): section,
  };
  static const _routeAliases = <String, String>{
    'departments': 'programs-and-courses',
    'faculty': 'faculty-and-staff',
    'placements': 'placement',
    'internship': 'internships',
    'help-centre': 'contact-us',
    'contact-srit': 'contact-us',
    'semester-results': 'exam-results',
    'exam-timetable': 'timetable',
    'class-timetable': 'timetable',
  };
  static const _knownStandaloneRoutes = {
    'dashboard',
    'my-dashboard',
    'profile',
    'personal-details',
    'academic-details',
    'edit-profile',
    'settings',
    'change-password',
    'security',
    'events',
    'announcements',
    'gallery',
    'feedback',
  };

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final List<String> _previousRoutes = [];
  late final web.EventListener _popStateListener;
  late String _route;
  bool _isSidebarCollapsed = false;

  @override
  void initState() {
    super.initState();
    _route = widget.initialSection == null
        ? _routeFromLocation()
        : _routeForSection(widget.initialSection!);
    unawaited(ActivityAnalyticsService.instance.logPageVisit(_route));
    _popStateListener = ((web.Event _) => _handlePopState()).toJS;
    web.window.addEventListener('popstate', _popStateListener);
  }

  @override
  void didUpdateWidget(covariant WebPortalShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialSection != oldWidget.initialSection &&
        widget.initialSection != null) {
      final nextRoute = _routeForSection(widget.initialSection!);
      if (nextRoute != _route) {
        _previousRoutes.add(_route);
        _route = nextRoute;
        _writeRoute(nextRoute, replace: true);
        unawaited(ActivityAnalyticsService.instance.logPageVisit(nextRoute));
      }
    }
  }

  @override
  void dispose() {
    web.window.removeEventListener('popstate', _popStateListener);
    super.dispose();
  }

  static String _slug(String value) => value
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');

  String _routeForSection(CampusSection section) => _slug(section.title);

  String _routeFromLocation() {
    final uri = Uri.parse(web.window.location.href);
    final page = uri.queryParameters['page'];
    if (page != null &&
        (_knownStandaloneRoutes.contains(page) ||
            _sectionForRoute(page) != null)) {
      return page;
    }

    final sectionTitle = uri.queryParameters['section'];
    if (sectionTitle != null) {
      if (sectionTitle == 'Home') return 'dashboard';
      for (final section in campusSections) {
        if (section.title == sectionTitle) return _routeForSection(section);
      }
    }
    return 'dashboard';
  }

  CampusSection? _sectionForRoute(String route) {
    if (route == 'departments') {
      return _sectionRoutes['programs-and-courses'];
    }
    final target = _routeAliases[route] ?? route;
    return _sectionRoutes[target];
  }

  String _titleForRoute(String route) {
    for (final group in _groups) {
      for (final entry in group.entries) {
        if (entry.route == route) return entry.label;
      }
    }
    final section = _sectionForRoute(route);
    return section?.title ??
        switch (route) {
          'dashboard' || 'my-dashboard' => 'SRIT PORTAL',
          'profile' => 'My Profile',
          'personal-details' => 'Personal Details',
          'academic-details' => 'Academic Details',
          'edit-profile' => 'Edit Profile',
          'settings' => 'Settings',
          'change-password' => 'Change Password',
          'security' => 'Security',
          'events' => 'Events',
          'announcements' => 'Announcements',
          'gallery' => 'Campus Gallery',
          'feedback' => 'Feedback',
          _ => 'SRIT PORTAL',
        };
  }

  void _writeRoute(String route, {bool replace = false}) {
    final current = Uri.parse(web.window.location.href);
    final query = Map<String, String>.from(current.queryParameters)
      ..remove('section');
    if (route == 'dashboard' || route == 'my-dashboard') {
      query.remove('page');
    } else {
      query['page'] = route;
    }
    final target = current.replace(
      queryParameters: query.isEmpty ? null : query,
    );
    if (replace) {
      web.window.history.replaceState(null, '', target.toString());
    } else {
      web.window.history.pushState(null, '', target.toString());
    }
  }

  void _selectRoute(String nextRoute) {
    if (nextRoute == _route) {
      _scaffoldKey.currentState?.closeDrawer();
      return;
    }
    _previousRoutes.add(_route);
    _writeRoute(nextRoute);
    unawaited(
      ActivityAnalyticsService.instance.logNavigationClick(nextRoute),
    );
    unawaited(ActivityAnalyticsService.instance.logPageVisit(nextRoute));
    setState(() => _route = nextRoute);
    _scaffoldKey.currentState?.closeDrawer();
  }

  void _selectSection(CampusSection section) {
    _selectRoute(_routeForSection(section));
  }

  void _handlePopState() {
    final nextRoute = _routeFromLocation();
    if (nextRoute == _route) return;
    if (_previousRoutes.isNotEmpty && _previousRoutes.last == nextRoute) {
      _previousRoutes.removeLast();
    } else {
      _previousRoutes.add(_route);
    }
    unawaited(
      ActivityAnalyticsService.instance.logNavigationClick(nextRoute),
    );
    unawaited(ActivityAnalyticsService.instance.logPageVisit(nextRoute));
    setState(() => _route = nextRoute);
    _scaffoldKey.currentState?.closeDrawer();
  }

  void _goBack() {
    if (_previousRoutes.isNotEmpty) {
      web.window.history.back();
      return;
    }
    if (_route != 'dashboard') {
      _writeRoute('dashboard', replace: true);
      setState(() => _route = 'dashboard');
    }
  }

  Widget _pageForRoute(User? user) {
    if (_route == 'dashboard' || _route == 'my-dashboard') {
      return widget.homeBuilder(_selectSection);
    }
    if (_route == 'student-profile' ||
        _route == 'profile' ||
        _route == 'personal-details' ||
        _route == 'edit-profile') {
      return _ProfilePage(
        key: ValueKey(_route),
        user: user,
        startInEditMode: _route == 'edit-profile',
      );
    }
    if (_route == 'academic-details') {
      return const _AcademicDetailsPage();
    }
    if (_route == 'settings' ||
        _route == 'change-password' ||
        _route == 'security') {
      return _SettingsPage(
        route: _route,
        user: user,
        onEnableNotifications: widget.onEnableNotifications,
        onSignOut: widget.onSignOut,
      );
    }
    if (_route == 'gallery') {
      return const SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: OfficialSritGallery(expanded: true),
      );
    }
    if (_route == 'departments') {
      return _DepartmentsPage(onSelectSection: _selectSection);
    }
    if (_route == 'announcements') {
      return const _CampusUpdatesPage(type: CampusUpdateType.announcement);
    }
    if (_route == 'events') {
      return const _CampusUpdatesPage(type: CampusUpdateType.event);
    }
    if (_route == 'feedback') return const _FeedbackPage();
    final section = _sectionForRoute(_route);
    if (section != null) return CampusSectionContent(section: section);
    return const _UnknownRoutePage();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 1120;
    final sidebarWidth = _isSidebarCollapsed ? 88.0 : 278.0;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      key: _scaffoldKey,
      drawer: isDesktop
          ? null
          : Drawer(
              width: 300,
              child: _PortalSidebar(
                groups: _groups,
                selectedRoute: _route,
                user: user,
                collapsed: false,
                onSelect: _selectRoute,
                onSignOut: widget.onSignOut,
              ),
            ),
      appBar: AppBar(
        leading: _route == 'dashboard' || _route == 'my-dashboard'
            ? isDesktop
                  ? null
                  : IconButton(
                      tooltip: 'Open navigation',
                      onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                      icon: const Icon(Icons.menu_rounded),
                    )
            : IconButton(
                tooltip: 'Back',
                onPressed: _goBack,
                icon: const Icon(Icons.arrow_back_rounded),
              ),
        title: Row(
          children: [
            const BrandMark(size: 34),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _titleForRoute(_route),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        actions: [
          if (!isDesktop && _route != 'dashboard' && _route != 'my-dashboard')
            IconButton(
              tooltip: 'Open navigation',
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              icon: const Icon(Icons.menu_rounded),
            ),
          if (isDesktop)
            IconButton(
              tooltip: _isSidebarCollapsed
                  ? 'Expand navigation'
                  : 'Collapse navigation',
              onPressed: () =>
                  setState(() => _isSidebarCollapsed = !_isSidebarCollapsed),
              icon: Icon(
                _isSidebarCollapsed
                    ? Icons.menu_open_rounded
                    : Icons.menu_rounded,
              ),
            ),
          if (user != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: _UserAvatar(user: user, radius: 18),
            ),
        ],
      ),
      body: Row(
        children: [
          if (isDesktop)
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: sidebarWidth,
              child: _PortalSidebar(
                groups: _groups,
                selectedRoute: _route,
                user: user,
                collapsed: _isSidebarCollapsed,
                onSelect: _selectRoute,
                onSignOut: widget.onSignOut,
              ),
            ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) => Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: constraints.maxWidth > 1260
                      ? 1260
                      : constraints.maxWidth,
                  height: constraints.maxHeight,
                  child: _pageForRoute(user),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PortalSidebar extends StatelessWidget {
  const _PortalSidebar({
    required this.groups,
    required this.selectedRoute,
    required this.user,
    required this.collapsed,
    required this.onSelect,
    required this.onSignOut,
  });

  final List<_NavGroup> groups;
  final String selectedRoute;
  final User? user;
  final bool collapsed;
  final ValueChanged<String> onSelect;
  final Future<void> Function() onSignOut;

  @override
  Widget build(BuildContext context) {
    final displayName = user?.displayName?.trim();
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              collapsed ? 10 : 18,
              18,
              collapsed ? 10 : 18,
              18,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF00785B), Color(0xFF004B39)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: collapsed
                ? const Center(
                    child: BrandMark(size: 54),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const InstitutionBranding(
                        logoSize: 48,
                        textColor: Colors.white,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _UserAvatar(user: user, radius: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayName?.isNotEmpty == true
                                      ? displayName!
                                      : 'Campus community',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user?.email ?? 'Sign-in required',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                collapsed ? 8 : 12,
                10,
                collapsed ? 8 : 12,
                12,
              ),
              children: [
                for (final group in groups) ...[
                  if (!collapsed)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 14, 8, 6),
                      child: Text(
                        group.label,
                        style: const TextStyle(
                          color: Color(0xFF76877D),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.15,
                        ),
                      ),
                    ),
                  for (final entry in group.entries)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Tooltip(
                        message: collapsed ? entry.label : '',
                        child: ListTile(
                          selected: selectedRoute == entry.route,
                          selectedColor: const Color(0xFF00543F),
                          selectedTileColor: const Color(0xFFE8F5EF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                          dense: true,
                          leading: Icon(entry.icon, size: 20),
                          title: collapsed
                              ? null
                              : Text(
                                  entry.label,
                                  style: const TextStyle(fontSize: 13),
                                ),
                          horizontalTitleGap: 12,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: collapsed ? 12 : 14,
                            vertical: 1,
                          ),
                          onTap: () => onSelect(entry.route),
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
          const Divider(height: 1),
          if (!collapsed)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: AndroidApkDownloadCard(compact: true),
            )
          else
            Tooltip(
              message: 'Download Android APK (50.0 MiB)',
              child: ListTile(
                dense: true,
                leading: const Icon(Icons.android, color: Color(0xFF006B50)),
                onTap: triggerAndroidApkDownload,
              ),
            ),
          const Divider(height: 1),
          Tooltip(
            message: collapsed ? 'Logout' : '',
            child: ListTile(
              dense: true,
              leading: const Icon(Icons.logout_rounded),
              title: collapsed ? null : const Text('Logout'),
              onTap: onSignOut,
            ),
          ),
          if (!collapsed) const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({required this.user, required this.radius});

  final User? user;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final photoUrl = user?.photoURL;
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.white.withValues(alpha: 0.18),
      child: photoUrl == null || photoUrl.isEmpty
          ? Icon(
              Icons.person_outline_rounded,
              color: Colors.white,
              size: radius,
            )
          : ClipOval(
              child: Image.network(
                photoUrl,
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Icon(
                  Icons.person_outline_rounded,
                  color: Colors.white,
                  size: radius,
                ),
              ),
            ),
    );
  }
}

class _ProfilePage extends StatefulWidget {
  const _ProfilePage({
    required this.user,
    required this.startInEditMode,
    super.key,
  });

  final User? user;
  final bool startInEditMode;

  @override
  State<_ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<_ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _photoController;
  late User? _user;
  late bool _isEditing;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    _isEditing = widget.startInEditMode;
    _nameController = TextEditingController(text: _user?.displayName ?? '');
    _photoController = TextEditingController(text: _user?.photoURL ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _photoController.dispose();
    super.dispose();
  }

  void _cancelEdit() {
    setState(() {
      _nameController.text = _user?.displayName ?? '';
      _photoController.text = _user?.photoURL ?? '';
      _errorMessage = null;
      _isEditing = false;
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      setState(() => _errorMessage = 'Sign in again to edit your profile.');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });
    try {
      final name = _nameController.text.trim();
      final photoUrl = _photoController.text.trim();
      await currentUser.updateDisplayName(name.isEmpty ? null : name);
      await currentUser.updatePhotoURL(photoUrl.isEmpty ? null : photoUrl);
      await currentUser.reload();
      if (!mounted) return;
      setState(() {
        _user = FirebaseAuth.instance.currentUser;
        _isEditing = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile changes saved.')));
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        setState(
          () => _errorMessage = AuthService.messageForFirebaseError(error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;
    if (user == null) {
      return const Center(child: Text('Sign in to view your account profile.'));
    }

    final createdAt = user.metadata.creationTime;
    final accountProviders = user.providerData
        .map((provider) => provider.providerId)
        .toSet()
        .join(', ');

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _ProfilePhoto(user: user, radius: 48),
                const SizedBox(height: 14),
                Text(
                  user.displayName?.trim().isNotEmpty == true
                      ? user.displayName!
                      : 'Name not provided',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  user.email ?? 'Email not provided',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 18),
                OutlinedButton.icon(
                  onPressed: () => setState(() {
                    _nameController.text = user.displayName ?? '';
                    _photoController.text = user.photoURL ?? '';
                    _isEditing = true;
                  }),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit Profile'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        if (_isEditing)
          _ProfileEditForm(
            formKey: _formKey,
            nameController: _nameController,
            photoController: _photoController,
            isSaving: _isSaving,
            errorMessage: _errorMessage,
            onCancel: _cancelEdit,
            onSave: _saveProfile,
          )
        else ...[
          _InfoCard(
            title: 'Personal details',
            rows: [
              _InfoRow('Official email', user.email ?? 'Not provided'),
              _InfoRow('Phone number', user.phoneNumber ?? 'Not provided'),
              _InfoRow(
                'Email verification',
                user.emailVerified ? 'Verified' : 'Not verified',
              ),
              _InfoRow(
                'Account created',
                createdAt == null ? 'Not available' : _formatDate(createdAt),
              ),
              _InfoRow(
                'Sign-in provider',
                accountProviders.isEmpty ? 'Not available' : accountProviders,
              ),
            ],
          ),
          const SizedBox(height: 18),
          const _AcademicDataNotice(),
        ],
      ],
    );
  }
}

class _ProfileEditForm extends StatelessWidget {
  const _ProfileEditForm({
    required this.formKey,
    required this.nameController,
    required this.photoController,
    required this.isSaving,
    required this.errorMessage,
    required this.onCancel,
    required this.onSave,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController photoController;
  final bool isSaving;
  final String? errorMessage;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Edit account profile',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Display name',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: photoController,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: 'Profile photo HTTPS URL',
                  prefixIcon: Icon(Icons.image_outlined),
                ),
                validator: (value) {
                  final raw = value?.trim() ?? '';
                  if (raw.isEmpty) return null;
                  final uri = Uri.tryParse(raw);
                  if (uri == null ||
                      uri.scheme != 'https' ||
                      uri.host.isEmpty) {
                    return 'Use a valid HTTPS image URL';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              Text(
                'The photo URL is stored in your Firebase Auth profile. '
                'Direct image uploads are not configured for this project.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  FilledButton(
                    onPressed: isSaving ? null : onSave,
                    child: isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save Changes'),
                  ),
                  OutlinedButton(
                    onPressed: isSaving ? null : onCancel,
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfilePhoto extends StatelessWidget {
  const _ProfilePhoto({required this.user, required this.radius});

  final User user;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final photoUrl = user.photoURL;
    return CircleAvatar(
      radius: radius,
      backgroundColor: Theme.of(
        context,
      ).colorScheme.primary.withValues(alpha: 0.12),
      child: photoUrl == null || photoUrl.isEmpty
          ? Icon(
              Icons.person_outline_rounded,
              size: radius,
              color: Theme.of(context).colorScheme.primary,
            )
          : ClipOval(
              child: Image.network(
                photoUrl,
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Icon(
                  Icons.person_outline_rounded,
                  size: radius,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
    );
  }
}

class _AcademicDetailsPage extends StatelessWidget {
  const _AcademicDetailsPage();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(24),
      children: [
        const _AcademicDataNotice(),
        const SizedBox(height: 18),
        Card(
          child: ListTile(
            leading: Icon(Icons.lock_outline_rounded),
            title: Text('Academic records are not connected'),
            subtitle: Text(
              'Register number, department, academic year and semester must '
              'come from an approved SRIT student-record system. No such '
              'connection is configured in this Firebase project.',
            ),
          ),
        ),
      ],
    );
  }
}

class _DepartmentsPage extends StatelessWidget {
  const _DepartmentsPage({required this.onSelectSection});

  final ValueChanged<CampusSection> onSelectSection;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'Explore SRIT departments',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        const Text(
          'Department information links to the official SRIT pages. '
          'Select a department to view its published overview.',
        ),
        const SizedBox(height: 16),
        for (final section in sritDepartmentSections)
          Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: section.color.withValues(alpha: 0.1),
                child: Icon(section.icon, color: section.color),
              ),
              title: Text(
                section.title,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(section.intro),
              trailing: const Icon(Icons.arrow_forward_rounded),
              onTap: () => onSelectSection(section),
            ),
          ),
      ],
    );
  }
}

class _AcademicDataNotice extends StatelessWidget {
  const _AcademicDataNotice();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: ListTile(
        leading: Icon(Icons.verified_user_outlined),
        title: Text('Student records are not connected'),
        subtitle: Text(
          'Register number, department, academic year, semester, attendance '
          'and marks are not available from the current Firebase setup. '
          'No student information is invented.',
        ),
      ),
    );
  }
}

class _SettingsPage extends StatelessWidget {
  const _SettingsPage({
    required this.route,
    required this.user,
    required this.onEnableNotifications,
    required this.onSignOut,
  });

  final String route;
  final User? user;
  final Future<void> Function() onEnableNotifications;
  final Future<void> Function() onSignOut;

  Future<void> _sendPasswordReset(BuildContext context) async {
    final email = user?.email;
    if (email == null || email.isEmpty) return;
    try {
      await AuthService().sendPasswordReset(email);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password reset email sent to $email.')),
        );
      }
    } on FirebaseAuthException catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AuthService.messageForFirebaseError(error))),
        );
      }
    } on AuthServiceException catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final providerIds =
        user?.providerData.map((provider) => provider.providerId).toSet() ??
        const <String>{};
    final hasPasswordProvider =
        providerIds.contains('password') && user?.email?.isNotEmpty == true;
    final theme = context.watch<ThemeProvider>();

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _SettingsCard(
          icon: Icons.person_outline_rounded,
          title: 'Personal information',
          subtitle: user?.email ?? 'No authenticated email is available.',
        ),
        const SizedBox(height: 14),
        _SettingsCard(
          icon: Icons.lock_outline_rounded,
          title: 'Password settings',
          subtitle: hasPasswordProvider
              ? 'Reset the SRIT PORTAL account password through Firebase email.'
              : 'This account uses Google sign-in; its password is managed by '
                    'Google, not SRIT PORTAL.',
          child: hasPasswordProvider
              ? Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: () => _sendPasswordReset(context),
                    icon: const Icon(Icons.mark_email_read_outlined),
                    label: const Text('Send password reset email'),
                  ),
                )
              : null,
        ),
        const SizedBox(height: 14),
        _SettingsCard(
          icon: Icons.notifications_outlined,
          title: 'Notification preferences',
          subtitle:
              'Enable push notifications for this signed-in device. Browser '
              'or operating-system permission is still required.',
          child: Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: onEnableNotifications,
              icon: const Icon(Icons.notifications_active_outlined),
              label: const Text('Enable notifications'),
            ),
          ),
        ),
        const SizedBox(height: 14),
        _SettingsCard(
          icon: Icons.privacy_tip_outlined,
          title: 'Privacy and security',
          subtitle:
              'Your dashboard uses the signed-in Firebase account. Student '
              'records are not connected to this project.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Email verification: ${user?.emailVerified == true ? 'verified' : 'not verified'}'
                '\nSign-in provider: ${providerIds.isEmpty ? 'unavailable' : providerIds.join(', ')}',
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => showAnalyticsConsentDialog(context),
                icon: const Icon(Icons.analytics_outlined),
                label: const Text('Manage analytics preferences'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Card(
          child: SwitchListTile(
            secondary: Icon(
              theme.isDarkMode
                  ? Icons.dark_mode_outlined
                  : Icons.light_mode_outlined,
            ),
            title: const Text('Theme'),
            subtitle: const Text('Use the light or dark SRIT PORTAL theme.'),
            value: theme.isDarkMode,
            onChanged: theme.toggleDarkMode,
          ),
        ),
        if (route == 'change-password' && !hasPasswordProvider) ...[
          const SizedBox(height: 14),
          const Card(
            child: ListTile(
              leading: Icon(Icons.info_outline_rounded),
              title: Text('Password is managed by Google'),
              subtitle: Text(
                'SRIT PORTAL cannot change a Google account password. Use '
                'Google Account settings to manage it.',
              ),
            ),
          ),
        ],
        const SizedBox(height: 14),
        Card(
          child: ListTile(
            leading: const Icon(Icons.logout_rounded),
            title: const Text('Log out'),
            subtitle: const Text('Sign out of this SRIT PORTAL account.'),
            onTap: onSignOut,
          ),
        ),
      ],
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.child,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 5),
                      Text(subtitle),
                    ],
                  ),
                ),
              ],
            ),
            if (child != null) ...[const SizedBox(height: 12), child!],
          ],
        ),
      ),
    );
  }
}

class _CampusUpdatesPage extends StatelessWidget {
  const _CampusUpdatesPage({required this.type});

  final CampusUpdateType type;

  @override
  Widget build(BuildContext context) {
    return Consumer<CampusContentProvider>(
      builder: (context, provider, _) {
        final (items, isLoading, error, emptyMessage) = switch (type) {
          CampusUpdateType.announcement => (
            provider.announcements,
            provider.isLoadingAnnouncements,
            provider.announcementsError,
            'No published announcements are available.',
          ),
          CampusUpdateType.news => (
            provider.news,
            provider.isLoadingNews,
            provider.newsError,
            'No published news is available.',
          ),
          CampusUpdateType.event => (
            provider.events,
            provider.isLoadingEvents,
            provider.eventsError,
            'No upcoming events have been published.',
          ),
        };
        if (error != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off_outlined, size: 42),
                  const SizedBox(height: 12),
                  Text('Could not load updates: $error'),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: provider.refresh,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }
        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (items.isEmpty) {
          return Center(child: Text(emptyMessage));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(18),
                leading: CircleAvatar(
                  child: Icon(switch (item.type) {
                    CampusUpdateType.announcement => Icons.campaign_outlined,
                    CampusUpdateType.news => Icons.newspaper_outlined,
                    CampusUpdateType.event => Icons.event_outlined,
                  }),
                ),
                title: Text(
                  item.title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 7),
                  child: Text(item.description),
                ),
                trailing: item.link == null
                    ? null
                    : const Icon(Icons.open_in_new_rounded),
                onTap: item.link == null
                    ? null
                    : () => openCampusLink(context, item.link!),
              ),
            );
          },
        );
      },
    );
  }
}

class _FeedbackPage extends StatelessWidget {
  const _FeedbackPage();

  @override
  Widget build(BuildContext context) {
    final contactUri = Uri(
      scheme: 'mailto',
      path: 'principal@sritcbe.ac.in',
      queryParameters: const {'subject': 'SRIT PORTAL feedback'},
    );
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: Card(
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.feedback_outlined, size: 46),
                const SizedBox(height: 12),
                Text(
                  'Share feedback with SRIT',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Feedback is sent through your device’s email application to '
                  'the official SRIT contact. No feedback is stored in this '
                  'Firebase project.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: () => openCampusLink(context, contactUri),
                  icon: const Icon(Icons.mail_outline_rounded),
                  label: const Text('Email SRIT'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UnknownRoutePage extends StatelessWidget {
  const _UnknownRoutePage();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text('This SRIT PORTAL page is not available.'),
      ),
    );
  }
}

class _NavGroup {
  const _NavGroup(this.label, this.entries);

  final String label;
  final List<_NavEntry> entries;
}

class _NavEntry {
  const _NavEntry(this.route, this.label, this.icon);

  final String route;
  final String label;
  final IconData icon;
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.rows});

  final String title;
  final List<_InfoRow> rows;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            for (final row in rows) ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  row.label,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                subtitle: Text(
                  row.value,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              if (row != rows.last) const Divider(height: 1),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow {
  const _InfoRow(this.label, this.value);

  final String label;
  final String value;
}

String _formatDate(DateTime date) {
  final local = date.toLocal();
  return '${local.day.toString().padLeft(2, '0')}/'
      '${local.month.toString().padLeft(2, '0')}/${local.year}';
}
