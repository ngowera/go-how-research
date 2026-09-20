// ignore_for_file: public_member_api_docs

import 'dart:convert';

// ---------------------------------------------------------------------------
// Enums
// ---------------------------------------------------------------------------

enum UserRole { student, supervisor, admin, enumerator, ethicsOfficer }

enum SyncStatus { synced, pending, failed, offline }

enum QuestionType {
  text,
  number,
  singleChoice,
  multipleChoice,
  likertScale,
  rating,
  date,
  matrix,
  yesNo,
  thumbs,
}

enum ResearchStatus { draft, active, completed, archived, paused }

// ---------------------------------------------------------------------------
// AppUser
// ---------------------------------------------------------------------------

class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.institutionId,
    this.avatarUrl,
    required this.createdAt,
  });

  final String id;
  final String email;
  final String name;
  final UserRole role;
  final String? institutionId;
  final String? avatarUrl;
  final DateTime createdAt;

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] as String,
        email: json['email'] as String,
        name: json['name'] as String,
        role: UserRole.values.firstWhere(
          (e) => e.name == json['role'],
          orElse: () => UserRole.student,
        ),
        institutionId: json['institution_id'] as String?,
        avatarUrl: json['avatar_url'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'role': role.name,
        'institution_id': institutionId,
        'avatar_url': avatarUrl,
        'created_at': createdAt.toIso8601String(),
      };

  AppUser copyWith({
    String? id,
    String? email,
    String? name,
    UserRole? role,
    String? institutionId,
    String? avatarUrl,
    DateTime? createdAt,
  }) =>
      AppUser(
        id: id ?? this.id,
        email: email ?? this.email,
        name: name ?? this.name,
        role: role ?? this.role,
        institutionId: institutionId ?? this.institutionId,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppUser &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email &&
          name == other.name &&
          role == other.role &&
          institutionId == other.institutionId &&
          avatarUrl == other.avatarUrl &&
          createdAt == other.createdAt;

  @override
  int get hashCode =>
      Object.hash(id, email, name, role, institutionId, avatarUrl, createdAt);

  @override
  String toString() =>
      'AppUser(id: $id, email: $email, name: $name, role: ${role.name})';
}

// ---------------------------------------------------------------------------
// ResearchProject
// ---------------------------------------------------------------------------

class ResearchProject {
  const ResearchProject({
    required this.id,
    required this.title,
    required this.description,
    required this.objectives,
    required this.researchQuestions,
    required this.methodology,
    required this.population,
    required this.sampleSize,
    required this.sites,
    this.startDate,
    this.endDate,
    required this.status,
    required this.ownerId,
    this.supervisorId,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
  });

  final String id;
  final String title;
  final String description;
  final String objectives;
  final List<String> researchQuestions;
  final String methodology;
  final String population;
  final int sampleSize;
  final List<String> sites;
  final DateTime? startDate;
  final DateTime? endDate;
  final ResearchStatus status;
  final String ownerId;
  final String? supervisorId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final SyncStatus syncStatus;

