import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gohow_research/core/database/app_database.dart';
import 'package:gohow_research/core/models/app_models.dart' as models;

void main() {
  test('project deletion removes its complete local research dataset',
      () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final now = DateTime.utc(2026, 1, 1);

    await database.insertProject(models.ResearchProject(
      id: 'project-1',
      title: 'Study',
      description: 'Description',
      objectives: 'Objective',
      researchQuestions: const ['Question'],
      methodology: 'Mixed methods',
      population: 'Students',
      sampleSize: 10,
      sites: const ['Campus'],
      status: models.ResearchStatus.active,
      ownerId: 'owner-1',
      createdAt: now,
      updatedAt: now,
      syncStatus: models.SyncStatus.pending,
    ));
    await database.insertQuestionnaire(models.Questionnaire(
      id: 'questionnaire-1',
      projectId: 'project-1',
      title: 'Survey',
      description: 'Survey description',
      version: 1,
      isApproved: false,
      isPublished: true,
      createdAt: now,
      updatedAt: now,
      syncStatus: models.SyncStatus.pending,
    ));
    await database.insertQuestion(models.Question(
      id: 'question-1',
      questionnaireId: 'questionnaire-1',
      order: 1,
      type: models.QuestionType.number,
      text: 'Age',
      isRequired: true,
      options: const [],
      rows: const [],
      columns: const [],
    ));
    await database.insertResponse(models.QuestionnaireResponse(
      id: 'response-1',
      questionnaireId: 'questionnaire-1',
      participantId: 'P-001',
      responses: const {'question-1': 22},
      collectedAt: now,
      syncStatus: models.SyncStatus.pending,
    ));
    await database.insertParticipant(models.Participant(
      id: 'participant-1',
      projectId: 'project-1',
      code: 'P-001',
      name: 'Anonymous participant',
      hasConsented: true,
      consentDate: now,
      createdAt: now,
      syncStatus: models.SyncStatus.pending,
    ));

    await database.deleteProject('project-1');

    expect(await database.getProjects(), isEmpty);
    expect(await database.getQuestionnaires(projectId: 'project-1'), isEmpty);
    expect(
      await database.getQuestions(questionnaireId: 'questionnaire-1'),
      isEmpty,
    );
    expect(
      await database.getResponses(questionnaireId: 'questionnaire-1'),
      isEmpty,
    );
    expect(await database.getParticipants(projectId: 'project-1'), isEmpty);
    final deletions = await database.getPendingDeletions();
    expect(deletions, hasLength(1));
    expect(deletions.single.entityType, 'projects');
    expect(deletions.single.entityId, 'project-1');
  });

  test('individual offline deletions create durable sync tombstones', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final now = DateTime.utc(2026, 1, 1);
    await database.insertParticipant(models.Participant(
      id: 'participant-2',
      projectId: 'project-2',
      code: 'P-002',
      name: 'Test',
      hasConsented: false,
      createdAt: now,
      syncStatus: models.SyncStatus.synced,
    ));
    await database.deleteParticipant('participant-2');
    expect(await database.getParticipants(projectId: 'project-2'), isEmpty);
    expect((await database.getPendingDeletions()).single.entityType,
        'participants');
  });
}
