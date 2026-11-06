import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/widgets/auth_layout.dart';
import '../../../shared/widgets/google_sign_in_option.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../shared/theme/app_theme.dart';

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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    FocusManager.instance.primaryFocus?.unfocus();
    final notifier = ref.read(authStateProvider.notifier);
    await notifier.login(
      _emailController.text.trim(),
      _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isPhone = MediaQuery.sizeOf(context).width < 600;

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

    return AuthLayout(
      isRegistration: false,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isPhone ? 'Welcome to Go-How Research' : 'Welcome back',
              style: GoogleFonts.poppins(
                fontSize: isPhone ? 25 : 32,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            SizedBox(height: isPhone ? 12 : 32),
            // Email
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              autocorrect: false,
              enableSuggestions: false,
              decoration: InputDecoration(
                labelText: 'Email address',
                prefixIcon: const Icon(Icons.email_outlined),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return 'Please enter your email';
                }
                if (!v.contains('@')) {
                  return 'Enter a valid email';
                }
                return null;
              },
            ),
            SizedBox(height: isPhone ? 12 : 16),
            // Password
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              onFieldSubmitted: (_) {
                if (!authState.isLoading) {
                  _login();
                }
              },
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outlined),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return 'Please enter your password';
                }
                if (v.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                style: TextButton.styleFrom(
                  visualDensity: isPhone ? VisualDensity.compact : null,
                  padding: EdgeInsets.symmetric(
                      horizontal: 8, vertical: isPhone ? 2 : 8),
                  minimumSize: Size(0, isPhone ? 32 : 40),
                ),
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
                  style: GoogleFonts.poppins(color: AppTheme.kPrimary),
                ),
              ),
            ),
            SizedBox(height: isPhone ? 10 : 24),
            // Login button
            SizedBox(
              width: double.infinity,
              height: isPhone ? 46 : 52,
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
                            color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        'Sign In',
                        style: GoogleFonts.poppins(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
            const SizedBox(height: 8),
            GoogleSignInOption(compact: isPhone),
            SizedBox(height: isPhone ? 8 : 24),
            // Register link
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  "Don't have an account? ",
                  style: GoogleFonts.poppins(color: Colors.grey.shade600),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    visualDensity: isPhone ? VisualDensity.compact : null,
                    padding: EdgeInsets.symmetric(
                        horizontal: 8, vertical: isPhone ? 2 : 8),
                    minimumSize: Size(0, isPhone ? 32 : 40),
                  ),
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
    );
  }
}