  factory ResearchProject.fromJson(Map<String, dynamic> json) =>
      ResearchProject(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        objectives: json['objectives'] as String,
        researchQuestions: _parseStringList(json['research_questions']),
        methodology: json['methodology'] as String,
        population: json['population'] as String,
        sampleSize: (json['sample_size'] as num).toInt(),
        sites: _parseStringList(json['sites']),
        startDate: json['start_date'] != null
            ? DateTime.parse(json['start_date'] as String)
            : null,
        endDate: json['end_date'] != null
            ? DateTime.parse(json['end_date'] as String)
            : null,
        status: ResearchStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => ResearchStatus.draft,
        ),
        ownerId: json['owner_id'] as String,
        supervisorId: json['supervisor_id'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
        syncStatus: SyncStatus.values.firstWhere(
          (e) => e.name == json['sync_status'],
          orElse: () => SyncStatus.pending,
        ),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'objectives': objectives,
        'research_questions': researchQuestions,
        'methodology': methodology,
        'population': population,
        'sample_size': sampleSize,
        'sites': sites,
        'start_date': startDate?.toIso8601String(),
        'end_date': endDate?.toIso8601String(),
        'status': status.name,
        'owner_id': ownerId,
        'supervisor_id': supervisorId,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  ResearchProject copyWith({
    String? id,
    String? title,
    String? description,
    String? objectives,
    List<String>? researchQuestions,
    String? methodology,
    String? population,
    int? sampleSize,
    List<String>? sites,
    DateTime? startDate,
    DateTime? endDate,
    ResearchStatus? status,
    String? ownerId,
    String? supervisorId,
    DateTime? createdAt,
    DateTime? updatedAt,
    SyncStatus? syncStatus,
  }) =>
      ResearchProject(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        objectives: objectives ?? this.objectives,
        researchQuestions: researchQuestions ?? this.researchQuestions,
        methodology: methodology ?? this.methodology,
        population: population ?? this.population,
        sampleSize: sampleSize ?? this.sampleSize,
        sites: sites ?? this.sites,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        status: status ?? this.status,
        ownerId: ownerId ?? this.ownerId,
        supervisorId: supervisorId ?? this.supervisorId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        syncStatus: syncStatus ?? this.syncStatus,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResearchProject &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          status == other.status &&
          syncStatus == other.syncStatus;

  @override
  int get hashCode => Object.hash(id, title, status, syncStatus);

  @override
  String toString() =>
      'ResearchProject(id: $id, title: $title, status: ${status.name})';
}

// ---------------------------------------------------------------------------
// Questionnaire
// ---------------------------------------------------------------------------

class Questionnaire {
  const Questionnaire({
    required this.id,
    required this.projectId,
    required this.title,
    required this.description,
    required this.version,
    required this.isApproved,
    required this.isPublished,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
  });

  final String id;
  final String projectId;
  final String title;
  final String description;
  final int version;
  final bool isApproved;
  final bool isPublished;
  final DateTime createdAt;
  final DateTime updatedAt;
  final SyncStatus syncStatus;

  factory Questionnaire.fromJson(Map<String, dynamic> json) => Questionnaire(
        id: json['id'] as String,
        projectId: json['project_id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        version: (json['version'] as num).toInt(),
        isApproved: json['is_approved'] as bool? ?? false,
        isPublished: json['is_published'] as bool? ?? false,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
        syncStatus: SyncStatus.values.firstWhere(
          (e) => e.name == json['sync_status'],
          orElse: () => SyncStatus.pending,
        ),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'project_id': projectId,
        'title': title,
        'description': description,
        'version': version,
        'is_approved': isApproved,
        'is_published': isPublished,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  Questionnaire copyWith({
    String? id,
    String? projectId,
    String? title,
    String? description,
    int? version,
    bool? isApproved,
    bool? isPublished,
    DateTime? createdAt,
    DateTime? updatedAt,
    SyncStatus? syncStatus,
  }) =>
      Questionnaire(
        id: id ?? this.id,
        projectId: projectId ?? this.projectId,
        title: title ?? this.title,
        description: description ?? this.description,
        version: version ?? this.version,
        isApproved: isApproved ?? this.isApproved,
        isPublished: isPublished ?? this.isPublished,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        syncStatus: syncStatus ?? this.syncStatus,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Questionnaire &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          version == other.version;

  @override
  int get hashCode => Object.hash(id, version);

  @override
  String toString() =>
      'Questionnaire(id: $id, title: $title, version: $version)';
}

// ---------------------------------------------------------------------------
// Question
// ---------------------------------------------------------------------------

class Question {
  const Question({
    required this.id,
    required this.questionnaireId,
    required this.order,
    required this.type,
    required this.text,
    this.helpText,
    required this.isRequired,
    required this.options,
    this.minValue,
    this.maxValue,
    this.skipLogic,
    required this.rows,
    required this.columns,
  });

  final String id;
  final String questionnaireId;
  final int order;
  final QuestionType type;
  final String text;
  final String? helpText;
  final bool isRequired;
  final List<String> options;
  final double? minValue;
  final double? maxValue;
  final Map<String, dynamic>? skipLogic;
  final List<String> rows;
  final List<String> columns;

  factory Question.fromJson(Map<String, dynamic> json) => Question(
        id: json['id'] as String,
        questionnaireId: json['questionnaire_id'] as String,
        order: (json['order_index'] ?? json['order'] as num).toInt(),
        type: QuestionType.values.firstWhere(
          (e) => e.name == (json['question_type'] ?? json['type']),
          orElse: () => QuestionType.text,
        ),
        text: (json['question_text'] ?? json['text']) as String,
        helpText: json['help_text'] as String?,
        isRequired: json['is_required'] as bool? ?? false,
        options: _parseStringList(json['options_json'] ?? json['options']),
        minValue: (json['min_value'] as num?)?.toDouble(),
        maxValue: (json['max_value'] as num?)?.toDouble(),
        skipLogic: (json['skip_logic_json'] ?? json['skip_logic']) != null
            ? ((json['skip_logic_json'] ?? json['skip_logic']) is String
                ? jsonDecode((json['skip_logic_json'] ?? json['skip_logic'])
                    as String) as Map<String, dynamic>
                : (json['skip_logic_json'] ?? json['skip_logic'])
                    as Map<String, dynamic>)
            : null,
        rows: _parseStringList(json['rows_json'] ?? json['rows']),
        columns: _parseStringList(json['columns_json'] ?? json['columns']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'questionnaire_id': questionnaireId,
        'order_index': order,
        'question_type': type.name,
        'question_text': text,
        'help_text': helpText,
        'is_required': isRequired,
        'options_json': options,
        'min_value': minValue,
        'max_value': maxValue,
        'skip_logic_json': skipLogic,
        'rows_json': rows,
        'columns_json': columns,
      };

  Question copyWith({
    String? id,
    String? questionnaireId,
    int? order,
    QuestionType? type,
    String? text,
    String? helpText,
    bool? isRequired,
    List<String>? options,
    double? minValue,
    double? maxValue,
    Map<String, dynamic>? skipLogic,
    List<String>? rows,
    List<String>? columns,
  }) =>
      Question(
        id: id ?? this.id,
        questionnaireId: questionnaireId ?? this.questionnaireId,
        order: order ?? this.order,
        type: type ?? this.type,
        text: text ?? this.text,
        helpText: helpText ?? this.helpText,
        isRequired: isRequired ?? this.isRequired,
        options: options ?? this.options,
        minValue: minValue ?? this.minValue,
        maxValue: maxValue ?? this.maxValue,
        skipLogic: skipLogic ?? this.skipLogic,
        rows: rows ?? this.rows,
        columns: columns ?? this.columns,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Question &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          order == other.order;

  @override
  int get hashCode => Object.hash(id, order);

  @override
  String toString() => 'Question(id: $id, order: $order, type: ${type.name})';
}

// ---------------------------------------------------------------------------
// QuestionnaireResponse
// ---------------------------------------------------------------------------

class QuestionnaireResponse {
  const QuestionnaireResponse({
    required this.id,
    required this.questionnaireId,
    required this.participantId,
    required this.responses,
    required this.collectedAt,
    required this.syncStatus,
    this.latitude,
    this.longitude,
  });

  final String id;
  final String questionnaireId;
  final String participantId;
  final Map<String, dynamic> responses;
  final DateTime collectedAt;
  final SyncStatus syncStatus;
  final double? latitude;
  final double? longitude;

  factory QuestionnaireResponse.fromJson(Map<String, dynamic> json) =>
      QuestionnaireResponse(
        id: json['id'] as String,
        questionnaireId: json['questionnaire_id'] as String,
        participantId: json['participant_id'] as String,
        responses: (json['responses_json'] ?? json['responses']) is String
            ? jsonDecode(
                    (json['responses_json'] ?? json['responses']) as String)
                as Map<String, dynamic>
            : (json['responses_json'] ?? json['responses'])
                as Map<String, dynamic>,
        collectedAt: DateTime.parse(json['collected_at'] as String),
        syncStatus: SyncStatus.values.firstWhere(
          (e) => e.name == json['sync_status'],
          orElse: () => SyncStatus.pending,
        ),
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'questionnaire_id': questionnaireId,
        'participant_id': participantId,
        'responses_json': responses,
        'collected_at': collectedAt.toIso8601String(),
        'latitude': latitude,
        'longitude': longitude,
      };

  QuestionnaireResponse copyWith({
    String? id,
    String? questionnaireId,
    String? participantId,
    Map<String, dynamic>? responses,
    DateTime? collectedAt,
    SyncStatus? syncStatus,
    double? latitude,
    double? longitude,
  }) =>
      QuestionnaireResponse(
        id: id ?? this.id,
        questionnaireId: questionnaireId ?? this.questionnaireId,
        participantId: participantId ?? this.participantId,
        responses: responses ?? this.responses,
        collectedAt: collectedAt ?? this.collectedAt,
        syncStatus: syncStatus ?? this.syncStatus,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuestionnaireResponse &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'QuestionnaireResponse(id: $id, questionnaireId: $questionnaireId)';
}

// ---------------------------------------------------------------------------
// Participant
// ---------------------------------------------------------------------------

class Participant {
  const Participant({
    required this.id,
    required this.projectId,
    required this.code,
    required this.name,
    this.phone,
    this.email,
    required this.hasConsented,
    this.consentDate,
    this.notes,
    required this.createdAt,
    required this.syncStatus,
  });

  final String id;
  final String projectId;
  final String code;
  final String name;
  final String? phone;
  final String? email;
  final bool hasConsented;
  final DateTime? consentDate;
  final String? notes;
  final DateTime createdAt;
  final SyncStatus syncStatus;

  factory Participant.fromJson(Map<String, dynamic> json) => Participant(
        id: json['id'] as String,
        projectId: json['project_id'] as String,
        code: json['code'] as String,
        name: json['name'] as String,
        phone: json['phone'] as String?,
        email: json['email'] as String?,
        hasConsented: json['has_consented'] as bool? ?? false,
        consentDate: json['consent_date'] != null
            ? DateTime.parse(json['consent_date'] as String)
            : null,
        notes: json['notes'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
        syncStatus: SyncStatus.values.firstWhere(
          (e) => e.name == json['sync_status'],
          orElse: () => SyncStatus.pending,
        ),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'project_id': projectId,
        'code': code,
        'name': name,
        'phone': phone,
        'email': email,
        'has_consented': hasConsented,
        'consent_date': consentDate?.toIso8601String(),
        'notes': notes,
        'created_at': createdAt.toIso8601String(),
      };

  Participant copyWith({
    String? id,
    String? projectId,
    String? code,
    String? name,
    String? phone,
    String? email,
    bool? hasConsented,
    DateTime? consentDate,
    String? notes,
    DateTime? createdAt,
    SyncStatus? syncStatus,
  }) =>
      Participant(
        id: id ?? this.id,
        projectId: projectId ?? this.projectId,
        code: code ?? this.code,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        email: email ?? this.email,
        hasConsented: hasConsented ?? this.hasConsented,
        consentDate: consentDate ?? this.consentDate,
        notes: notes ?? this.notes,
        createdAt: createdAt ?? this.createdAt,
        syncStatus: syncStatus ?? this.syncStatus,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Participant &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          code == other.code;

  @override
  int get hashCode => Object.hash(id, code);

  @override
  String toString() => 'Participant(id: $id, code: $code, name: $name)';
}

// ---------------------------------------------------------------------------
// AnalyticsResult
// ---------------------------------------------------------------------------

class AnalyticsResult {
  const AnalyticsResult({
    required this.questionId,
    required this.questionText,
    required this.type,
    required this.frequencies,
    this.mean,
    this.median,
    this.stdDev,
    this.min,
    this.max,
    required this.count,
    required this.chartData,
  });

  final String questionId;
  final String questionText;
  final QuestionType type;
  final Map<String, int> frequencies;
  final double? mean;
  final double? median;
  final double? stdDev;
  final double? min;
  final double? max;
  final int count;
  final List<Map<String, dynamic>> chartData;

  factory AnalyticsResult.fromJson(Map<String, dynamic> json) =>
      AnalyticsResult(
        questionId: json['question_id'] as String,
        questionText: json['question_text'] as String,
        type: QuestionType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => QuestionType.text,
        ),
        frequencies: (json['frequencies'] as Map<String, dynamic>? ?? {})
            .map((k, v) => MapEntry(k, (v as num).toInt())),
        mean: (json['mean'] as num?)?.toDouble(),
        median: (json['median'] as num?)?.toDouble(),
        stdDev: (json['std_dev'] as num?)?.toDouble(),
        min: (json['min'] as num?)?.toDouble(),
        max: (json['max'] as num?)?.toDouble(),
        count: (json['count'] as num).toInt(),
        chartData: (json['chart_data'] as List<dynamic>? ?? [])
            .map((e) => e as Map<String, dynamic>)
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'question_id': questionId,
        'question_text': questionText,
        'type': type.name,
        'frequencies': frequencies,
        'mean': mean,
        'median': median,
        'std_dev': stdDev,
        'min': min,
        'max': max,
        'count': count,
        'chart_data': chartData,
      };

  AnalyticsResult copyWith({
    String? questionId,
    String? questionText,
    QuestionType? type,
    Map<String, int>? frequencies,
    double? mean,
    double? median,
    double? stdDev,
    double? min,
    double? max,
    int? count,
    List<Map<String, dynamic>>? chartData,
  }) =>
      AnalyticsResult(
        questionId: questionId ?? this.questionId,
        questionText: questionText ?? this.questionText,
        type: type ?? this.type,
        frequencies: frequencies ?? this.frequencies,
        mean: mean ?? this.mean,
        median: median ?? this.median,
        stdDev: stdDev ?? this.stdDev,
        min: min ?? this.min,
        max: max ?? this.max,
        count: count ?? this.count,
        chartData: chartData ?? this.chartData,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnalyticsResult &&
          runtimeType == other.runtimeType &&
          questionId == other.questionId;

  @override
  int get hashCode => questionId.hashCode;

  @override
  String toString() =>
      'AnalyticsResult(questionId: $questionId, count: $count)';
}

// ---------------------------------------------------------------------------
// Private helpers
// ---------------------------------------------------------------------------

List<String> _parseStringList(dynamic value) {
  if (value == null) return [];
  if (value is List) return value.cast<String>();
  if (value is String) {
    final decoded = jsonDecode(value);
    if (decoded is List) return decoded.cast<String>();
  }
  return [];
}
