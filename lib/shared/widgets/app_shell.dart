// lib/shared/widgets/app_shell.dart
import 'dart:async';

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
// Sync status enum
// ---------------------------------------------------------------------------
enum SyncStatus { synced, pending, offline }

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
const List<_NavItem> _navItems = [
  _NavItem(
    label: 'Dashboard',
    icon: Icons.dashboard_outlined,
    activeIcon: Icons.dashboard_rounded,
    route: '/dashboard',
  ),
  _NavItem(
    label: 'Projects',
    icon: Icons.folder_outlined,
    activeIcon: Icons.folder_rounded,
    route: '/projects',
  ),
  _NavItem(
    label: 'Questionnaires & Data',
    icon: Icons.edit_note_outlined,
    activeIcon: Icons.edit_note_rounded,
    route: '/data-collection/default',
  ),
  _NavItem(
    label: 'Analytics',
    icon: Icons.bar_chart_outlined,
    activeIcon: Icons.bar_chart_rounded,
    route: '/analytics/default',
  ),
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
  _NavItem(
    label: 'Settings',
    icon: Icons.settings_outlined,
    activeIcon: Icons.settings_rounded,
    route: '/settings',
  ),
];

// ---------------------------------------------------------------------------
// AppShell
// ---------------------------------------------------------------------------
class AppShell extends ConsumerWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  /// Determine the selected index from the current route location.
  int _selectedIndex(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    if (loc.startsWith('/questionnaires')) {
      return _navItems.indexWhere(
        (item) => item.route == '/data-collection/default',
      );
    }
    for (int i = 0; i < _navItems.length; i++) {
      final base = _navItems[i].route.split('/:').first.split('/default').first;
      if (loc.startsWith(base) && base.length > 1) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final settings = ref.watch(appSettingsProvider);
    final syncState = ref.watch(sync.syncProvider);
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
    final syncStatus = switch (syncState.status) {
      sync.SyncStateStatus.success => SyncStatus.synced,
      sync.SyncStateStatus.offline => SyncStatus.offline,
      _ => SyncStatus.pending,
    };
    final screenWidth = MediaQuery.sizeOf(context).width;
    final useRail = screenWidth > 800;
    final selectedIdx = _selectedIndex(context);

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
              selectedIndex: selectedIdx,
              backgroundColor: Color(settings.sidebarColor),
              user: user,
              syncStatus: syncStatus,
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
    // Narrow screen: use Drawer
    // ------------------------------------------------------------------------
    return Scaffold(
      floatingActionButton: const ResearchAssistantButton(),
      backgroundColor: AppColors.kBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: AppColors.kPrimary),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: _AppLogo(compact: true),
        actions: const [CollaborationNotificationBell(), SizedBox(width: 8)],
      ),
      drawer: Drawer(
        width: 260,
        backgroundColor: Colors.white,
        child: _Sidebar(
          selectedIndex: selectedIdx,
          backgroundColor: Color(settings.sidebarColor),
          user: user,
          syncStatus: syncStatus,
          onLogout: () async {
            await ref.read(authStateProvider.notifier).logout();
            if (context.mounted) context.go(AppRoutes.login);
          },
          onItemTap: (i) {
            Navigator.of(context).pop(); // close drawer
            context.go(_navItems[i].route);
          },
        ),
      ),
      body: child,
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
    final unreadIds = _notifications
        .where((notice) => notice.isUnread)
        .map((notice) => notice.id)
        .toList(growable: false);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF321C15),
      barrierColor: const Color(0xFF2A160F).withValues(alpha: 0.30),
      showDragHandle: true,
      builder: (context) => FractionallySizedBox(
        heightFactor: .82,
        widthFactor: MediaQuery.sizeOf(context).width < 700 ? 1 : .62,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Color(0xFF5B382C),
                      foregroundColor: Color(0xFFFFF4EA),
                      child: Icon(Icons.notifications_active_outlined),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                        child: Text(
                      'Research activity',
                      style: TextStyle(
                        color: Color(0xFFFFF4EA),
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    )),
                    IconButton(
                      tooltip: 'Close',
                      onPressed: () => Navigator.pop(context),
                      color: const Color(0xFFFFF4EA),
                      icon: const Icon(Icons.close),
                    )
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 52),
                  child: Text(
                    'Submissions, collaboration and project updates',
                    style: TextStyle(color: Color(0xFFE7CFC0), fontSize: 12),
                  ),
                ),
                const SizedBox(height: 14),
                if (_notifications.isEmpty && _requests.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 28),
                    child: Center(
                      child: Text(
                        'No new research activity yet.',
                        style: TextStyle(color: Color(0xFFE7CFC0)),
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
                              color: notice.isUnread
                                  ? const Color(0xFF5B382C)
                                  : const Color(0xFF43271E),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFE7CFC0)
                                    .withValues(alpha: 0.20),
                              ),
                            ),
                            child: ListTile(
                              leading: Icon(
                                notice.kind == 'questionnaire_submission'
                                    ? Icons.assignment_turned_in_outlined
                                    : Icons.notifications_none_rounded,
                                color: const Color(0xFFFFD7BE),
                              ),
                              title: Text(
                                notice.title,
                                style: const TextStyle(
                                  color: Color(0xFFFFF4EA),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              subtitle: Text(
                                '${notice.body}\n${_relativeTime(notice.createdAt)}',
                                style: const TextStyle(
                                  color: Color(0xFFE7CFC0),
                                ),
                              ),
                              isThreeLine: true,
                            ),
                          ),
                        ),
                        ..._requests.map(
                          (request) => ListTile(
                            leading: const Icon(
                              Icons.person_add_alt_1_outlined,
                              color: Color(0xFFFFD7BE),
                            ),
                            title: Text(request.requesterName,
                                style:
                                    const TextStyle(color: Color(0xFFFFF4EA))),
                            subtitle: Text(
                              '${request.projectTitle} • ${request.requestedRole}',
                              style: const TextStyle(color: Color(0xFFE7CFC0)),
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
                        foregroundColor: const Color(0xFFFFD7BE),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
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
          tooltip: 'Research activity',
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
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFB94A2F),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Text(
                count > 99 ? '99+' : '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
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
  final int selectedIndex;
  final _UserInfo user;
  final SyncStatus syncStatus;
  final Color backgroundColor;
  final ValueChanged<int> onItemTap;
  final VoidCallback onLogout;

  const _Sidebar({
    required this.selectedIndex,
    required this.user,
    required this.syncStatus,
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
                  _SyncDot(status: syncStatus),
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
                itemCount: _navItems.length,
                itemBuilder: (context, i) {
                  final item = _navItems[i];
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
            _UserCard(user: user, onLogout: onLogout),
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
// Sync status dot
// ---------------------------------------------------------------------------
class _SyncDot extends StatelessWidget {
  final SyncStatus status;
  const _SyncDot({required this.status});

  Color get _color {
    switch (status) {
      case SyncStatus.synced:
        return AppColors.kSuccess;
      case SyncStatus.pending:
        return AppColors.kWarning;
      case SyncStatus.offline:
        return AppColors.kError;
    }
  }

  String get _tooltip {
    switch (status) {
      case SyncStatus.synced:
        return 'Synced';
      case SyncStatus.pending:
        return 'Sync pending';
      case SyncStatus.offline:
        return 'Offline';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: _tooltip,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _color.withOpacity(0.5),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          Text(
            _tooltip,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: _color,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// User card (bottom of sidebar)
// ---------------------------------------------------------------------------
class _UserCard extends ConsumerWidget {
  final _UserInfo user;
  final VoidCallback onLogout;
  const _UserCard({required this.user, required this.onLogout});

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
                    color: AppColors.kOnSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  user.role,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: const Color(0xFF6B7280),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Logout / more options icon
          IconButton(
            icon: const Icon(
              Icons.logout_rounded,
              size: 18,
              color: Color(0xFF9CA3AF),
            ),
            tooltip: 'Sign out',
            onPressed: onLogout,
          ),
        ],
      ),
    );
  }
}
