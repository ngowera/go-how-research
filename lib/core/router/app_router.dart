// lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Shell
import '../../shared/widgets/app_shell.dart';

// Auth screens
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';

// Dashboard
import '../../features/dashboard/screens/dashboard_screen.dart';

// Projects
import '../../features/projects/screens/projects_screen.dart';
import '../../features/projects/screens/project_detail_screen.dart';

// Questionnaires
import '../../features/questionnaires/screens/questionnaires_screen.dart';
import '../../features/questionnaires/screens/questionnaire_builder_screen.dart';
import '../../features/questionnaires/screens/public_questionnaire_screen.dart';

// Data Collection
import '../../features/data_collection/screens/data_collection_screen.dart';

// Data
import '../../features/data/screens/data_table_screen.dart';

// Analytics
import '../../features/analytics/screens/analytics_screen.dart';

// Participants
import '../../features/participants/screens/participants_screen.dart';

// Supervisor
import '../../features/supervisor/screens/supervisor_screen.dart';

// Reports
import '../../features/reports/screens/reports_screen.dart';

// Settings
import '../../features/settings/screens/settings_screen.dart';
import '../../features/interviews/interviews_screen.dart';
import '../../features/analytics/screens/analysis_project_picker.dart';
import '../providers/interviews_provider.dart';
import '../providers/auth_provider.dart';
import '../models/app_models.dart';

// ---------------------------------------------------------------------------
// Navigator keys
// ---------------------------------------------------------------------------
final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

// ---------------------------------------------------------------------------
// Helper: read authentication status from SharedPreferences
// ---------------------------------------------------------------------------
Future<bool> _isAuthenticated() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('isLoggedIn') ?? false;
}

// ---------------------------------------------------------------------------
// Route path constants
// ---------------------------------------------------------------------------
class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String projects = '/projects';
  static const String questionnaires = '/questionnaires';
  static const String participants = '/participants';
  static const String supervisor = '/supervisor';
  static const String reports = '/reports';
  static const String settings = '/settings';

  // Parameterised helpers
  static String projectDetail(String id) => '/projects/$id';
  static String questionnaireBuilder(String id) =>
      '/questionnaires/$id/builder';
  static String dataCollection(String questionnaireId) =>
      '/data-collection/$questionnaireId';
  static String dataTable(String projectId) => '/data/$projectId';
  static String analytics(String projectId) => '/analytics/$projectId';
}

// ---------------------------------------------------------------------------
// Router Riverpod provider
// ---------------------------------------------------------------------------
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.dashboard,
    debugLogDiagnostics: true,

    // -------------------------------------------------------------------------
    // Global redirect: unauthenticated → /login
    // -------------------------------------------------------------------------
    redirect: (BuildContext context, GoRouterState state) async {
      // Global redirects may not yet have a matched route name.
      final segments = state.uri.pathSegments;
      const privateRoots = {'login','register','dashboard','projects',
        'questionnaires','participants','supervisor','reports','settings',
        'interviews','analytics','data','data-collection'};
      if (segments.length == 1 &&
          !privateRoots.contains(segments.first) &&
          RegExp(r'^[a-z0-9][a-z0-9-]{5,59}$').hasMatch(segments.first)) {
        return null;
      }
      final authenticated = await _isAuthenticated();
      final loc = state.matchedLocation;

      final isOnAuth = loc == AppRoutes.login || loc == AppRoutes.register;

      if (!authenticated && !isOnAuth) {
        // Preserve intended destination for post-login deep-link
        return '${AppRoutes.login}?from=${Uri.encodeComponent(loc)}';
      }

      // Already logged in → skip auth pages
      if (authenticated && isOnAuth) {
        return AppRoutes.dashboard;
      }

      final isSupervisorRoute = segments.firstOrNull == 'supervisor';
      if (authenticated && isSupervisorRoute) {
        final role = ref.read(currentUserProvider)?.role;
        const allowedRoles = {
          UserRole.supervisor,
          UserRole.admin,
          UserRole.ethicsOfficer,
        };
        if (!allowedRoles.contains(role)) return AppRoutes.dashboard;
      }

      return null; // no redirect
    },

    routes: [
      // -----------------------------------------------------------------------
      // Standalone auth routes (no shell)
      // -----------------------------------------------------------------------
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) {
          final from = state.uri.queryParameters['from'];
          return LoginScreen(redirectTo: from);
        },
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // -----------------------------------------------------------------------
      // Shell route: persistent sidebar around all main screens
      // -----------------------------------------------------------------------
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
              path: '/interviews',
              onExit: (context, state) async {
                if (!ref.read(interviewRecordingProvider)) return true;
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text(
                        'Stop and save the recording before leaving Interviews.')));
                return false;
              },
              builder: (context, state) => const InterviewsScreen()),
          // Dashboard
          GoRoute(
            path: AppRoutes.dashboard,
            name: 'dashboard',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DashboardScreen(),
            ),
          ),

          // Projects
          GoRoute(
            path: AppRoutes.projects,
            name: 'projects',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProjectsScreen(),
            ),
            routes: [
              GoRoute(
                path: ':id',
                name: 'project-detail',
                builder: (context, state) => ProjectDetailScreen(
                  projectId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),

          // Questionnaires
          GoRoute(
            path: AppRoutes.questionnaires,
            name: 'questionnaires',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: QuestionnairesScreen(),
            ),
            routes: [
              GoRoute(
                path: ':id/builder',
                name: 'questionnaire-builder',
                builder: (context, state) => QuestionnaireBuilderScreen(
                  questionnaireId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),

          // Data Collection
          GoRoute(
            path: '/data-collection/:questionnaireId',
            name: 'data-collection',
            builder: (context, state) =>
                state.pathParameters['questionnaireId'] == 'default'
                    ? const QuestionnairesScreen()
                    : DataCollectionScreen(
                        questionnaireId:
                            state.pathParameters['questionnaireId']!,
                      ),
          ),

          // Data Table
          GoRoute(
            path: '/data/:projectId',
            name: 'data-table',
            builder: (context, state) => DataTableScreen(
              projectId: state.pathParameters['projectId']!,
            ),
          ),

          // Analytics
          GoRoute(
            path: '/analytics/:projectId',
            name: 'analytics',
            builder: (context, state) =>
                state.pathParameters['projectId'] == 'default'
                    ? const AnalysisProjectPicker()
                    : AnalyticsScreen(
                        projectId: state.pathParameters['projectId']!,
                      ),
          ),

          // Participants
          GoRoute(
            path: AppRoutes.participants,
            name: 'participants',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ParticipantsScreen(),
            ),
          ),

          // Supervisor
          GoRoute(
            path: AppRoutes.supervisor,
            name: 'supervisor',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SupervisorScreen(),
            ),
          ),

          // Reports
          GoRoute(
            path: AppRoutes.reports,
            name: 'reports',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ReportsScreen(),
            ),
          ),

          // Settings
          GoRoute(
            path: AppRoutes.settings,
            name: 'settings',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsScreen(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/:surveySlug',
        name: 'public-questionnaire',
        builder: (context,state)=>PublicQuestionnaireScreen(slug:state.pathParameters['surveySlug']!),
      ),
    ],

    // -------------------------------------------------------------------------
    // Error page
    // -------------------------------------------------------------------------
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Color(0xFFC62828),
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                state.error?.message ?? 'The requested route does not exist.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF6B7280),
                    ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go(AppRoutes.dashboard),
              icon: const Icon(Icons.home_rounded),
              label: const Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
    ),
  );
});
