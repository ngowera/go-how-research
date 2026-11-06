// lib/shared/widgets/app_shell.dart
import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';
import 'research_expert.dart';
import 'profile_avatar.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/app_settings_provider.dart';
import '../../core/providers/sync_provider.dart' as sync;
import '../../core/router/app_router.dart';
import '../../core/services/project_collaboration_service.dart';

// ---------------------------------------------------------------------------
// Internal data models
// ---------------------------------------------------------------------------
class _UserInfo {
  final String name;
  final String role;
  final String initials;
  const _UserInfo({
    required this.name,
    required this.role,
    required this.initials,
  });
}

class _NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.route,
  });
}

// ---------------------------------------------------------------------------
// Navigation items definition
// ---------------------------------------------------------------------------
const _dashboardItem = _NavItem(
  label: 'Home',
  icon: Icons.home_outlined,
  activeIcon: Icons.home_rounded,
  route: '/dashboard',
);
const _projectsItem = _NavItem(
  label: 'Projects',
  icon: Icons.folder_outlined,
  activeIcon: Icons.folder_rounded,
  route: '/projects',
);
const _dataItem = _NavItem(
  label: 'Data',
  icon: Icons.table_chart_outlined,
  activeIcon: Icons.table_chart_rounded,
  route: '/questionnaires',
);
const _analyticsItem = _NavItem(
  label: 'Analytics',
  icon: Icons.bar_chart_outlined,
  activeIcon: Icons.bar_chart_rounded,
  route: '/analytics/default',
);
const _settingsItem = _NavItem(
  label: 'Settings',
  icon: Icons.settings_outlined,
  activeIcon: Icons.settings_rounded,
  route: '/settings',
);

const List<_NavItem> _primaryNavItems = [
  _dashboardItem,
  _projectsItem,
  _dataItem,
  _analyticsItem,
  _settingsItem,
];

const List<_NavItem> _secondaryNavItems = [
  _NavItem(
    label: 'Participants',
    icon: Icons.people_outline,
    activeIcon: Icons.people_rounded,
    route: '/participants',
  ),
  _NavItem(
    label: 'Data Capture',
    icon: Icons.mic_none,
    activeIcon: Icons.mic,
    route: '/interviews',
  ),
  _NavItem(
    label: 'Supervisor',
    icon: Icons.supervisor_account_outlined,
    activeIcon: Icons.supervisor_account_rounded,
    route: '/supervisor',
  ),
  _NavItem(
    label: 'Reports',
    icon: Icons.description_outlined,
    activeIcon: Icons.description_rounded,
    route: '/reports',
  ),
];

const List<_NavItem> _navItems = [
  _dashboardItem,
  _projectsItem,
  _dataItem,
  _analyticsItem,
  ..._secondaryNavItems,
  _settingsItem,
];

