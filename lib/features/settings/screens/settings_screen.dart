import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/database/app_database.dart';
import '../../../core/models/app_models.dart';
import '../../../core/providers/app_settings_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/projects_provider.dart';
import '../../../core/providers/questionnaire_provider.dart';
import '../../../core/providers/sync_provider.dart';
import '../../../core/utils/export_utils.dart';
import '../../../core/utils/sample_data_seeder.dart';
import '../../../shared/theme/app_theme.dart';
import 'appearance_card.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Controllers for Academic Profile
  late TextEditingController _nameController;
  late TextEditingController _institutionController;
  late TextEditingController _deptController;
  late TextEditingController _orcidController;

  Map<String, int> _dbStats = {
    'projects': 0,
    'questionnaires': 0,
    'questions': 0,
    'responses': 0,
    'participants': 0,
  };
  bool _isLoadingStats = true;
  bool _isSeeding = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    final user = ref.read(currentUserProvider);
    final settings = ref.read(appSettingsProvider);

    _nameController = TextEditingController(text: user?.name ?? '');
    _institutionController = TextEditingController(
        text: user?.institutionId ?? 'University Department of Research');
    _deptController = TextEditingController(text: settings.department);
    _orcidController = TextEditingController(text: settings.orcidId);

    _refreshDbStats();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _institutionController.dispose();
    _deptController.dispose();
    _orcidController.dispose();
    super.dispose();
  }

  Future<void> _refreshDbStats() async {
    setState(() => _isLoadingStats = true);
    try {
      final db = ref.read(databaseProvider);
      final stats = await db.getDatabaseStats();
      if (mounted) {
        setState(() {
          _dbStats = stats;
          _isLoadingStats = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingStats = false);
    }
  }

  Future<void> _seedData() async {
    setState(() => _isSeeding = true);
    try {
      final db = ref.read(databaseProvider);
      await SampleDataSeeder.seedComprehensiveSampleStudy(db);
      await ref.read(projectsProvider.notifier).loadProjects();
      await ref.read(questionnairesProvider.notifier).loadQuestionnaires();
      await _refreshDbStats();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Sample research study seeded successfully! (1 Project, 1 Survey, 7 Questions, 15 Responses)',
            ),
            backgroundColor: AppTheme.kSuccess,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to seed data: $e'),
            backgroundColor: AppTheme.kError,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSeeding = false);
    }
  }

  Future<void> _exportDatabaseBackup() async {
    try {
      final db = ref.read(databaseProvider);
      final projs = await db.getProjects();
      final quests = await db.getQuestionnaires();
      final resps = await db.getResponses();
      final parts = await db.getParticipants();

      final backupData = {
        'version': '1.0.0',
        'exportedAt': DateTime.now().toIso8601String(),
        'projects': projs.map((p) => p.toJson()).toList(),
        'questionnaires': quests.map((q) => q.toJson()).toList(),
        'responses': resps.map((r) => r.toJson()).toList(),
        'participants': parts.map((p) => p.toJson()).toList(),
      };

      final jsonStr = const JsonEncoder.withIndent('  ').convert(backupData);
      final filename =
          'gohow_research_backup_${DateTime.now().millisecondsSinceEpoch}.json';
      await ExportUtils.exportFile(
        filename,
        utf8.encode(jsonStr),
        mimeType: 'application/json',
        subject: 'GoHow Research Database Backup JSON',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Database snapshot exported as $filename'),
            backgroundColor: AppTheme.kSuccess,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup error: $e'),
            backgroundColor: AppTheme.kError,
          ),
        );
      }
    }
  }

  Future<void> _confirmClearDatabase() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.red),
            const SizedBox(width: 8),
            Text('Clear Local Database?',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ],
        ),
        content: Text(
          'This will delete all locally stored projects, questionnaires, responses, participants, and interview recordings waiting to upload. Unsynced data cannot be recovered.\n\nYour user account and credentials will be preserved. Data already synced to the server is not deleted.',
          style: GoogleFonts.poppins(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete Everything',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final db = ref.read(databaseProvider);
      await db.clearAllResearchData();
      await ref.read(projectsProvider.notifier).loadProjects();
      await ref.read(questionnairesProvider.notifier).loadQuestionnaires();
      await _refreshDbStats();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Local research database has been cleared.'),
            backgroundColor: AppTheme.kPrimary,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final syncState = ref.watch(syncProvider);
    final settings = ref.watch(appSettingsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top Header Bar ───────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Settings & System Hub',
                          style: GoogleFonts.poppins(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.kPrimary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: AppTheme.kPrimary.withOpacity(0.3)),
                          ),
                          child: Text(
                            'v1.0.0 Release',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.kPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage researcher identity, survey defaults, SQLite offline storage, and cloud sync',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                // Quick actions on top
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: _refreshDbStats,
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: const Text('Refresh'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await ref.read(authStateProvider.notifier).logout();
                        if (mounted) context.go('/login');
                      },
                      icon: const Icon(Icons.logout_rounded, size: 16),
                      label: const Text('Sign Out'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Segmented Navigation Tabs ────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelColor: AppTheme.kPrimary,
                unselectedLabelColor: const Color(0xFF64748B),
                indicatorColor: AppTheme.kPrimary,
                indicatorWeight: 3,
                labelStyle: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                tabs: const [
                  Tab(
                      icon: Icon(Icons.badge_outlined, size: 18),
                      text: 'Academic Profile'),
                  Tab(
                      icon: Icon(Icons.tune_rounded, size: 18),
                      text: 'Field & Survey Defaults'),
                  Tab(
                      icon: Icon(Icons.analytics_outlined, size: 18),
                      text: 'Statistical Engine'),
                  Tab(
                      icon: Icon(Icons.cloud_sync_outlined, size: 18),
                      text: 'Offline & Cloud Sync'),
                  Tab(
                      icon: Icon(Icons.storage_rounded, size: 18),
                      text: 'Database & Storage Health'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Tab Views Content ────────────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAcademicProfileTab(user),
                  _buildSurveyDefaultsTab(settings),
                  _buildStatisticalEngineTab(settings),
                  _buildCloudSyncTab(syncState, settings),
                  _buildDatabaseStorageTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // TAB 1: Academic Profile & Identity
  // ===========================================================================
  Widget _buildAcademicProfileTab(AppUser? user) {
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Card
              const AppearanceCard(),
              Container(
                padding: const EdgeInsets.all(24),
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
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: AppTheme.kPrimary.withOpacity(0.12),
                      child: Text(
                        (user?.name.isNotEmpty ?? false)
                            ? user!.name.substring(0, 1).toUpperCase()
                            : 'R',
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.kPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'Lead Researcher',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.email ?? 'researcher@university.edu',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppTheme.kPrimary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'ROLE: ${user?.role.name.toUpperCase() ?? "STUDENT"}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.kPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'AUTHENTICATED',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Academic Information Form
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Researcher Information & Affiliations',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'This information appears automatically on generated research reports and ethics summaries.',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Full Name & Title',
                              hintText: 'e.g. Dr. Alex M. Gondwe, MSc',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _institutionController,
                            decoration: const InputDecoration(
                              labelText: 'University / Research Center',
                              hintText:
                                  'e.g. Kamuzu University of Health Sciences',
                              prefixIcon: Icon(Icons.account_balance_outlined),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _deptController,
                            decoration: const InputDecoration(
                              labelText: 'Department / Faculty',
                              hintText:
                                  'e.g. Faculty of Public Health & Epidemiology',
                              prefixIcon: Icon(Icons.domain_outlined),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _orcidController,
                            decoration: const InputDecoration(
                              labelText: 'ORCID iD (Academic Identifier)',
                              hintText: '0000-0002-1825-0097',
                              prefixIcon: Icon(Icons.fingerprint_outlined),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Account role is informational, not a permission switch.
                    Text(
                      'Account role',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Your current role is highlighted below. Changing your profile does not change your account permissions.',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _roleChip(
                            UserRole.student,
                            'Student Researcher',
                            Icons.school_rounded,
                            const Color(0xFF1565C0),
                            user?.role),
                        _roleChip(
                            UserRole.supervisor,
                            'Academic Supervisor',
                            Icons.supervisor_account_rounded,
                            const Color(0xFF7B1FA2),
                            user?.role),
                        _roleChip(
                            UserRole.enumerator,
                            'Field Enumerator',
                            Icons.assignment_ind_rounded,
                            const Color(0xFF00897B),
                            user?.role),
                        _roleChip(
                            UserRole.ethicsOfficer,
                            'Ethics Reviewer',
                            Icons.verified_user_rounded,
                            const Color(0xFF2E7D32),
                            user?.role),
                        _roleChip(
                            UserRole.admin,
                            'Institution Admin',
                            Icons.admin_panel_settings_rounded,
                            const Color(0xFFF57C00),
                            user?.role),
                      ],
                    ),
                    const SizedBox(height: 28),

                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await ref
                              .read(authStateProvider.notifier)
                              .updateProfile(
                                name: _nameController.text.trim(),
                                institutionId:
                                    _institutionController.text.trim(),
                              );
                          await ref
                              .read(appSettingsProvider.notifier)
                              .updateDepartment(_deptController.text.trim());
                          await ref
                              .read(appSettingsProvider.notifier)
                              .updateOrcid(_orcidController.text.trim());

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Academic Profile updated successfully!'),
                                backgroundColor: AppTheme.kSuccess,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.check_rounded, size: 18),
                        label: const Text('Save Profile Changes'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.kPrimary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roleChip(UserRole role, String label, IconData icon, Color color,
      UserRole? currentRole) {
    final isSelected = currentRole == role;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : color),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF334155),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // TAB 2: Field & Survey Defaults
  // ===========================================================================
  Widget _buildSurveyDefaultsTab(AppSettings settings) {
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Data Collection & Fieldwork Preferences',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Customize how questionnaire forms behave for field enumerators and respondents.',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
                const Divider(height: 32),

                // Form display mode
                _buildSettingTile(
                  title: 'Survey Form Display Layout',
                  subtitle:
                      'Choose whether survey questions appear as one long scrollable page or step-by-step.',
                  child: Row(
                    children: [
                      ChoiceChip(
                        label: const Text('Scrollable Single-Page'),
                        selected: settings.formDisplayMode ==
                            FormDisplayMode.singlePage,
                        selectedColor: AppTheme.kPrimary.withOpacity(0.15),
                        onSelected: (v) {
                          if (v) {
                            ref
                                .read(appSettingsProvider.notifier)
                                .updateDisplayMode(FormDisplayMode.singlePage);
                          }
                        },
                      ),
                      const SizedBox(width: 10),
                      ChoiceChip(
                        label: const Text('Focus Mode (Question-by-Question)'),
                        selected:
                            settings.formDisplayMode == FormDisplayMode.paged,
                        selectedColor: AppTheme.kPrimary.withOpacity(0.15),
                        onSelected: (v) {
                          if (v) {
                            ref
                                .read(appSettingsProvider.notifier)
                                .updateDisplayMode(FormDisplayMode.paged);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(height: 28),

                // Auto save interval
                _buildSettingTile(
                  title: 'Field Response Auto-Save Interval',
                  subtitle:
                      'Additional draft checkpoints on this device; changed answers are also saved immediately.',
                  child: DropdownButton<int>(
                    value: settings.autoSaveSeconds,
                    items: const [
                      DropdownMenuItem(
                          value: 15, child: Text('Every 15 Seconds')),
                      DropdownMenuItem(
                          value: 30, child: Text('Every 30 Seconds (Default)')),
                      DropdownMenuItem(
                          value: 60, child: Text('Every 60 Seconds')),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        ref
                            .read(appSettingsProvider.notifier)
                            .updateAutoSave(v);
                      }
                    },
                  ),
                ),
                const Divider(height: 28),

                // GPS Geolocation Tagging
                _buildSettingTile(
                  title: 'GPS Geolocation Tagging',
                  subtitle:
                      'Automatic GPS capture is not available in this version.',
                  child: Switch.adaptive(
                    value: false,
                    activeColor: const Color(0xFF00897B),
                    onChanged: null,
                  ),
                ),
                const Divider(height: 28),

                // Participant Code Prefix
                _buildSettingTile(
                  title: 'Default Participant Anonymization Prefix',
                  subtitle:
                      'Prefix used when generating unique participant tracking codes.',
                  child: SizedBox(
                    width: 140,
                    child: TextFormField(
                      initialValue: settings.participantPrefix,
                      decoration: const InputDecoration(
                        hintText: 'P-',
                        isDense: true,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onChanged: (v) {
                        ref
                            .read(appSettingsProvider.notifier)
                            .updateParticipantPrefix(v);
                      },
                    ),
                  ),
                ),
                const Divider(height: 28),
                _buildSettingTile(
                  title: 'Participant Identity Display',
                  subtitle:
                      'Every response retains an identification code. Choose whether authorized screens and exports also display the registered real name.',
                  child: DropdownButton<ParticipantIdentityMode>(
                    value: settings.participantIdentityMode,
                    items: const [
                      DropdownMenuItem(
                        value: ParticipantIdentityMode.codeOnly,
                        child: Text('Identification code only'),
                      ),
                      DropdownMenuItem(
                        value: ParticipantIdentityMode.nameAndCode,
                        child: Text('Real name + code'),
                      ),
                    ],
                    onChanged: (mode) {
                      if (mode != null) {
                        ref
                            .read(appSettingsProvider.notifier)
                            .updateParticipantIdentityMode(mode);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // TAB 3: Statistical Engine Defaults
  // ===========================================================================
  Widget _buildStatisticalEngineTab(AppSettings settings) {
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Statistical Analysis & Formula Engine',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Configure inferential parameters, significance criteria, and scientific reporting rules.',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
                const Divider(height: 32),

                // Significance level
                _buildSettingTile(
                  title: 'Statistical Significance Threshold (α)',
                  subtitle:
                      'Controls the significance decision. It does not change the p-value; confidence intervals remain 95%.',
                  child: DropdownButton<double>(
                    value: settings.confidenceLevel,
                    items: const [
                      DropdownMenuItem(
                          value: 0.05,
                          child: Text('p < 0.05 (95% Confidence Level)')),
                      DropdownMenuItem(
                          value: 0.01,
                          child: Text('p < 0.01 (99% High Confidence)')),
                      DropdownMenuItem(
                          value: 0.001,
                          child:
                              Text('p < 0.001 (99.9% Very High Confidence)')),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        ref
                            .read(appSettingsProvider.notifier)
                            .updateConfidenceLevel(v);
                      }
                    },
                  ),
                ),
                const Divider(height: 28),

                // Decimal precision
                _buildSettingTile(
                  title: 'Decimal Precision in Tables & Stats',
                  subtitle:
                      'Number of decimal places shown for mean, median, variance, and standard deviation.',
                  child: DropdownButton<int>(
                    value: settings.decimalPrecision,
                    items: const [
                      DropdownMenuItem(
                          value: 2, child: Text('2 Decimals (e.g. 3.45)')),
                      DropdownMenuItem(
                          value: 3, child: Text('3 Decimals (e.g. 3.452)')),
                      DropdownMenuItem(
                          value: 4, child: Text('4 Decimals (e.g. 3.4521)')),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        ref
                            .read(appSettingsProvider.notifier)
                            .updateDecimalPrecision(v);
                      }
                    },
                  ),
                ),
                const Divider(height: 28),

                // Academic Citation Format
                _buildSettingTile(
                  title: 'Citation Style for Generated Reports',
                  subtitle:
                      'Saved writing preference. Current statistical reports do not generate literature citations.',
                  child: DropdownButton<CitationStyle>(
                    value: settings.citationStyle,
                    items: const [
                      DropdownMenuItem(
                          value: CitationStyle.apa7,
                          child: Text('APA 7th Edition')),
                      DropdownMenuItem(
                          value: CitationStyle.harvard,
                          child: Text('Harvard Referencing')),
                      DropdownMenuItem(
                          value: CitationStyle.ieee,
                          child: Text('IEEE Technical')),
                      DropdownMenuItem(
                          value: CitationStyle.chicago,
                          child: Text('Chicago Manual of Style')),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        ref
                            .read(appSettingsProvider.notifier)
                            .updateCitationStyle(v);
                      }
                    },
                  ),
                ),
                const Divider(height: 28),

                // Chart Color Palette
                _buildSettingTile(
                  title: 'Default Chart Palette',
                  subtitle:
                      'Color theme applied to distribution bar charts and pie charts in Analytics.',
                  child: DropdownButton<String>(
                    value: settings.chartPalette,
                    items: const [
                      DropdownMenuItem(
                          value: 'Academic Blue & Teal',
                          child: Text('Academic Blue & Teal (Standard)')),
                      DropdownMenuItem(
                          value: 'Vibrant Multi-Color',
                          child: Text('Vibrant Multi-Color')),
                      DropdownMenuItem(
                          value: 'Emerald & Mint',
                          child: Text('Emerald & Mint')),
                      DropdownMenuItem(
                          value: 'Warm Sunset Orange',
                          child: Text('Warm Sunset Orange')),
                      DropdownMenuItem(
                          value: 'Colorblind Friendly',
                          child: Text('Colorblind friendly')),
                      DropdownMenuItem(
                          value: 'Grayscale', child: Text('Grayscale')),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        ref
                            .read(appSettingsProvider.notifier)
                            .updateChartPalette(v);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // TAB 4: Offline & Cloud Sync
  // ===========================================================================
  Widget _buildCloudSyncTab(SyncState syncState, AppSettings settings) {
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: Column(
            children: [
              // Sync Status Overview
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00897B).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.cloud_sync_rounded,
                                  color: Color(0xFF00897B), size: 24),
                            ),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Supabase Cloud Sync Engine',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1E293B),
                                  ),
                                ),
                                Text(
                                  'Offline SQLite ↔ Supabase PostgreSQL',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: syncState.status == SyncStateStatus.syncing
                              ? null
                              : () async {
                                  await ref
                                      .read(syncProvider.notifier)
                                      .syncAll();
                                  if (!mounted) return;
                                  final r = ref.read(syncProvider);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text(r.message ?? 'Sync finished'),
                                      backgroundColor:
                                          r.status == SyncStateStatus.success
                                              ? AppTheme.kSuccess
                                              : Colors.orange.shade800,
                                    ),
                                  );
                                },
                          icon: syncState.status == SyncStateStatus.syncing
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.sync_rounded, size: 16),
                          label: Text(
                              syncState.status == SyncStateStatus.syncing
                                  ? 'Syncing...'
                                  : 'Sync Now'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00897B),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        _metricBadge(
                            'Pending Push',
                            '${syncState.pendingCount} records',
                            const Color(0xFFF57C00)),
                        const SizedBox(width: 14),
                        _metricBadge(
                            'Engine State',
                            syncState.status.name.toUpperCase(),
                            syncState.status == SyncStateStatus.success
                                ? const Color(0xFF2E7D32)
                                : const Color(0xFF1565C0)),
                        const SizedBox(width: 14),
                        _metricBadge(
                          'Last Synced',
                          syncState.lastSyncTime != null
                              ? syncState.lastSyncTime!
                                  .toIso8601String()
                                  .split('T')
                                  .last
                                  .substring(0, 5)
                              : 'Never',
                          Colors.grey.shade700,
                        ),
                      ],
                    ),
                    const Divider(height: 32),

                    // Auto sync toggle
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Automatic Background Synchronization',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        'When enabled, pushes and pulls authenticated research data every 10 seconds and after internet reconnection.',
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: Colors.grey.shade600),
                      ),
                      value: settings.autoSyncOnReconnect,
                      activeColor: const Color(0xFF00897B),
                      onChanged: (v) {
                        ref
                            .read(appSettingsProvider.notifier)
                            .updateAutoSync(v);
                      },
                    ),
                    const SizedBox(height: 14),

                    // Security card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.shield_outlined,
                              size: 22, color: Color(0xFF00897B)),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Protected Credentials (.env)',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Your Supabase Project URL and Anon Key are securely loaded from the project root .env file and never exposed in the UI.',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // TAB 5: Database & Storage Health
  // ===========================================================================
  Widget _buildDatabaseStorageTab() {
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Counters Row
              Row(
                children: [
                  Expanded(
                    child: _statBox(
                      title: 'Projects',
                      count: _isLoadingStats
                          ? '...'
                          : '${_dbStats['projects'] ?? 0}',
                      icon: Icons.folder_rounded,
                      color: const Color(0xFF1565C0),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _statBox(
                      title: 'Questionnaires',
                      count: _isLoadingStats
                          ? '...'
                          : '${_dbStats['questionnaires'] ?? 0}',
                      icon: Icons.assignment_rounded,
                      color: const Color(0xFF00897B),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _statBox(
                      title: 'Questions',
                      count: _isLoadingStats
                          ? '...'
                          : '${_dbStats['questions'] ?? 0}',
                      icon: Icons.help_outline_rounded,
                      color: const Color(0xFFF57C00),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _statBox(
                      title: 'Responses',
                      count: _isLoadingStats
                          ? '...'
                          : '${_dbStats['responses'] ?? 0}',
                      icon: Icons.table_chart_rounded,
                      color: const Color(0xFF7B1FA2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _statBox(
                      title: 'Participants',
                      count: _isLoadingStats
                          ? '...'
                          : '${_dbStats['participants'] ?? 0}',
                      icon: Icons.people_rounded,
                      color: const Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Action Cards Container
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Database Tools & Mock Data Generator',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Utilities to seed realistic academic datasets, backup your research SQLite store, or reset local caches.',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const Divider(height: 32),

                    // Seed Sample Data Tool
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.kPrimary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.dataset_rounded,
                              color: AppTheme.kPrimary),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Load Sample Research Study (Instant Test Dataset)',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Seeds a complete study with 1 questionnaire, 7 questions, and 15 completed responses to test charts, cross-tabs, and reports.',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _isSeeding ? null : _seedData,
                          icon: _isSeeding
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.download_rounded, size: 16),
                          label: Text(
                              _isSeeding ? 'Seeding...' : 'Load Sample Study'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.kPrimary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 28),

                    // Export Backup
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00897B).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.file_download_outlined,
                              color: Color(0xFF00897B)),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Export Database Snapshot (JSON Backup)',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Creates an offline JSON archive containing all projects, questionnaires, responses, and participants.',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: _exportDatabaseBackup,
                          icon: const Icon(Icons.save_alt_rounded, size: 16),
                          label: const Text('Export JSON'),
                        ),
                      ],
                    ),
                    const Divider(height: 28),

                    // Clear Database
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.delete_sweep_rounded,
                              color: Colors.red),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Clear Local Research Database',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red.shade700,
                                ),
                              ),
                              Text(
                                'Resets all local study tables and deletes cached survey responses.',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _confirmClearDatabase,
                          icon: const Icon(Icons.delete_forever_rounded,
                              size: 16),
                          label: const Text('Reset Data'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade600,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helper Widgets ─────────────────────────────────────────────────────────

  Widget _buildSettingTile({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        child,
      ],
    );
  }

  Widget _metricBadge(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 11, fontWeight: FontWeight.w600, color: color)),
            const SizedBox(height: 2),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statBox({
    required String title,
    required String count,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            count,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
            ),
          ),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
