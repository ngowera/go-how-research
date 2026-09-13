import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart' show AppDatabase, databaseProvider;
import '../models/app_models.dart';

class AuthState {
  final AppUser? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    AppUser? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AppDatabase _db;
  static const _uuid = Uuid();

  AuthNotifier(this._db) : super(const AuthState()) {
    checkSession();
  }

  Future<void> checkSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      var localUser = await _db.getCurrentUser();
      if (_cloudConfigured()) {
        final cloudUser = Supabase.instance.client.auth.currentUser;
        if (cloudUser != null) {
          if (localUser == null || localUser.id != cloudUser.id ||
              prefs.getBool('pending_profile_${cloudUser.id}') != true) {
            localUser = await _loadCloudProfile(cloudUser);
          }
          await _db.setCurrentUser(localUser);
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('currentUserId', localUser.id);
        }
      }
      if (!isLoggedIn && localUser == null) return;
      if (localUser != null) {
        state = state.copyWith(user: localUser);
      }
    } catch (e) {
      // Ignored for initial session check
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      if (!_cloudConfigured()) {
        throw StateError(
          'Cloud sign-in is not configured yet. Enable Offline Mode to continue locally.',
        );
      }

      final res = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final suUser = res.user;
      if (suUser == null) throw StateError('Sign-in did not return a user.');
      final user = await _loadCloudProfile(suUser);

      final previousUser = await _db.getCurrentUser();
      if (previousUser != null &&
          previousUser.id != user.id &&
          previousUser.email.toLowerCase() == user.email.toLowerCase()) {
        await _db.reassignProjectOwner(previousUser.id, user.id);
      }
      await _db.setCurrentUser(user);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('currentUserId', user.id);

      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loginOffline(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      var user = await _db.getUserByEmail(email);
      if (user == null) {
        user = AppUser(
          id: _uuid.v4(),
          email: email,
          name: email.split('@').first,
          role: UserRole.student,
          createdAt: DateTime.now(),
        );
        await _db.insertUser(user);
      }

      await _db.setCurrentUser(user);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('currentUserId', user.id);

      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> register(
    String name,
    String email,
    String password,
    UserRole role,
  ) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      if (!_cloudConfigured()) {
        throw StateError(
          'Cloud registration is not configured. Use Offline Mode instead.',
        );
      }

      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {'name': name, 'role': role.name},
      );
      final userId = response.user?.id;
      if (userId == null) {
        throw StateError('Registration did not return a user.');
      }
      if (response.session == null) {
        state = state.copyWith(
          isLoading: false,
          error:
              'Account created. Check your email to confirm it, then sign in.',
        );
        return;
      }

      final user = AppUser(
        id: userId,
        email: email,
        name: name,
        role: role,
        createdAt: DateTime.now(),
      );

      final previousUser = await _db.getCurrentUser();
      if (previousUser != null &&
          previousUser.id != user.id &&
          previousUser.email.toLowerCase() == user.email.toLowerCase()) {
        await _db.reassignProjectOwner(previousUser.id, user.id);
      }
      await _db.insertUser(user);
      await _syncCloudProfile(user);
      await _db.setCurrentUser(user);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('currentUserId', user.id);

      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> _syncCloudProfile(AppUser user) async {
    await Supabase.instance.client.from('users').upsert(user.toJson());
  }

  bool _cloudConfigured() {
    final url = dotenv.env['SUPABASE_URL'] ?? '';
    final key = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
    return Uri.tryParse(url)?.host.endsWith('.supabase.co') == true &&
        !url.contains('your-project') &&
        key.isNotEmpty &&
        !key.contains('your-anon-key');
  }

  Future<AppUser> _loadCloudProfile(User authUser) async {
    final row = await Supabase.instance.client
        .from('users')
        .select()
        .eq('id', authUser.id)
        .maybeSingle();
    if (row != null) return AppUser.fromJson(row);

    final fallback = AppUser(
      id: authUser.id,
      email: authUser.email ?? '',
      name: authUser.userMetadata?['name'] as String? ??
          (authUser.email ?? 'researcher').split('@').first,
      role: UserRole.student,
      createdAt: DateTime.now(),
    );
    await _syncCloudProfile(fallback);
    return fallback;
  }

  Future<void> updateProfile({
    String? name,
    UserRole? role,
    String? institutionId,
    String? avatarUrl,
  }) async {
    final current = state.user;
    if (current == null) return;
    if (name != null && name.trim().isEmpty)
      throw ArgumentError('Your name cannot be empty.');
    final updated = current.copyWith(
      name: name ?? current.name,
      role: role ?? current.role,
      institutionId: institutionId ?? current.institutionId,
      avatarUrl: avatarUrl ?? current.avatarUrl,
    );
    await _db.insertUser(updated);
    await _db.setCurrentUser(updated);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool('pending_profile_${updated.id}', true);
    try {
      if (_cloudConfigured()) {
        await _syncCloudProfile(updated);
        await preferences.remove('pending_profile_${updated.id}');
      }
    } catch (_) {}
    state = state.copyWith(user: updated);
  }

  Future<void> logout() async {
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (_) {}
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('isLoggedIn');
      await prefs.remove('currentUserId');
      await _db.clearCurrentUser();
    } catch (_) {}
    state = const AuthState();
  }
}

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final db = ref.watch(databaseProvider);
  return AuthNotifier(db);
});

final currentUserProvider = Provider<AppUser?>((ref) {
  return ref.watch(authStateProvider).user;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).user != null;
});
