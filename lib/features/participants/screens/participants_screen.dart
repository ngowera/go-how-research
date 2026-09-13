import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/models/app_models.dart';
import '../../../core/providers/participants_provider.dart';
import '../../../core/providers/projects_provider.dart';
import '../../../shared/theme/app_theme.dart';

class ParticipantsScreen extends ConsumerStatefulWidget {
  const ParticipantsScreen({super.key});

  @override
  ConsumerState<ParticipantsScreen> createState() => _ParticipantsScreenState();
}

class _ParticipantsScreenState extends ConsumerState<ParticipantsScreen> {
  String _search = '';
  String? _selectedProjectId;

  void _showAddParticipantDialog(BuildContext context) {
    final projects = ref.read(projectsProvider).projects;
    if (projects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please create a project first!'),
          backgroundColor: AppTheme.kWarning,
        ),
      );
      return;
    }

    String projId = _selectedProjectId ?? projects.first.id;
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    bool hasConsented = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          title: Text('Register Research Participant',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: projId,
                  decoration: const InputDecoration(labelText: 'Study Project'),
                  items: projects
                      .map((p) => DropdownMenuItem(
                            value: p.id,
                            child:
                                Text(p.title, overflow: TextOverflow.ellipsis),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setDlgState(() => projId = v);
                  },
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText:
                        'Name / pseudonym (optional — code is always assigned)',
                    hintText: 'e.g. Participant Alpha',
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: phoneCtrl,
                  decoration: const InputDecoration(labelText: 'Contact Phone'),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(labelText: 'Email Address'),
                ),
                const SizedBox(height: 14),
                SwitchListTile(
                  title: const Text('Informed Consent Obtained'),
                  subtitle: const Text('Participant signed consent protocol'),
                  value: hasConsented,
                  activeColor: AppTheme.kPrimary,
                  onChanged: (v) => setDlgState(() => hasConsented = v),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: notesCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Demographics / Field Notes',
                    hintText: 'Age group, location, referral info...',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (projId.isNotEmpty) {
                  final code = await ref
                      .read(participantsProvider.notifier)
                      .generateParticipantCode(projId);
                  await ref.read(participantsProvider.notifier).addParticipant(
                        projectId: projId,
                        code: code,
                        name: nameCtrl.text.trim(),
                        phone: phoneCtrl.text.trim().isEmpty
                            ? null
                            : phoneCtrl.text.trim(),
                        email: emailCtrl.text.trim().isEmpty
                            ? null
                            : emailCtrl.text.trim(),
                        hasConsented: hasConsented,
                        notes: notesCtrl.text.trim().isEmpty
                            ? null
                            : notesCtrl.text.trim(),
                      );
                  if (mounted) Navigator.of(ctx).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.kPrimary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Register Participant'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(participantsProvider);
    final projects = ref.watch(projectsProvider).projects;

    final participants = state.participants.where((p) {
      final matchesSearch =
          p.name.toLowerCase().contains(_search.toLowerCase()) ||
              p.code.toLowerCase().contains(_search.toLowerCase());
      final matchesProj =
          _selectedProjectId == null || p.projectId == _selectedProjectId;
      return matchesSearch && matchesProj;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Participant Registry & Ethics',
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage anonymous codes, demographics, and informed consent records',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddParticipantDialog(context),
                  icon: const Icon(Icons.person_add_rounded),
                  label: const Text('Register Participant'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.kPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Search & Filter
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText:
                          'Search by participant code (e.g. P-001) or name...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    onChanged: (v) => setState(() => _search = v),
                  ),
                ),
                const SizedBox(width: 16),
                if (projects.isNotEmpty)
                  DropdownButton<String?>(
                    value: _selectedProjectId,
                    hint: const Text('All Projects'),
                    items: [
                      const DropdownMenuItem(
                          value: null, child: Text('All Projects')),
                      ...projects.map((p) => DropdownMenuItem(
                            value: p.id,
                            child: Text(p.title),
                          )),
                    ],
                    onChanged: (v) => setState(() => _selectedProjectId = v),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // Participants List
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : participants.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.people_outline_rounded,
                                  size: 64, color: Colors.grey.shade400),
                              const SizedBox(height: 16),
                              Text(
                                'No participants registered',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Add research subjects and manage informed consent compliance.',
                                style: GoogleFonts.poppins(
                                    color: Colors.grey.shade500),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () =>
                                    _showAddParticipantDialog(context),
                                child: const Text('Register First Participant'),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          itemCount: participants.length,
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (context, idx) {
                            final p = participants[idx];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    AppTheme.kPrimary.withOpacity(0.1),
                                child: Text(
                                  p.code.replaceAll('P-', ''),
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.kPrimary,
                                  ),
                                ),
                              ),
                              title: Text(
                                '${p.code} — ${p.name}',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              subtitle: Text(
                                '${p.phone ?? "No phone"} • Registered: ${p.createdAt.toIso8601String().split('T').first}',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: p.hasConsented
                                          ? Colors.green.shade50
                                          : Colors.red.shade50,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: p.hasConsented
                                            ? Colors.green.shade300
                                            : Colors.red.shade300,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          p.hasConsented
                                              ? Icons.check_circle_rounded
                                              : Icons.cancel_rounded,
                                          size: 14,
                                          color: p.hasConsented
                                              ? Colors.green.shade700
                                              : Colors.red.shade700,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          p.hasConsented
                                              ? 'CONSENTED'
                                              : 'NO CONSENT',
                                          style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: p.hasConsented
                                                ? Colors.green.shade700
                                                : Colors.red.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline,
                                        color: Colors.red, size: 20),
                                    onPressed: () {
                                      ref
                                          .read(participantsProvider.notifier)
                                          .deleteParticipant(p.id,
                                              projectId: p.projectId);
                                    },
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
}
