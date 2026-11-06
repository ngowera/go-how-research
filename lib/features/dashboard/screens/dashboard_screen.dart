import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/projects_provider.dart';
import '../../../core/providers/questionnaire_provider.dart';
import '../../../shared/theme/app_theme.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final projectsState = ref.watch(projectsProvider);
    final questionnairesState = ref.watch(questionnairesProvider);
    final totalProjects = projectsState.projects.length;
    final activeProjectCount = projectsState.projects
        .where((project) => project.status.name == 'active')
        .length;
    final totalQuestionnaires = questionnairesState.questionnaires.length;
    final activeProjects = projectsState.projects.take(4).toList();

    final greeting = _getGreeting();
    final todayStr = DateFormat('EEEE, MMMM d, y').format(DateTime.now());
    final roleName = user?.role.name ?? 'student';
    final roleLabel = '${roleName[0].toUpperCase()}${roleName.substring(1)}';

    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isPhone = constraints.maxWidth < 600;
          final isCompact = constraints.maxWidth < 900;
          return SingleChildScrollView(
            padding: EdgeInsets.all(isPhone ? 16 : 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top Header Bar ───────────────────────────────────────────────
                isCompact
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildGreeting(
                              user?.name ?? 'Researcher', greeting, todayStr,
                              fontSize: 22),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$greeting, ${user?.name ?? "Researcher"}!',
                                style: GoogleFonts.poppins(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                todayStr,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                const SizedBox(height: 28),

                // ── Quick Stats Row ──────────────────────────────────────────────
                isCompact
                    ? GridView.count(
                        crossAxisCount: constraints.maxWidth < 360 ? 1 : 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        mainAxisExtent: 124,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildStatCard(
                              compact: true,
                              title: 'Total Projects',
                              value: '$totalProjects',
                              subtitle: 'Research studies',
                              icon: Icons.folder_special_rounded,
                              accentColor: const Color(0xFF1565C0),
                              bgGradient: const [
                                Color(0xFFE3F2FD),
                                Color(0xFFBBDEFB)
                              ],
                              onTap: () => context.go('/projects')),
                          _buildStatCard(
                              compact: true,
                              title: 'Forms',
                              value: '$totalQuestionnaires',
                              subtitle: 'Data instruments',
                              icon: Icons.assignment_rounded,
                              accentColor: const Color(0xFF00897B),
                              bgGradient: const [
                                Color(0xFFE0F2F1),
                                Color(0xFFB2DFDB)
                              ],
                              onTap: () => context.go('/questionnaires')),
                          _buildStatCard(
                              compact: true,
                              title: 'Active Projects',
                              value: '$activeProjectCount',
                              subtitle: 'In progress',
                              icon: Icons.play_circle_outline_rounded,
                              accentColor: const Color(0xFFF57C00),
                              bgGradient: const [
                                Color(0xFFFFF3E0),
                                Color(0xFFFFE0B2)
                              ],
                              onTap: () => context.go('/projects')),
                          _buildStatCard(
                              compact: true,
                              title: 'Role',
                              value: roleLabel,
                              subtitle: 'Account type',
                              icon: Icons.verified_user_rounded,
                              accentColor: const Color(0xFF7B1FA2),
                              bgGradient: const [
                                Color(0xFFF3E5F5),
                                Color(0xFFE1BEE7)
                              ],
                              onTap: () => context.go('/settings')),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              title: 'Total Projects',
                              value: '$totalProjects',
                              subtitle: 'Research studies',
                              icon: Icons.folder_special_rounded,
                              accentColor: const Color(0xFF1565C0),
                              bgGradient: const [
                                Color(0xFFE3F2FD),
                                Color(0xFFBBDEFB)
                              ],
                              onTap: () => context.go('/projects'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStatCard(
                              title: 'Forms',
                              value: '$totalQuestionnaires',
                              subtitle: 'Data instruments',
                              icon: Icons.assignment_rounded,
                              accentColor: const Color(0xFF00897B),
                              bgGradient: const [
                                Color(0xFFE0F2F1),
                                Color(0xFFB2DFDB)
                              ],
                              onTap: () => context.go('/questionnaires'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStatCard(
                              title: 'Active Projects',
                              value: '$activeProjectCount',
                              subtitle: 'In progress',
                              icon: Icons.play_circle_outline_rounded,
                              accentColor: const Color(0xFFF57C00),
                              bgGradient: const [
                                Color(0xFFFFF3E0),
                                Color(0xFFFFE0B2)
                              ],
                              onTap: () => context.go('/projects'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStatCard(
                              title: 'Role',
                              value: roleLabel,
                              subtitle: 'Account type',
                              icon: Icons.verified_user_rounded,
                              accentColor: const Color(0xFF7B1FA2),
                              bgGradient: const [
                                Color(0xFFF3E5F5),
                                Color(0xFFE1BEE7)
                              ],
                              onTap: () => context.go('/settings'),
                            ),
                          ),
                        ],
                      ),
                const SizedBox(height: 32),

                // ── Quick Actions Grid ───────────────────────────────────────────
                Text(
                  'Quick Actions',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 112,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: 6,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) => [
                      _buildActionTile(
                        icon: Icons.add_circle_outline_rounded,
                        label: 'New Project',
                        color: const Color(0xFF1565C0),
                        onTap: () => context.go('/projects'),
                      ),
                      _buildActionTile(
                        icon: Icons.playlist_add_rounded,
                        label: 'Build Questionnaire',
                        color: const Color(0xFF00897B),
                        onTap: () => context.go('/questionnaires'),
                      ),
                      _buildActionTile(
                        icon: Icons.edit_note_rounded,
                        label: 'Collect Data',
                        color: const Color(0xFFF57C00),
                        onTap: () => context.go('/data-collection/default'),
                      ),
                      _buildActionTile(
                        icon: Icons.bar_chart_rounded,
                        label: 'View Analytics',
                        color: const Color(0xFF7B1FA2),
                        onTap: () {
                          if (projectsState.projects.isNotEmpty) {
                            context.go(
                                '/analytics/${projectsState.projects.first.id}');
                          } else {
                            context.go('/projects');
                          }
                        },
                      ),
                      _buildActionTile(
                        icon: Icons.person_add_outlined,
                        label: 'Participants',
                        color: const Color(0xFF2E7D32),
                        onTap: () => context.go('/participants'),
                      ),
                      _buildActionTile(
                        icon: Icons.picture_as_pdf_outlined,
                        label: 'Reports',
                        color: const Color(0xFFC62828),
                        onTap: () => context.go('/reports'),
                      ),
                    ][index],
                  ),
                ),
                const SizedBox(height: 36),

                // ── Recent Projects & Activity ───────────────────────────────────
                Wrap(
                  spacing: 20,
                  runSpacing: 16,
                  children: [
                    // Recent Projects List
                    SizedBox(
                      width: isCompact
                          ? constraints.maxWidth
                          : (constraints.maxWidth - 20) * 0.6,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                Text(
                                  'Recent Research Projects',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1E293B),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => context.go('/projects'),
                                  child: Text(
                                    'View All',
                                    style: GoogleFonts.poppins(
                                      color: AppTheme.kPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (activeProjects.isEmpty)
                              Padding(
                                padding: const EdgeInsets.all(32),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Icon(Icons.folder_open_rounded,
                                          size: 48,
                                          color: Colors.grey.shade400),
                                      const SizedBox(height: 12),
                                      Text(
                                        'No research projects created yet',
                                        style: GoogleFonts.poppins(
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      ElevatedButton.icon(
                                        onPressed: () =>
                                            context.go('/projects'),
                                        icon: const Icon(Icons.add, size: 18),
                                        label:
                                            const Text('Create First Project'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppTheme.kPrimary,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: activeProjects.length,
                                separatorBuilder: (_, __) =>
                                    const Divider(height: 20),
                                itemBuilder: (context, idx) {
                                  final p = activeProjects[idx];
                                  return InkWell(
                                    onTap: () =>
                                        context.go('/projects/${p.id}'),
                                    borderRadius: BorderRadius.circular(10),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: 44,
                                                height: 44,
                                                decoration: BoxDecoration(
                                                  color: AppTheme.kPrimary
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: const Icon(
                                                  Icons.science_rounded,
                                                  color: AppTheme.kPrimary,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                  child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    p.title,
                                                    style: GoogleFonts.poppins(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    'Target sample: ${p.sampleSize} • ${p.methodology}',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 12,
                                                      color:
                                                          Colors.grey.shade600,
                                                    ),
                                                  ),
                                                ],
                                              )),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Align(
                                              alignment: Alignment.centerRight,
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 10,
                                                        vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          Colors.green.shade50,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      border: Border.all(
                                                          color: Colors
                                                              .green.shade200),
                                                    ),
                                                    child: Text(
                                                      p.status.name
                                                          .toUpperCase(),
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors
                                                            .green.shade700,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  IconButton(
                                                    icon: const Icon(
                                                        Icons
                                                            .arrow_forward_ios_rounded,
                                                        size: 14),
                                                    onPressed: () => context.go(
                                                        '/projects/${p.id}'),
                                                  ),
                                                ],
                                              )),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                    // Offline-First & Research Tools Info
                    SizedBox(
                      width: isCompact
                          ? constraints.maxWidth
                          : (constraints.maxWidth - 20) * 0.4,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1565C0).withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                const Icon(Icons.bolt_rounded,
                                    color: Colors.amber, size: 28),
                                const SizedBox(width: 8),
                                Text(
                                  'Go-How RS-Sync',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Designed specifically for university field research in offline and online environments.',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.9),
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildFeatureBullet(
                                'Offline-first SQLite local persistence'),
                            _buildFeatureBullet(
                                'Automatic cloud sync when back online'),
                            _buildFeatureBullet(
                                'Drag-and-drop questionnaire designer'),
                            _buildFeatureBullet(
                                'Built-in descriptive & inferential statistics'),
                            _buildFeatureBullet(
                                'Supervisor review & approval workflow'),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () => context.go('/questionnaires'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppTheme.kPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'Open Questionnaire Builder',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  static Widget _buildFeatureBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded,
              size: 16, color: Colors.lightGreenAccent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildGreeting(
    String name,
    String greeting,
    String date, {
    required double fontSize,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$greeting, $name!',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          date,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  static Widget _buildStatCard({
    bool compact = false,
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required List<Color> bgGradient,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(compact ? 12 : 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: compact ? 11 : 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                )),
                Container(
                  padding: EdgeInsets.all(compact ? 6 : 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: bgGradient),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child:
                      Icon(icon, size: compact ? 15 : 18, color: accentColor),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: compact ? 20 : 26,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E293B),
              ),
            ),
            SizedBox(height: compact ? 2 : 4),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: compact ? 9 : 11,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildActionTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: 112,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF334155),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}
