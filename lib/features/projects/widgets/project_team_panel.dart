import 'package:flutter/material.dart';

import '../../../core/services/project_collaboration_service.dart';
import '../../../shared/widgets/profile_avatar.dart';

class ProjectTeamPanel extends StatelessWidget {
  const ProjectTeamPanel({super.key, required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ProjectMember>>(
      future: ProjectCollaborationService().membersForProject(projectId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Team details are available when connected online.'),
          );
        }
        final members = snapshot.data ?? const <ProjectMember>[];
        if (members.isEmpty) {
          return const Center(child: Text('No shared team members yet.'));
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: members.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final member = members[index];
            return ListTile(
              leading: ProfileAvatar(
                name: member.name,
                image: member.avatarUrl,
                radius: 22,
              ),
              title: Text(member.name),
              subtitle: Text(member.email),
              trailing: Chip(label: Text(member.roleLabel)),
            );
          },
        );
      },
    );
  }
}
