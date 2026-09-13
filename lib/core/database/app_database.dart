// ignore_for_file: public_member_api_docs

import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_models.dart' as m;
import 'database_connection_stub.dart'
    if (dart.library.io) 'database_connection_native.dart'
    if (dart.library.js_interop) 'database_connection_web.dart' as connection;

part 'app_database.g.dart';

// ---------------------------------------------------------------------------
// Table definitions
// ---------------------------------------------------------------------------

class Users extends Table {
  TextColumn get id => text()();
  TextColumn get email => text()();
  TextColumn get name => text()();
  TextColumn get role => text()();
  TextColumn get institutionId => text().nullable()();
  TextColumn get avatarUrl => text().nullable()();
  TextColumn get createdAt => text()();
  BoolColumn get isCurrentUser =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class Projects extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  TextColumn get objectives => text()();
  TextColumn get researchQuestions =>
      text().withDefault(const Constant('[]'))();
  TextColumn get methodology => text()();
  TextColumn get population => text()();
  IntColumn get sampleSize => integer().withDefault(const Constant(0))();
  TextColumn get sites => text().withDefault(const Constant('[]'))();
  TextColumn get status => text()();
  TextColumn get ownerId => text()();
  TextColumn get supervisorId => text().nullable()();
  TextColumn get startDate => text().nullable()();
  TextColumn get endDate => text().nullable()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
  TextColumn get syncStatus => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('QuestionnaireRow')
class Questionnaires extends Table {
  TextColumn get id => text()();
  TextColumn get projectId => text()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  BoolColumn get isApproved => boolean().withDefault(const Constant(false))();
  BoolColumn get isPublished => boolean().withDefault(const Constant(false))();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
  TextColumn get syncStatus => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('QuestionRow')
class Questions extends Table {
  TextColumn get id => text()();
  TextColumn get questionnaireId => text()();
  IntColumn get orderIndex => integer()();
  TextColumn get questionType => text()();
  TextColumn get questionText => text()();
  TextColumn get helpText => text().nullable()();
  BoolColumn get isRequired => boolean().withDefault(const Constant(false))();
  TextColumn get optionsJson => text().withDefault(const Constant('[]'))();
  RealColumn get minValue => real().nullable()();
  RealColumn get maxValue => real().nullable()();
  TextColumn get skipLogicJson => text().nullable()();
  TextColumn get rowsJson => text().nullable()();
  TextColumn get columnsJson => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Responses extends Table {
  TextColumn get id => text()();
  TextColumn get questionnaireId => text()();
  TextColumn get participantId => text()();
  TextColumn get responsesJson => text()();
  TextColumn get collectedAt => text()();
  TextColumn get syncStatus => text()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ParticipantRow')
class Participants extends Table {
  TextColumn get id => text()();
  TextColumn get projectId => text()();
  TextColumn get code => text()();
  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  BoolColumn get hasConsented => boolean().withDefault(const Constant(false))();
  TextColumn get consentDate => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get createdAt => text()();
  TextColumn get syncStatus => text()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Durable delete queue so offline deletions are also applied in Supabase.
class SyncDeletions extends Table {
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get createdAt => text()();

  @override
  Set<Column> get primaryKey => {entityType, entityId};
}

class InterviewDrafts extends Table {
  TextColumn get id => text()();
  TextColumn get ownerId => text()();
  TextColumn get metadata => text()();
  BlobColumn get audio => blob()();
  BoolColumn get ready => boolean().withDefault(const Constant(false))();
  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// Database
// ---------------------------------------------------------------------------

@DriftDatabase(
  tables: [
    Users,
    Projects,
    Questionnaires,
    Questions,
    Responses,
    Participants,
    SyncDeletions,
    InterviewDrafts,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? connection.openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) await m.createTable(syncDeletions);
          if (from < 3) await m.createTable(interviewDrafts);
        },
      );

  // ── Users ────────────────────────────────────────────────────────────────

  Future<m.AppUser?> getCurrentUser() async {
    final row = await (select(users)
          ..where((u) => u.isCurrentUser.equals(true)))
        .getSingleOrNull();
    return row == null ? null : _userFromRow(row);
  }

  Future<void> setCurrentUser(m.AppUser user) async {
    await (update(users)..where((u) => u.isCurrentUser.equals(true)))
        .write(const UsersCompanion(isCurrentUser: Value(false)));

    await into(users).insertOnConflictUpdate(UsersCompanion.insert(
      id: user.id,
      email: user.email,
      name: user.name,
      role: user.role.name,
      institutionId: Value(user.institutionId),
      avatarUrl: Value(user.avatarUrl),
      createdAt: user.createdAt.toIso8601String(),
      isCurrentUser: const Value(true),
    ));
  }

  Future<void> clearCurrentUser() async {
    await (update(users)..where((u) => u.isCurrentUser.equals(true)))
        .write(const UsersCompanion(isCurrentUser: Value(false)));
  }

  Future<m.AppUser?> getUserByEmail(String email) async {
    final row = await (select(users)..where((u) => u.email.equals(email)))
        .getSingleOrNull();
    return row == null ? null : _userFromRow(row);
  }

  Future<void> insertUser(m.AppUser user) async {
    await upsertUser(user);
  }

  Future<void> upsertUser(m.AppUser user) async {
    await into(users).insertOnConflictUpdate(UsersCompanion.insert(
      id: user.id,
      email: user.email,
      name: user.name,
      role: user.role.name,
      institutionId: Value(user.institutionId),
      avatarUrl: Value(user.avatarUrl),
      createdAt: user.createdAt.toIso8601String(),
    ));
  }

  // ── Projects ─────────────────────────────────────────────────────────────

  Future<void> insertProject(m.ResearchProject project) async {
    await into(projects).insertOnConflictUpdate(_projectToCompanion(project));
  }

  Future<List<m.ResearchProject>> getProjects({String? ownerId}) async {
    final query = select(projects);
    final user = await getCurrentUser();
    if (user != null)
      query.where(
          (p) => p.ownerId.equals(user.id) | p.supervisorId.equals(user.id));
    if (ownerId != null) {
      query.where((p) => p.ownerId.equals(ownerId));
    }
    final rows = await query.get();
    return rows.map(_projectFromRow).toList();
  }

  Future<m.ResearchProject?> getProjectById(String id) async {
    final row = await (select(projects)..where((p) => p.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _projectFromRow(row);
  }

  Future<void> updateProject(m.ResearchProject project) async {
    await (update(projects)..where((p) => p.id.equals(project.id)))
        .write(_projectToCompanion(project));
  }

  Future<void> deleteProject(String id) async {
    await transaction(() async {
      await queueDeletion('projects', id);
      final projectQuestionnaires = await getQuestionnaires(projectId: id);
      for (final questionnaire in projectQuestionnaires) {
        await (delete(responses)
              ..where((r) => r.questionnaireId.equals(questionnaire.id)))
            .go();
        await deleteQuestionsForQuestionnaire(questionnaire.id);
        await (delete(questionnaires)
              ..where((q) => q.id.equals(questionnaire.id)))
            .go();
      }
      await (delete(participants)..where((p) => p.projectId.equals(id))).go();
      await (delete(projects)..where((p) => p.id.equals(id))).go();
    });
  }

  Future<List<m.ResearchProject>> getPendingProjects() async {
    final rows = await (select(projects)
          ..where((p) => p.syncStatus.equals(m.SyncStatus.pending.name)))
        .get();
    return rows.map(_projectFromRow).toList();
  }

  Future<void> markProjectSynced(String id) async {
    await (update(projects)..where((p) => p.id.equals(id)))
        .write(ProjectsCompanion(syncStatus: Value(m.SyncStatus.synced.name)));
  }

  Future<void> reassignProjectOwner(
      String? previousOwnerId, String ownerId) async {
    await (update(projects)
          ..where((project) => previousOwnerId == null
              ? project.ownerId.equals('local_user')
              : project.ownerId.equals(previousOwnerId) |
                  project.ownerId.equals('local_user')))
        .write(
      ProjectsCompanion(
        ownerId: Value(ownerId),
        updatedAt: Value(DateTime.now().toIso8601String()),
        syncStatus: Value(m.SyncStatus.pending.name),
      ),
    );
  }

  // ── Questionnaires ────────────────────────────────────────────────────────

  Future<void> insertQuestionnaire(m.Questionnaire q) async {
    await into(questionnaires)
        .insertOnConflictUpdate(_questionnaireToCompanion(q));
  }

  Future<List<m.Questionnaire>> getQuestionnaires({String? projectId}) async {
    final query = select(questionnaires);
    final visible = (await getProjects()).map((p) => p.id).toList();
    query.where((q) => q.projectId.isIn(visible));
    if (projectId != null) {
      query.where((q) => q.projectId.equals(projectId));
    }
    final rows = await query.get();
    return rows.map(_questionnaireFromRow).toList();
  }

  Future<m.Questionnaire?> getQuestionnaireById(String id) async {
    final row = await (select(questionnaires)..where((q) => q.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _questionnaireFromRow(row);
  }

  Future<void> updateQuestionnaire(m.Questionnaire q) async {
    await (update(questionnaires)..where((tbl) => tbl.id.equals(q.id)))
        .write(_questionnaireToCompanion(q));
  }

  Future<void> deleteQuestionnaire(String id) async {
    await transaction(() async {
      await queueDeletion('questionnaires', id);
      await (delete(responses)..where((r) => r.questionnaireId.equals(id)))
          .go();
      await deleteQuestionsForQuestionnaire(id);
      await (delete(questionnaires)..where((q) => q.id.equals(id))).go();
    });
  }

  Future<List<m.Questionnaire>> getPendingQuestionnaires() async {
    final rows = await (select(questionnaires)
          ..where((q) => q.syncStatus.equals(m.SyncStatus.pending.name)))
        .get();
    return rows.map(_questionnaireFromRow).toList();
  }

  Future<void> markQuestionnaireSynced(String id) async {
    await (update(questionnaires)..where((q) => q.id.equals(id))).write(
        QuestionnairesCompanion(syncStatus: Value(m.SyncStatus.synced.name)));
  }

  Future<void> markQuestionnairePending(String id) async {
    await (update(questionnaires)..where((q) => q.id.equals(id))).write(
      QuestionnairesCompanion(
        syncStatus: Value(m.SyncStatus.pending.name),
        updatedAt: Value(DateTime.now().toIso8601String()),
      ),
    );
  }

  // ── Questions ─────────────────────────────────────────────────────────────

  Future<void> insertQuestion(m.Question question) async {
    await into(questions)
        .insertOnConflictUpdate(_questionToCompanion(question));
  }

  Future<List<m.Question>> getQuestions(
      {required String questionnaireId}) async {
    if (!(await getQuestionnaires()).any((q) => q.id == questionnaireId))
      return [];
    final rows = await (select(questions)
          ..where((q) => q.questionnaireId.equals(questionnaireId))
          ..orderBy([(q) => OrderingTerm.asc(q.orderIndex)]))
        .get();
    return rows.map(_questionFromRow).toList();
  }

  Future<void> deleteQuestion(String id) async {
    await transaction(() async {
      await queueDeletion('questions', id);
      await (delete(questions)..where((q) => q.id.equals(id))).go();
    });
  }

  Future<void> deleteQuestionsForQuestionnaire(String questionnaireId) async {
    await (delete(questions)
          ..where((q) => q.questionnaireId.equals(questionnaireId)))
        .go();
  }

  // ── Responses ─────────────────────────────────────────────────────────────

  Future<void> insertResponse(m.QuestionnaireResponse response) async {
    await into(responses)
        .insertOnConflictUpdate(_responseToCompanion(response));
  }

  Future<List<m.QuestionnaireResponse>> getResponses({
    String? questionnaireId,
    String? participantId,
  }) async {
    final query = select(responses);
    final visible = (await getQuestionnaires()).map((q) => q.id).toList();
    query.where((r) => r.questionnaireId.isIn(visible));
    if (questionnaireId != null) {
      query.where((r) => r.questionnaireId.equals(questionnaireId));
    }
    if (participantId != null) {
      query.where((r) => r.participantId.equals(participantId));
    }
    final rows = await query.get();
    return rows.map(_responseFromRow).toList();
  }

  Future<void> deleteResponse(String id) async {
    await transaction(() async {
      await queueDeletion('responses', id);
      await (delete(responses)..where((r) => r.id.equals(id))).go();
    });
  }

  Future<List<m.QuestionnaireResponse>> getPendingResponses() async {
    final rows = await (select(responses)
          ..where((r) => r.syncStatus.equals(m.SyncStatus.pending.name)))
        .get();
    return rows.map(_responseFromRow).toList();
  }

  Future<void> markResponseSynced(String id) async {
    await (update(responses)..where((r) => r.id.equals(id)))
        .write(ResponsesCompanion(syncStatus: Value(m.SyncStatus.synced.name)));
  }

  // ── Participants ──────────────────────────────────────────────────────────

  Future<void> insertParticipant(m.Participant participant) async {
    await into(participants)
        .insertOnConflictUpdate(_participantToCompanion(participant));
  }

  Future<List<m.Participant>> getParticipants({String? projectId}) async {
    final query = select(participants);
    final visible = (await getProjects()).map((p) => p.id).toList();
    query.where((p) => p.projectId.isIn(visible));
    if (projectId != null) {
      query.where((p) => p.projectId.equals(projectId));
    }
    final rows = await query.get();
    return rows.map(_participantFromRow).toList();
  }

  Future<m.Participant?> getParticipantById(String id) async {
    final row = await (select(participants)..where((p) => p.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _participantFromRow(row);
  }

  Future<void> updateParticipant(m.Participant participant) async {
    await (update(participants)..where((p) => p.id.equals(participant.id)))
        .write(_participantToCompanion(participant));
  }

  Future<void> deleteParticipant(String id) async {
    await transaction(() async {
      await queueDeletion('participants', id);
      await (delete(participants)..where((p) => p.id.equals(id))).go();
    });
  }

  Future<List<m.Participant>> getPendingParticipants() async {
    final rows = await (select(participants)
          ..where((p) => p.syncStatus.equals(m.SyncStatus.pending.name)))
        .get();
    return rows.map(_participantFromRow).toList();
  }

  Future<void> markParticipantSynced(String id) async {
    await (update(participants)..where((p) => p.id.equals(id))).write(
        ParticipantsCompanion(syncStatus: Value(m.SyncStatus.synced.name)));
  }

  Future<void> queueDeletion(String entityType, String entityId) async {
    await into(syncDeletions).insertOnConflictUpdate(
      SyncDeletionsCompanion.insert(
        entityType: entityType,
        entityId: entityId,
        createdAt: DateTime.now().toIso8601String(),
      ),
    );
  }

  Future<List<SyncDeletion>> getPendingDeletions() =>
      (select(syncDeletions)..orderBy([(d) => OrderingTerm.asc(d.createdAt)]))
          .get();

  Future<void> removePendingDeletion(String entityType, String entityId) async {
    await (delete(syncDeletions)
          ..where((d) =>
              d.entityType.equals(entityType) & d.entityId.equals(entityId)))
        .go();
  }

  Future<Map<String, int>> getDatabaseStats() async {
    final projs = await select(projects).get();
    final quests = await select(questionnaires).get();
    final questItems = await select(questions).get();
    final resps = await select(responses).get();
    final parts = await select(participants).get();
    return {
      'projects': projs.length,
      'questionnaires': quests.length,
      'questions': questItems.length,
      'responses': resps.length,
      'participants': parts.length,
    };
  }

  Future<void> clearAllResearchData() async {
    await transaction(() async {
      await delete(interviewDrafts).go();
      await delete(responses).go();
      await delete(questions).go();
      await delete(questionnaires).go();
      await delete(participants).go();
      await delete(projects).go();
      await delete(syncDeletions).go();
    });
  }

  // ── Row converters ────────────────────────────────────────────────────────

  m.AppUser _userFromRow(User row) => m.AppUser(
        id: row.id,
        email: row.email,
        name: row.name,
        role: m.UserRole.values.firstWhere(
          (e) => e.name == row.role,
          orElse: () => m.UserRole.student,
        ),
        institutionId: row.institutionId,
        avatarUrl: row.avatarUrl,
        createdAt: DateTime.parse(row.createdAt),
      );

  m.ResearchProject _projectFromRow(Project row) => m.ResearchProject(
        id: row.id,
        title: row.title,
        description: row.description,
        objectives: row.objectives,
        researchQuestions:
            (jsonDecode(row.researchQuestions) as List).cast<String>(),
        methodology: row.methodology,
        population: row.population,
        sampleSize: row.sampleSize,
        sites: (jsonDecode(row.sites) as List).cast<String>(),
        startDate:
            row.startDate != null ? DateTime.parse(row.startDate!) : null,
        endDate: row.endDate != null ? DateTime.parse(row.endDate!) : null,
        status: m.ResearchStatus.values.firstWhere(
          (e) => e.name == row.status,
          orElse: () => m.ResearchStatus.draft,
        ),
        ownerId: row.ownerId,
        supervisorId: row.supervisorId,
        createdAt: DateTime.parse(row.createdAt),
        updatedAt: DateTime.parse(row.updatedAt),
        syncStatus: m.SyncStatus.values.firstWhere(
          (e) => e.name == row.syncStatus,
          orElse: () => m.SyncStatus.pending,
        ),
      );

  ProjectsCompanion _projectToCompanion(m.ResearchProject p) =>
      ProjectsCompanion.insert(
        id: p.id,
        title: p.title,
        description: p.description,
        objectives: p.objectives,
        researchQuestions: Value(jsonEncode(p.researchQuestions)),
        methodology: p.methodology,
        population: p.population,
        sampleSize: Value(p.sampleSize),
        sites: Value(jsonEncode(p.sites)),
        status: p.status.name,
        ownerId: p.ownerId,
        supervisorId: Value(p.supervisorId),
        startDate: Value(p.startDate?.toIso8601String()),
        endDate: Value(p.endDate?.toIso8601String()),
        createdAt: p.createdAt.toIso8601String(),
        updatedAt: p.updatedAt.toIso8601String(),
        syncStatus: p.syncStatus.name,
      );

  m.Questionnaire _questionnaireFromRow(QuestionnaireRow row) =>
      m.Questionnaire(
        id: row.id,
        projectId: row.projectId,
        title: row.title,
        description: row.description,
        version: row.version,
        isApproved: row.isApproved,
        isPublished: row.isPublished,
        createdAt: DateTime.parse(row.createdAt),
        updatedAt: DateTime.parse(row.updatedAt),
        syncStatus: m.SyncStatus.values.firstWhere(
          (e) => e.name == row.syncStatus,
          orElse: () => m.SyncStatus.pending,
        ),
      );

  QuestionnairesCompanion _questionnaireToCompanion(m.Questionnaire q) =>
      QuestionnairesCompanion.insert(
        id: q.id,
        projectId: q.projectId,
        title: q.title,
        description: q.description,
        version: Value(q.version),
        isApproved: Value(q.isApproved),
        isPublished: Value(q.isPublished),
        createdAt: q.createdAt.toIso8601String(),
        updatedAt: q.updatedAt.toIso8601String(),
        syncStatus: q.syncStatus.name,
      );

  m.Question _questionFromRow(QuestionRow row) => m.Question(
        id: row.id,
        questionnaireId: row.questionnaireId,
        order: row.orderIndex,
        type: m.QuestionType.values.firstWhere(
          (e) => e.name == row.questionType,
          orElse: () => m.QuestionType.text,
        ),
        text: row.questionText,
        helpText: row.helpText,
        isRequired: row.isRequired,
        options: (jsonDecode(row.optionsJson) as List).cast<String>(),
        minValue: row.minValue,
        maxValue: row.maxValue,
        skipLogic: row.skipLogicJson != null
            ? jsonDecode(row.skipLogicJson!) as Map<String, dynamic>
            : null,
        rows: row.rowsJson != null
            ? (jsonDecode(row.rowsJson!) as List).cast<String>()
            : [],
        columns: row.columnsJson != null
            ? (jsonDecode(row.columnsJson!) as List).cast<String>()
            : [],
      );

  QuestionsCompanion _questionToCompanion(m.Question q) =>
      QuestionsCompanion.insert(
        id: q.id,
        questionnaireId: q.questionnaireId,
        orderIndex: q.order,
        questionType: q.type.name,
        questionText: q.text,
        helpText: Value(q.helpText),
        isRequired: Value(q.isRequired),
        optionsJson: Value(jsonEncode(q.options)),
        minValue: Value(q.minValue),
        maxValue: Value(q.maxValue),
        skipLogicJson:
            Value(q.skipLogic != null ? jsonEncode(q.skipLogic) : null),
        rowsJson: Value(jsonEncode(q.rows)),
        columnsJson: Value(jsonEncode(q.columns)),
      );

  m.QuestionnaireResponse _responseFromRow(Response row) =>
      m.QuestionnaireResponse(
        id: row.id,
        questionnaireId: row.questionnaireId,
        participantId: row.participantId,
        responses: jsonDecode(row.responsesJson) as Map<String, dynamic>,
        collectedAt: DateTime.parse(row.collectedAt),
        syncStatus: m.SyncStatus.values.firstWhere(
          (e) => e.name == row.syncStatus,
          orElse: () => m.SyncStatus.pending,
        ),
        latitude: row.latitude,
        longitude: row.longitude,
      );

  ResponsesCompanion _responseToCompanion(m.QuestionnaireResponse r) =>
      ResponsesCompanion.insert(
        id: r.id,
        questionnaireId: r.questionnaireId,
        participantId: r.participantId,
        responsesJson: jsonEncode(r.responses),
        collectedAt: r.collectedAt.toIso8601String(),
        syncStatus: r.syncStatus.name,
        latitude: Value(r.latitude),
        longitude: Value(r.longitude),
      );

  m.Participant _participantFromRow(ParticipantRow row) => m.Participant(
        id: row.id,
        projectId: row.projectId,
        code: row.code,
        name: row.name,
        phone: row.phone,
        email: row.email,
        hasConsented: row.hasConsented,
        consentDate:
            row.consentDate != null ? DateTime.parse(row.consentDate!) : null,
        notes: row.notes,
        createdAt: DateTime.parse(row.createdAt),
        syncStatus: m.SyncStatus.values.firstWhere(
          (e) => e.name == row.syncStatus,
          orElse: () => m.SyncStatus.pending,
        ),
      );

  ParticipantsCompanion _participantToCompanion(m.Participant p) =>
      ParticipantsCompanion.insert(
        id: p.id,
        projectId: p.projectId,
        code: p.code,
        name: p.name,
        phone: Value(p.phone),
        email: Value(p.email),
        hasConsented: Value(p.hasConsented),
        consentDate: Value(p.consentDate?.toIso8601String()),
        notes: Value(p.notes),
        createdAt: p.createdAt.toIso8601String(),
        syncStatus: p.syncStatus.name,
      );
}

// ---------------------------------------------------------------------------
// Riverpod provider
// ---------------------------------------------------------------------------

/// Global provider for the drift [AppDatabase] instance.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
