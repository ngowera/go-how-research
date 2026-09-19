import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/project_collaboration_service.dart';
import '../../../shared/theme/app_theme.dart';

class ProjectCollaborationCard extends ConsumerStatefulWidget {
  const ProjectCollaborationCard({super.key});

  @override
  ConsumerState<ProjectCollaborationCard> createState() =>
      _ProjectCollaborationCardState();
}

class _ProjectCollaborationCardState
    extends ConsumerState<ProjectCollaborationCard> {
  final projectIdController = TextEditingController();
  final service = ProjectCollaborationService();
  String requestedRole = 'studentCollaborator';
  List<ProjectAccessRequest> requests = const [];
  List<ProjectNotification> notifications = const [];
  bool busy = false;
  String? message;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  @override
  void dispose() {
    projectIdController.dispose();
    super.dispose();
  }

  Future<void> _loadRequests() async {
    try {
      final result = await service.incomingRequests();
      final notices = await service.notifications();
      if (mounted) {
        setState(() {
          requests = result;
          notifications = notices;
        });
      }
    } catch (_) {
      // Supabase may be intentionally unavailable in offline mode.
    }
  }

  Future<void> _requestAccess() async {
    if (projectIdController.text.trim().isEmpty) {
      setState(() => message = 'Enter the project ID first.');
      return;
    }
    setState(() {
      busy = true;
      message = null;
    });
    try {
      await service.requestAccess(
        projectId: projectIdController.text,
        requestedRole: requestedRole,
      );
      projectIdController.clear();
      setState(() => message = 'Request sent to the project owner.');
    } catch (error) {
      setState(() => message = error.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _respond(ProjectAccessRequest request, bool approve) async {
    setState(() => busy = true);
    try {
      await service.respond(requestId: request.id, approve: approve);
      await _loadRequests();
    } catch (error) {
      if (mounted) setState(() => message = error.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Project Collaboration',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  )),
          const SizedBox(height: 4),
          Text(
            'Join a research project by ID or review requests from researchers who want to work with you.',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth < 560;
              final projectField = TextField(
                controller: projectIdController,
                decoration: const InputDecoration(
                  labelText: 'Project ID',
                  hintText: 'Paste the project ID',
                  prefixIcon: Icon(Icons.key_outlined),
                ),
              );
              final roleField = DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: requestedRole,
                decoration: const InputDecoration(labelText: 'Role'),
                items: const [
                  DropdownMenuItem(
                      value: 'studentCollaborator',
                      child: Text('Student collaborator')),
                  DropdownMenuItem(
                      value: 'supervisor', child: Text('Supervisor')),
                  DropdownMenuItem(
                      value: 'fieldEnumerator',
                      child: Text('Field enumerator')),
                  DropdownMenuItem(
                      value: 'ethicsReviewer', child: Text('Ethics reviewer')),
                ],
                onChanged: busy
                    ? null
                    : (value) => setState(() => requestedRole = value!),
              );
              return narrow
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        projectField,
                        const SizedBox(height: 12),
                        roleField,
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(child: projectField),
                        const SizedBox(width: 12),
                        Expanded(child: roleField),
                      ],
                    );
            },
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: busy ? null : _requestAccess,
            icon: const Icon(Icons.group_add_outlined),
            label: const Text('Request project access'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.kPrimary,
              foregroundColor: Colors.white,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 10),
            Text(message!, style: TextStyle(color: Colors.grey.shade700)),
          ],
          if (requests.isNotEmpty) ...[
            const Divider(height: 28),
            const Text('Access requests',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            ...requests.map(
              (request) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                    child: Icon(Icons.person_add_alt_1_outlined)),
                title: Text('${request.requesterName} wants to join'),
                subtitle: Text(
                    '${request.requesterEmail}\n${request.projectTitle} • ${request.requestedRole}'),
                isThreeLine: true,
                trailing: Wrap(
                  spacing: 4,
                  children: [
                    IconButton(
                      tooltip: 'Approve',
                      onPressed: busy ? null : () => _respond(request, true),
                      icon: const Icon(Icons.check_circle_outline,
                          color: Colors.green),
                    ),
                    IconButton(
                      tooltip: 'Reject',
                      onPressed: busy ? null : () => _respond(request, false),
                      icon:
                          const Icon(Icons.cancel_outlined, color: Colors.red),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (notifications.isNotEmpty) ...[
            const Divider(height: 28),
            const Text('Notifications',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            ...notifications.map(
              (notification) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.notifications_none_rounded),
                title: Text(notification.title),
                subtitle: Text(notification.body),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
