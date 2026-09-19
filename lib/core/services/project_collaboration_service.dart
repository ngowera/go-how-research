import 'package:supabase_flutter/supabase_flutter.dart';

class ProjectAccessRequest {
  const ProjectAccessRequest({
    required this.id,
    required this.projectId,
    required this.projectTitle,
    required this.requesterId,
    required this.requesterName,
    required this.requesterEmail,
    required this.requestedRole,
    required this.status,
  });

  final String id;
  final String projectId;
  final String projectTitle;
  final String requesterId;
  final String requesterName;
  final String requesterEmail;
  final String requestedRole;
  final String status;

  factory ProjectAccessRequest.fromJson(Map<String, dynamic> json) {
    final requester = json['requester'] as Map<String, dynamic>? ?? {};
    final project = json['project'] as Map<String, dynamic>? ?? {};
    return ProjectAccessRequest(
      id: json['id'] as String,
      projectId: json['project_id'] as String,
      projectTitle: project['title'] as String? ?? json['project_id'] as String,
      requesterId: json['requester_id'] as String,
      requesterName: requester['name'] as String? ?? 'Researcher',
      requesterEmail: requester['email'] as String? ?? '',
      requestedRole: json['requested_role'] as String? ?? 'studentCollaborator',
      status: json['status'] as String? ?? 'pending',
    );
  }
}

class ProjectNotification {
  const ProjectNotification({
    required this.title,
    required this.body,
    required this.createdAt,
  });

  final String title;
  final String body;
  final DateTime createdAt;

  factory ProjectNotification.fromJson(Map<String, dynamic> json) {
    return ProjectNotification(
      title: json['title'] as String,
      body: json['body'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class ProjectMember {
  const ProjectMember({
    required this.userId,
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.role,
  });

  final String userId;
  final String name;
  final String email;
  final String? avatarUrl;
  final String role;

  String get roleLabel => switch (role) {
        'studentCollaborator' => 'Student collaborator',
        'fieldEnumerator' => 'Field enumerator',
        'ethicsReviewer' => 'Ethics reviewer',
        _ => role,
      };

  factory ProjectMember.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? {};
    return ProjectMember(
      userId: json['user_id'] as String,
      name: user['name'] as String? ?? 'Researcher',
      email: user['email'] as String? ?? '',
      avatarUrl: user['avatar_url'] as String?,
      role: json['project_role'] as String? ?? 'member',
    );
  }
}

class ProjectCollaborationService {
  SupabaseClient get _client => Supabase.instance.client;

  Future<void> requestAccess({
    required String projectId,
    required String requestedRole,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw StateError('Sign in online to join a project.');
    await _client.from('project_access_requests').insert({
      'project_id': projectId.trim(),
      'requester_id': user.id,
      'requested_role': requestedRole,
    });
  }

  Future<List<ProjectAccessRequest>> incomingRequests() async {
    final rows = await _client
        .from('project_access_requests')
        .select('id,project_id,requester_id,requested_role,status,project:projects(title),requester:users(name,email)')
        .eq('status', 'pending')
        .order('created_at', ascending: false);
    return (rows as List)
        .map((row) => ProjectAccessRequest.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  Future<void> respond({
    required String requestId,
    required bool approve,
  }) async {
    await _client.from('project_access_requests').update({
      'status': approve ? 'approved' : 'rejected',
      'responded_at': DateTime.now().toIso8601String(),
    }).eq('id', requestId);
  }

  Future<List<ProjectNotification>> notifications() async {
    final rows = await _client
        .from('notifications')
        .select('title,body,created_at')
        .order('created_at', ascending: false)
        .limit(10);
    return (rows as List)
        .map((row) => ProjectNotification.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  Future<List<ProjectMember>> membersForProject(String projectId) async {
    final rows = await _client
        .from('project_members')
        .select('user_id,project_role,user:users(name,email,avatar_url)')
        .eq('project_id', projectId);
    return (rows as List)
        .map((row) => ProjectMember.fromJson(row as Map<String, dynamic>))
        .toList();
  }
}
