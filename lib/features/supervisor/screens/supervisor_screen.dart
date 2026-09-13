import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/models/app_models.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/projects_provider.dart';
import '../../../core/providers/questionnaire_provider.dart';
import '../../../shared/theme/app_theme.dart';

class SupervisorScreen extends ConsumerWidget {
  const SupervisorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final projectsState = ref.watch(projectsProvider);
    final questionnairesState = ref.watch(questionnairesProvider);

    final pendingQuestionnaires =
        questionnairesState.questionnaires.where((q) => !q.isApproved).toList();
    final approvedQuestionnaires =
        questionnairesState.questionnaires.where((q) => q.isApproved).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Supervisor Collaboration Portal',
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Academic review, questionnaire validation, ethics oversight and feedback',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7B1FA2).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: const Color(0xFF7B1FA2).withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.school_rounded,
                          color: Color(0xFF7B1FA2), size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Role: ${user?.role.name.toUpperCase() ?? "SUPERVISOR"}',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: const Color(0xFF7B1FA2),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Overview cards
            Row(
              children: [
                Expanded(
                  child: _buildCountCard(
                    title: 'Supervised Projects',
                    count: '${projectsState.projects.length}',
                    icon: Icons.folder_special_rounded,
                    color: const Color(0xFF1565C0),
                    bg: const Color(0xFFE3F2FD),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildCountCard(
                    title: 'Pending Review',
                    count: '${pendingQuestionnaires.length}',
                    icon: Icons.pending_actions_rounded,
                    color: const Color(0xFFF57C00),
                    bg: const Color(0xFFFFF3E0),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildCountCard(
                    title: 'Approved Instruments',
                    count: '${approvedQuestionnaires.length}',
                    icon: Icons.verified_rounded,
                    color: const Color(0xFF2E7D32),
                    bg: const Color(0xFFE8F5E9),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Pending Approvals Section
            Text(
              'Instruments Awaiting Supervisor Approval',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: pendingQuestionnaires.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.thumb_up_alt_outlined,
                              size: 56, color: Colors.green.shade300),
                          const SizedBox(height: 12),
                          Text(
                            'All questionnaires reviewed & approved!',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'No pending instruments currently require supervisor sign-off.',
                            style: GoogleFonts.poppins(
                                color: Colors.grey.shade500, fontSize: 13),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: pendingQuestionnaires.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, idx) {
                        final q = pendingQuestionnaires[idx];
                        return Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.orange.shade200),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.assignment_late_rounded,
                                  color: Color(0xFFF57C00),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      q.title,
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF1E293B),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Version ${q.version} • Submitted for validation • ${q.description}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              OutlinedButton.icon(
                                onPressed: () => context
                                    .go('/questionnaires/${q.id}/builder'),
                                icon: const Icon(Icons.visibility_outlined,
                                    size: 16),
                                label: const Text('Review Questions'),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton.icon(
                                onPressed: () {
                                  ref
                                      .read(questionnairesProvider.notifier)
                                      .approveQuestionnaire(q.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Questionnaire successfully approved! Field data collection unlocked.'),
                                      backgroundColor: AppTheme.kSuccess,
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.check_circle_outline,
                                    size: 16),
                                label: const Text('Approve Instrument'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2E7D32),
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountCard({
    required String title,
    required String count,
    required IconData icon,
    required Color color,
    required Color bg,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                count,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
