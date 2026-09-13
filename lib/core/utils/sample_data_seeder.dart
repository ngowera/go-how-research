import 'dart:math';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';
import '../models/app_models.dart';

class SampleDataSeeder {
  static const _uuid = Uuid();

  static Future<void> seedComprehensiveSampleStudy(AppDatabase db) async {
    final now = DateTime.now();
    final projectId = _uuid.v4();

    // 1. Create Research Project
    final project = ResearchProject(
      id: projectId,
      title: 'Digital Health & Mobile Diagnostics Adoption Study',
      description:
          'A multi-site investigation evaluating the operational efficacy, clinician acceptance, and data latency of mobile diagnostics deployed in rural and peri-urban community health centers.',
      objectives:
          '1. Assess user satisfaction and usability of mobile health record systems.\n2. Determine correlation between clinical experience and digital diagnostic workflow turnaround.\n3. Measure infrastructure barriers impacting offline data synchronization.',
      researchQuestions: [
        'How does mobile diagnostic tool usage impact diagnostic turnaround time?',
        'What are the primary institutional barriers to digital tool adherence among healthcare workers?',
        'Is there a statistically significant association between formal training and clinician satisfaction scores?',
      ],
      methodology: 'Mixed-Methods',
      population:
          'Registered nurses, clinical technicians, and community health officers stationed in district clinics.',
      sampleSize: 100,
      sites: [
        'Lilongwe District Hospital',
        'Blantyre Community Clinic',
        'Zomba Central Health Post'
      ],
      status: ResearchStatus.active,
      ownerId: 'local_user',
      startDate: now.subtract(const Duration(days: 30)),
      endDate: now.add(const Duration(days: 90)),
      createdAt: now.subtract(const Duration(days: 30)),
      updatedAt: now,
      syncStatus: SyncStatus.pending,
    );
    await db.insertProject(project);

    // 2. Create Questionnaire
    final questionnaireId = _uuid.v4();
    final questionnaire = Questionnaire(
      id: questionnaireId,
      projectId: projectId,
      title: 'Healthcare Worker Digital Diagnostic Usability Survey',
      description:
          'Please answer each question candidly. All responses remain anonymized and contribute to national healthcare technology evaluation.',
      version: 1,
      isApproved: true,
      isPublished: true,
      createdAt: now.subtract(const Duration(days: 20)),
      updatedAt: now,
      syncStatus: SyncStatus.pending,
    );
    await db.insertQuestionnaire(questionnaire);

    // 3. Create Questions
    final q1Id = _uuid.v4(); // Single choice
    final q2Id = _uuid.v4(); // Number
    final q3Id = _uuid.v4(); // Likert
    final q4Id = _uuid.v4(); // Likert
    final q5Id = _uuid.v4(); // Rating
    final q6Id = _uuid.v4(); // Yes/No
    final q7Id = _uuid.v4(); // Text

    final questions = [
      Question(
        id: q1Id,
        questionnaireId: questionnaireId,
        order: 1,
        type: QuestionType.singleChoice,
        text: 'What is your primary clinical designation?',
        helpText:
            'Select the role that best describes your daily responsibilities.',
        isRequired: true,
        options: [
          'Medical Officer',
          'Clinical Officer',
          'Registered Nurse',
          'Community Health Worker'
        ],
        rows: [],
        columns: [],
      ),
      Question(
        id: q2Id,
        questionnaireId: questionnaireId,
        order: 2,
        type: QuestionType.number,
        text: 'How many years have you been practicing in healthcare?',
        helpText: 'Enter total years of active service.',
        isRequired: true,
        options: [],
        minValue: 1,
        maxValue: 40,
        rows: [],
        columns: [],
      ),
      Question(
        id: q3Id,
        questionnaireId: questionnaireId,
        order: 3,
        type: QuestionType.likertScale,
        text:
            'Digital mobile tools have significantly reduced patient wait times at our clinic.',
        helpText: '1 = Strongly Disagree, 5 = Strongly Agree',
        isRequired: true,
        options: [],
        rows: [],
        columns: [],
      ),
      Question(
        id: q4Id,
        questionnaireId: questionnaireId,
        order: 4,
        type: QuestionType.likertScale,
        text:
            'The offline data collection features allow uninterrupted work during network outages.',
        helpText: '1 = Strongly Disagree, 5 = Strongly Agree',
        isRequired: true,
        options: [],
        rows: [],
        columns: [],
      ),
      Question(
        id: q5Id,
        questionnaireId: questionnaireId,
        order: 5,
        type: QuestionType.rating,
        text:
            'Overall satisfaction rating with mobile health app interface usability.',
        helpText: '1 to 5 stars',
        isRequired: true,
        options: [],
        rows: [],
        columns: [],
      ),
      Question(
        id: q6Id,
        questionnaireId: questionnaireId,
        order: 6,
        type: QuestionType.yesNo,
        text:
            'Have you received formal institutional training on mobile electronic health records?',
        helpText: 'Select YES or NO.',
        isRequired: true,
        options: [],
        rows: [],
        columns: [],
      ),
      Question(
        id: q7Id,
        questionnaireId: questionnaireId,
        order: 7,
        type: QuestionType.text,
        text:
            'What is the single greatest technical challenge encountered during field data logging?',
        helpText:
            'Brief sentence or phrase describing any hardware or software bottlenecks.',
        isRequired: false,
        options: [],
        rows: [],
        columns: [],
      ),
    ];

    for (final q in questions) {
      await db.insertQuestion(q);
    }

    // 4. Create 15 Participants and 15 Responses
    final roles = [
      'Medical Officer',
      'Clinical Officer',
      'Registered Nurse',
      'Community Health Worker'
    ];
    final challenges = [
      'Battery depletion in off-grid rural sites',
      'Occasional slow synchronization over 2G networks',
      'Small screen size on older tablet devices',
      'Screen glare during outdoor community visits',
      'Need for more automated data validation cues',
      'Lack of backup hardware during peak hours',
    ];

    final rand = Random(42);

    for (int i = 1; i <= 15; i++) {
      final code = 'P-${i.toString().padLeft(3, '0')}';
      final participantId = _uuid.v4();

      final participant = Participant(
        id: participantId,
        projectId: projectId,
        code: code,
        name: 'Clinician Subject $i',
        phone: '+265 99 812 30${i.toString().padLeft(2, '0')}',
        email: 'clinician$i@moh-health.mw',
        hasConsented: true,
        consentDate: now.subtract(Duration(days: 15 - i)),
        notes: 'Enrolled under IRB Protocol 2026-DH-04',
        createdAt: now.subtract(Duration(days: 15 - i)),
        syncStatus: SyncStatus.pending,
      );
      await db.insertParticipant(participant);

      final role = roles[rand.nextInt(roles.length)];
      final years = 2 + rand.nextInt(18);
      final likertWait = 3 + rand.nextInt(3); // 3, 4, or 5
      final likertOffline = 4 + (rand.nextBool() ? 1 : 0); // 4 or 5
      final rating = 3 + rand.nextInt(3); // 3, 4, 5
      final trained = rand.nextDouble() > 0.3 ? 'YES' : 'NO';
      final challenge = challenges[rand.nextInt(challenges.length)];

      final respData = {
        q1Id: role,
        q2Id: years.toString(),
        q3Id: likertWait,
        q4Id: likertOffline,
        q5Id: rating,
        q6Id: trained,
        q7Id: challenge,
      };

      final response = QuestionnaireResponse(
        id: _uuid.v4(),
        questionnaireId: questionnaireId,
        participantId: code,
        responses: respData,
        collectedAt:
            now.subtract(Duration(days: 14 - i, hours: rand.nextInt(8))),
        syncStatus: SyncStatus.pending,
        latitude: -13.9626 + (rand.nextDouble() - 0.5) * 0.1,
        longitude: 33.7741 + (rand.nextDouble() - 0.5) * 0.1,
      );
      await db.insertResponse(response);
    }
  }
}