// ---------------------------------------------------------------------------
// AppShell
// ---------------------------------------------------------------------------
class AppShell extends ConsumerWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  /// Determine the selected index from the current route location.
  int _selectedIndex(BuildContext context, List<_NavItem> items) {
    final loc = GoRouterState.of(context).matchedLocation;
    for (int i = 0; i < items.length; i++) {
      final base = items[i].route.split('/:').first.split('/default').first;
      if (base.length > 1 && (loc == base || loc.startsWith('$base/'))) {
        return i;
      }
    }
    return -1;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final settings = ref.watch(appSettingsProvider);
    final displayName = currentUser?.name ?? 'Local Researcher';
    final initials = displayName
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();
    final user = _UserInfo(
      name: displayName,
      role: currentUser?.role.name ?? 'offline',
      initials: initials.isEmpty ? 'LR' : initials,
    );
    final screenWidth = MediaQuery.sizeOf(context).width;
    final useRail = screenWidth > 800;
    final selectedIdx = _selectedIndex(context, _navItems);
    final selectedPhoneIdx = _selectedIndex(context, _primaryNavItems);
    final selectedDrawerIdx = _selectedIndex(context, _secondaryNavItems);

    if (useRail) {
      return Scaffold(
        floatingActionButton: const ResearchAssistantButton(),
        backgroundColor: AppColors.kBackground,
        body: Row(
          children: [
            // ----------------------------------------------------------------
            // Left sidebar
            // ----------------------------------------------------------------
            _Sidebar(
              items: _navItems,
              selectedIndex: selectedIdx,
              backgroundColor: Color(settings.sidebarColor),
              user: user,
              onLogout: () async {
                await ref.read(authStateProvider.notifier).logout();
                if (context.mounted) context.go(AppRoutes.login);
              },
              onItemTap: (i) => context.go(_navItems[i].route),
            ),
            // Vertical divider
            const VerticalDivider(
              width: 1,
              thickness: 1,
              color: Color(0xFFE5E7EB),
            ),
            // ----------------------------------------------------------------
            // Main content
            // ----------------------------------------------------------------
            Expanded(
              child: Stack(
                children: [
                  child,
                  const Positioned(
                    top: 10,
                    right: 16,
                    child: CollaborationNotificationBell(),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // ------------------------------------------------------------------------
    // Narrow screen: primary destinations stay in a glass bottom bar;
    // secondary destinations remain available from the drawer.
    // ------------------------------------------------------------------------
    return Scaffold(
      backgroundColor: AppColors.kBackground,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: Icon(Icons.menu_rounded, color: Color(settings.accentColor)),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: _AppLogo(compact: true),
        actions: const [CollaborationNotificationBell(), SizedBox(width: 8)],
      ),
      drawer: Drawer(
        width: 260,
        backgroundColor: Colors.white,
        child: SafeArea(
          child: _Sidebar(
            items: _secondaryNavItems,
            selectedIndex: selectedDrawerIdx,
            backgroundColor: Color(settings.sidebarColor),
            user: user,
            onLogout: () async {
              await ref.read(authStateProvider.notifier).logout();
              if (context.mounted) context.go(AppRoutes.login);
            },
            onItemTap: (i) {
              Navigator.of(context).pop(); // close drawer
              context.go(_secondaryNavItems[i].route);
            },
          ),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            bottom: MediaQuery.viewInsetsOf(context).bottom == 0 ? 104 : 0,
            child: SafeArea(top: false, bottom: false, child: child),
          ),
          if (MediaQuery.viewInsetsOf(context).bottom == 0)
            Align(
              alignment: Alignment.bottomCenter,
              child: _PhoneGlassNavigation(
                items: _primaryNavItems,
                selectedIndex: selectedPhoneIdx,
                darkMode: settings.darkNavigationBar,
                accentColor: Color(settings.accentColor),
                onItemTap: (i) => context.go(_primaryNavItems[i].route),
              ),
            ),
          if (MediaQuery.viewInsetsOf(context).bottom == 0)
            const ResearchAssistantButton(phoneOverlay: true),
        ],
      ),
    );
  }
}

class _PhoneGlassNavigation extends StatelessWidget {
  final List<_NavItem> items;
  final int selectedIndex;
  final bool darkMode;
  final Color accentColor;
  final ValueChanged<int> onItemTap;

  const _PhoneGlassNavigation({
    required this.items,
    required this.selectedIndex,
    required this.darkMode,
    required this.accentColor,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkSurface = darkMode;
    final foreground = isDarkSurface ? Colors.white : const Color(0xFF30343A);
    final selectedForeground =
        isDarkSurface ? Colors.white : const Color(0xFF172033);
    final mutedForeground = foreground.withValues(alpha: 0.82);
    final surface = isDarkSurface
        ? const Color(0xFF292929).withValues(alpha: .60)
        : const Color(0xFFF3F5F7).withValues(alpha: .62);
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(42),
        child: Container(
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(42),
            border: Border.all(color: accentColor.withValues(alpha: 0.72)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.20),
                blurRadius: 18,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          padding: const EdgeInsets.all(4),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(38),
                border: Border.all(color: accentColor.withValues(alpha: .36)),
              ),
              child: Row(
                children: List.generate(items.length, (index) {
                  final item = items[index];
                  final selected = selectedIndex == index;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 3, vertical: 4),
                      child: Material(
                        color: selected
                            ? accentColor.withValues(
                                alpha: isDarkSurface ? .82 : .20)
                            : Colors.transparent,
                        shape: StadiumBorder(
                          side: BorderSide(
                            color: selected
                                ? accentColor.withValues(alpha: .86)
                                : Colors.transparent,
                          ),
                        ),
                        child: InkWell(
                          customBorder: const StadiumBorder(),
                          onTap: () => onItemTap(index),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(selected ? item.activeIcon : item.icon,
                                    size: 23,
                                    color: selected
                                        ? selectedForeground
                                        : mutedForeground),
                                const SizedBox(height: 3),
                                Text(item.label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: selected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: selected
                                          ? selectedForeground
                                          : mutedForeground,
                                    )),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CollaborationNotificationBell extends ConsumerStatefulWidget {
  const CollaborationNotificationBell({super.key});

  @override
  ConsumerState<CollaborationNotificationBell> createState() =>
      _CollaborationNotificationBellState();
}

class _CollaborationNotificationBellState
    extends ConsumerState<CollaborationNotificationBell> {
  final _service = ProjectCollaborationService();
  StreamSubscription<List<ProjectNotification>>? _notificationSubscription;
  List<ProjectNotification> _notifications = const [];
  List<ProjectAccessRequest> _requests = const [];
  Set<String> _knownNotificationIds = const {};
  bool _hasInitialSnapshot = false;

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  Future<void> _startListening() async {
    await _notificationSubscription?.cancel();
    _hasInitialSnapshot = false;
    _knownNotificationIds = const {};
    try {
      _requests = await _service.incomingRequests();
      _notificationSubscription = _service.watchNotifications().listen(
        (notifications) {
          final ids = notifications.map((notice) => notice.id).toSet();
          final hasNewSubmission = _hasInitialSnapshot &&
              notifications.any((notice) =>
                  notice.kind == 'questionnaire_submission' &&
                  !_knownNotificationIds.contains(notice.id));
          _knownNotificationIds = ids;
          _hasInitialSnapshot = true;
          if (mounted) setState(() => _notifications = notifications);
          if (hasNewSubmission) {
            // The notification is committed in the same database transaction
            // as the participant and answers, so this pull is never premature.
            ref.read(sync.syncProvider.notifier).syncAll();
          }
        },
        onError: (_) {},
      );
      if (mounted) setState(() {});
    } catch (_) {
      // Offline/local-only operation remains fully supported.
    }
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }

  String _relativeTime(DateTime time) {
    final difference = DateTime.now().difference(time.toLocal());
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }

  void _showNotifications(BuildContext context) {
    final darkGlass = ref.read(appSettingsProvider).darkResearchAssistant;
    final glassText = darkGlass ? Colors.white : const Color(0xFF1E293B);
    final glassMuted =
        darkGlass ? const Color(0xFFD5DCE8) : const Color(0xFF64748B);
    final accent = Color(ref.read(appSettingsProvider).accentColor);
    final unreadIds = _notifications
        .where((notice) => notice.isUnread)
        .map((notice) => notice.id)
        .toList(growable: false);
    showDialog<void>(
      context: context,
      barrierColor: const Color(0xFF201A17).withValues(alpha: 0.48),
      builder: (context) {
        final size = MediaQuery.sizeOf(context);
        final dialogHeight = size.height < 390
            ? size.height - 48
            : (size.height * .72).clamp(280, 620);
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
              child: Container(
                decoration: BoxDecoration(
                  color: (darkGlass ? const Color(0xFF1B2230) : Colors.white)
                      .withValues(alpha: .70),
                  border: Border.all(color: accent.withValues(alpha: .45)),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: SizedBox(
                  width: (size.width - 40).clamp(0, 440).toDouble(),
                  height: dialogHeight.toDouble(),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: accent.withValues(alpha: .18),
                                foregroundColor: glassText,
                                child:
                                    Icon(Icons.notifications_active_outlined),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: Text(
                                'Notification center',
                                style: TextStyle(
                                  color: glassText,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                ),
                              )),
                              IconButton(
                                tooltip: 'Close',
                                onPressed: () => Navigator.pop(context),
                                color: glassText,
                                icon: const Icon(Icons.close),
                              )
                            ],
                          ),
                          const SizedBox(height: 14),
                          if (_notifications.isEmpty && _requests.isEmpty)
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 28),
                              child: Center(
                                child: Text(
                                  'No new research activity yet.',
                                  style: TextStyle(color: glassMuted),
                                ),
                              ),
                            )
                          else
                            Flexible(
                              child: ListView(
                                shrinkWrap: true,
                                children: [
                                  ..._notifications.map(
                                    (notice) => Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      decoration: BoxDecoration(
                                        color: glassText.withValues(
                                            alpha: notice.isUnread ? .12 : .06),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: accent.withValues(alpha: 0.20),
                                        ),
                                      ),
                                      child: ListTile(
                                        leading: Icon(
                                          notice
                                                      .kind ==
                                                  'questionnaire_submission'
                                              ? Icons
                                                  .assignment_turned_in_outlined
                                              : Icons
                                                  .notifications_none_rounded,
                                          color: accent,
                                        ),
                                        title: Text(
                                          notice.title,
                                          style: TextStyle(
                                            color: glassText,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        subtitle: Text(
                                          '${notice.body}\n${_relativeTime(notice.createdAt)}',
                                          style: TextStyle(
                                            color: glassMuted,
                                          ),
                                        ),
                                        isThreeLine: true,
                                      ),
                                    ),
                                  ),
                                  ..._requests.map(
                                    (request) => ListTile(
                                      leading: Icon(
                                        Icons.person_add_alt_1_outlined,
                                        color: accent,
                                      ),
                                      title: Text(request.requesterName,
                                          style: TextStyle(color: glassText)),
                                      subtitle: Text(
                                        '${request.projectTitle} • ${request.requestedRole}',
                                        style: TextStyle(color: glassMuted),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (_requests.isNotEmpty)
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  GoRouter.of(context).go('/settings');
                                },
                                child: const Text('Manage collaboration'),
                                style: TextButton.styleFrom(
                                  foregroundColor: accent,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
    if (unreadIds.isNotEmpty) {
      _service.markNotificationsRead(unreadIds).catchError((_) {});
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<String?>(
      currentUserProvider.select((user) => user?.id),
      (previous, next) {
        if (previous != next) _startListening();
      },
    );
    final count = _notifications.where((notice) => notice.isUnread).length +
        _requests.length;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          tooltip: 'Notification center',
          onPressed: () => _showNotifications(context),
          style: IconButton.styleFrom(
            backgroundColor: const Color(0xFFFFF1E5),
            foregroundColor: const Color(0xFF4B2A1D),
          ),
          icon: const Icon(Icons.notifications_none_rounded),
        ),
        if (count > 0)
          Positioned(
            top: 3,
            right: 3,
            child: Container(
              width: 11,
              height: 11,
              decoration: BoxDecoration(
                color: const Color(0xFFE53935),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Sidebar widget (shared between rail and drawer)
// ---------------------------------------------------------------------------
class _Sidebar extends StatelessWidget {
  final List<_NavItem> items;
  final int selectedIndex;
  final _UserInfo user;
  final Color backgroundColor;
  final ValueChanged<int> onItemTap;
  final VoidCallback onLogout;

  const _Sidebar({
    required this.items,
    required this.selectedIndex,
    required this.user,
    required this.backgroundColor,
    required this.onItemTap,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final useLightForeground = backgroundColor.computeLuminance() < 0.35;
    return SizedBox(
      width: 240,
      child: Material(
        color: backgroundColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ----------------------------------------------------------------
            // Logo + sync dot
            // ----------------------------------------------------------------
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Row(
                children: [
                  Expanded(child: _AppLogo()),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),
            const SizedBox(height: 8),

            // ----------------------------------------------------------------
            // Navigation items
            // ----------------------------------------------------------------
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: items.length,
                itemBuilder: (context, i) {
                  final item = items[i];
                  final isSelected = i == selectedIndex;
                  return _NavTile(
                    item: item,
                    isSelected: isSelected,
                    useLightForeground: useLightForeground,
                    onTap: () => onItemTap(i),
                  );
                },
              ),
            ),

            // ----------------------------------------------------------------
            // User card at bottom
            // ----------------------------------------------------------------
            const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),
            _UserCard(
              user: user,
              onLogout: onLogout,
              useLightForeground: useLightForeground,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Individual nav tile
// ---------------------------------------------------------------------------
class _NavTile extends StatelessWidget {
  final _NavItem item;
  final bool isSelected;
  final bool useLightForeground;
  final VoidCallback onTap;

  const _NavTile({
    required this.item,
    required this.isSelected,
    required this.useLightForeground,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          hoverColor: isSelected
              ? Colors.white.withOpacity(0.08)
              : AppColors.kPrimary.withOpacity(0.06),
          splashColor: AppColors.kPrimary.withOpacity(0.12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(
                  isSelected ? item.activeIcon : item.icon,
                  size: 20,
                  color: isSelected || useLightForeground
                      ? Colors.white
                      : const Color(0xFF6B7280),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.label,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected || useLightForeground
                          ? Colors.white
                          : const Color(0xFF6B7280),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// App logo
// ---------------------------------------------------------------------------
class _AppLogo extends StatelessWidget {
  final bool compact;
  const _AppLogo({this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            'app_logo.png',
            width: compact ? 30 : 36,
            height: compact ? 30 : 36,
            fit: BoxFit.cover,
            semanticLabel: 'Go-How RS',
          ),
        ),
        const SizedBox(width: 10),
        if (!compact)
          Flexible(
            child: Text(
              'GoHow\nResearch',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.kPrimary,
                height: 1.2,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          )
        else
          Text(
            'Go-How RS',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.kPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// User card (bottom of sidebar)
// ---------------------------------------------------------------------------
class _UserCard extends ConsumerWidget {
  final _UserInfo user;
  final VoidCallback onLogout;
  final bool useLightForeground;
  const _UserCard({
    required this.user,
    required this.onLogout,
    required this.useLightForeground,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Avatar
          ProfileAvatar(
            name: user.name,
            image: ref.watch(currentUserProvider)?.avatarUrl,
            radius: 18,
          ),
          const SizedBox(width: 10),
          // Name + role
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  user.name,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: useLightForeground
                        ? Colors.white
                        : const Color(0xFF1C1B1F),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  user.role,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: useLightForeground
                        ? const Color(0xFFCBD5E1)
                        : const Color(0xFF6B7280),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Logout / more options icon
          IconButton(
            icon: Icon(
              Icons.logout_rounded,
              size: 18,
              color: useLightForeground
                  ? const Color(0xFFCBD5E1)
                  : const Color(0xFF64748B),
            ),
            tooltip: 'Sign out',
            onPressed: onLogout,
          ),
        ],
      ),
    );
  }
}
