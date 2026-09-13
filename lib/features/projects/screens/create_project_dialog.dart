import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/providers/projects_provider.dart';
import '../../../shared/theme/app_theme.dart';

class CreateProjectDialog extends ConsumerStatefulWidget {
  const CreateProjectDialog({super.key});

  @override
  ConsumerState<CreateProjectDialog> createState() =>
      _CreateProjectDialogState();
}

class _CreateProjectDialogState extends ConsumerState<CreateProjectDialog> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _objectivesController = TextEditingController();
  final _populationController = TextEditingController();
  final _sampleSizeController = TextEditingController();
  final _sitesController = TextEditingController();
  final _qController = TextEditingController();

  String _methodology = 'Quantitative';
  final List<String> _researchQuestions = [];
  final List<String> _studySites = [];
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _objectivesController.dispose();
    _populationController.dispose();
    _sampleSizeController.dispose();
    _sitesController.dispose();
    _qController.dispose();
    super.dispose();
  }

  void _addResearchQuestion() {
    final text = _qController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _researchQuestions.add(text);
        _qController.clear();
      });
    }
  }

  void _addStudySite() {
    final text = _sitesController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _studySites.add(text);
        _sitesController.clear();
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final sampleSize = int.tryParse(_sampleSizeController.text.trim()) ?? 100;

    await ref.read(projectsProvider.notifier).createProject(
          title: _titleController.text.trim(),
          description: _descController.text.trim(),
          objectives: _objectivesController.text.trim(),
          researchQuestions: _researchQuestions.isEmpty
              ? ['Primary research investigation']
              : _researchQuestions,
          methodology: _methodology,
          population: _populationController.text.trim().isEmpty
              ? 'General target population'
              : _populationController.text.trim(),
          sampleSize: sampleSize,
          sites: _studySites.isEmpty ? ['Campus / Community'] : _studySites,
          startDate: _startDate,
          endDate: _endDate,
        );

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 720),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.kPrimary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.create_new_folder_rounded,
                              color: AppTheme.kPrimary, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'New Research Project',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Stepper tabs
                Row(
                  children: [
                    _buildStepTab(0, '1. Basic Info'),
                    const SizedBox(width: 10),
                    _buildStepTab(1, '2. Study Design'),
                    const SizedBox(width: 10),
                    _buildStepTab(2, '3. Timeline & Sites'),
                  ],
                ),
                const Divider(height: 32),
                Expanded(
                  child: SingleChildScrollView(
                    child: _buildCurrentStepContent(),
                  ),
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_currentStep > 0)
                      OutlinedButton(
                        onPressed: () => setState(() => _currentStep--),
                        child: const Text('Back'),
                      )
                    else
                      const SizedBox.shrink(),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 12),
                        if (_currentStep < 2)
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                setState(() => _currentStep++);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.kPrimary,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Continue'),
                          )
                        else
                          ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.kPrimary,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Create Project'),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepTab(int index, String label) {
    final isActive = _currentStep == index;
    final isDone = _currentStep > index;
    return InkWell(
      onTap: () => setState(() => _currentStep = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.kPrimary.withOpacity(0.1)
              : isDone
                  ? Colors.green.shade50
                  : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive
                ? AppTheme.kPrimary
                : isDone
                    ? Colors.green.shade300
                    : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive
                ? AppTheme.kPrimary
                : isDone
                    ? Colors.green.shade700
                    : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Project Title *',
                hintText: 'e.g. Impact of Mobile Health Tech on Rural Clinics',
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Title is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Abstract / Description',
                hintText: 'Brief summary of the study context and rationale...',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _methodology,
              decoration: const InputDecoration(labelText: 'Methodology'),
              items: const [
                DropdownMenuItem(
                    value: 'Quantitative',
                    child: Text('Quantitative (Surveys/Metrics)')),
                DropdownMenuItem(
                    value: 'Qualitative',
                    child: Text('Qualitative (Interviews/Focus Groups)')),
                DropdownMenuItem(
                    value: 'Mixed-Methods',
                    child: Text('Mixed-Methods (Combined)')),
              ],
              onChanged: (v) => setState(() => _methodology = v!),
            ),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _objectivesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Primary & Secondary Objectives',
                hintText:
                    '1. Evaluate adoption rates\n2. Identify barriers to usage',
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Research Questions',
              style: GoogleFonts.poppins(
                  fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _qController,
                    decoration: const InputDecoration(
                      hintText: 'Enter a research question and click Add',
                    ),
                    onSubmitted: (_) => _addResearchQuestion(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  icon: const Icon(Icons.add),
                  onPressed: _addResearchQuestion,
                  style:
                      IconButton.styleFrom(backgroundColor: AppTheme.kPrimary),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _researchQuestions
                  .map((q) => Chip(
                        label: Text(q, style: const TextStyle(fontSize: 12)),
                        onDeleted: () =>
                            setState(() => _researchQuestions.remove(q)),
                      ))
                  .toList(),
            ),
          ],
        );
      case 2:
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _populationController,
              decoration: const InputDecoration(
                labelText: 'Study Population',
                hintText: 'e.g. University undergraduate students aged 18-25',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _sampleSizeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Target Sample Size (N)',
                hintText: 'e.g. 250',
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Study Sites / Locations',
              style: GoogleFonts.poppins(
                  fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _sitesController,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Lilongwe District Hospital',
                    ),
                    onSubmitted: (_) => _addStudySite(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  icon: const Icon(Icons.add),
                  onPressed: _addStudySite,
                  style: IconButton.styleFrom(
                      backgroundColor: AppTheme.kSecondary),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _studySites
                  .map((s) => Chip(
                        label: Text(s, style: const TextStyle(fontSize: 12)),
                        onDeleted: () => setState(() => _studySites.remove(s)),
                      ))
                  .toList(),
            ),
          ],
        );
    }
  }
}
