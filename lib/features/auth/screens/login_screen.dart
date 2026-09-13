import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/loading_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final String? redirectTo;

  const LoginScreen({super.key, this.redirectTo});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isOfflineMode = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final notifier = ref.read(authStateProvider.notifier);
    if (_isOfflineMode) {
      await notifier.loginOffline(_emailController.text.trim());
    } else {
      await notifier.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    ref.listen(authStateProvider, (prev, next) {
      if (next.user != null) {
        context.go(widget.redirectTo ?? '/dashboard');
      }
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppTheme.kError,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) => Row(
          children: [
            // Left panel - branding
            if (constraints.maxWidth >= 900)
              Expanded(
                flex: 5,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.kPrimary,
                        const Color(0xFF0D47A1),
                        AppTheme.kSecondary,
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(48),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Logo
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.biotech_rounded,
                            size: 56,
                            color: Colors.white,
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 600.ms)
                            .slideY(begin: -0.3),
                        const SizedBox(height: 32),
                        Text(
                          'GoHow\nResearch',
                          style: GoogleFonts.poppins(
                            fontSize: 48,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.1,
                          ),
                        )
                            .animate()
                            .fadeIn(delay: 200.ms, duration: 600.ms)
                            .slideX(begin: -0.3),
                        const SizedBox(height: 16),
                        Text(
                          'All-in-One University Research Platform',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            color: Colors.white.withOpacity(0.85),
                            fontWeight: FontWeight.w400,
                          ),
                        ).animate().fadeIn(delay: 400.ms, duration: 600.ms),
                        const SizedBox(height: 48),
                        // Features list
                        ...[
                          ('📊', 'Design & manage research projects'),
                          ('📝', 'Build smart questionnaires'),
                          ('📡', 'Collect data offline, sync online'),
                          ('📈', 'Analyse data with statistics & charts'),
                          ('🤝', 'Collaborate with supervisors'),
                        ]
                            .map((item) => Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: Row(
                                    children: [
                                      Text(item.$1,
                                          style: const TextStyle(fontSize: 20)),
                                      const SizedBox(width: 12),
                                      Text(
                                        item.$2,
                                        style: GoogleFonts.poppins(
                                          fontSize: 15,
                                          color: Colors.white.withOpacity(0.9),
                                        ),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList()
                            .animate(interval: 100.ms)
                            .fadeIn(delay: 600.ms, duration: 400.ms)
                            .slideX(begin: -0.2),
                        const SizedBox(height: 48),
                        Text(
                          'Smarter Research. Better Evidence.',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.6),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            // Right panel - login form
            Expanded(
              flex: 4,
              child: Container(
                color: Colors.white,
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(48),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back',
                              style: GoogleFonts.poppins(
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1A1A2E),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Sign in to continue your research',
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 40),
                            // Offline mode toggle
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _isOfflineMode
                                    ? AppTheme.kWarning.withOpacity(0.1)
                                    : Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: _isOfflineMode
                                      ? AppTheme.kWarning.withOpacity(0.4)
                                      : Colors.grey.shade200,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _isOfflineMode
                                        ? Icons.wifi_off_rounded
                                        : Icons.wifi_rounded,
                                    color: _isOfflineMode
                                        ? AppTheme.kWarning
                                        : Colors.grey.shade500,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _isOfflineMode
                                          ? 'Offline mode — using local data'
                                          : 'Online mode — syncing with cloud',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        color: _isOfflineMode
                                            ? AppTheme.kWarning
                                            : Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                  Switch.adaptive(
                                    value: _isOfflineMode,
                                    onChanged: (v) =>
                                        setState(() => _isOfflineMode = v),
                                    activeColor: AppTheme.kWarning,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Email
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: 'Email address',
                                prefixIcon: const Icon(Icons.email_outlined),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty)
                                  return 'Please enter your email';
                                if (!v.contains('@'))
                                  return 'Enter a valid email';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            // Password
                            if (!_isOfflineMode) ...[
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: const Icon(Icons.lock_outlined),
                                  suffixIcon: IconButton(
                                    icon: Icon(_obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined),
                                    onPressed: () => setState(() =>
                                        _obscurePassword = !_obscurePassword),
                                  ),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty)
                                    return 'Please enter your password';
                                  if (v.length < 6)
                                    return 'Password must be at least 6 characters';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Password recovery becomes available after Supabase is configured.',
                                        ),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Forgot password?',
                                    style: GoogleFonts.poppins(
                                        color: AppTheme.kPrimary),
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 24),
                            // Login button
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: authState.isLoading ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.kPrimary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                                child: authState.isLoading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2),
                                      )
                                    : Text(
                                        'Sign In',
                                        style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Register link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Don't have an account? ",
                                  style: GoogleFonts.poppins(
                                      color: Colors.grey.shade600),
                                ),
                                TextButton(
                                  onPressed: () => context.go('/register'),
                                  child: Text(
                                    'Create Account',
                                    style: GoogleFonts.poppins(
                                      color: AppTheme.kPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
