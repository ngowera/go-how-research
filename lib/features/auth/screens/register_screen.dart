import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/models/app_models.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../shared/theme/app_theme.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _institutionController = TextEditingController();
  UserRole _selectedRole = UserRole.student;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _institutionController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authStateProvider.notifier).register(
          _nameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text,
          _selectedRole,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    ref.listen(authStateProvider, (prev, next) {
      if (next.user != null) context.go('/dashboard');
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.error!),
          backgroundColor: AppTheme.kError,
          behavior: SnackBarBehavior.floating,
        ));
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) => Row(
          children: [
            // Left branding panel
            if (constraints.maxWidth >= 900)
              Expanded(
                flex: 4,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1565C0), Color(0xFF00897B)],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(48),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.biotech_rounded,
                            size: 64, color: Colors.white),
                        const SizedBox(height: 24),
                        Text(
                          'Join GoHow\nResearch',
                          style: GoogleFonts.poppins(
                            fontSize: 40,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Start managing your research projects professionally',
                          style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 16),
                        ),
                        const SizedBox(height: 40),
                        _infoChip('Student Researchers', Icons.school_rounded),
                        _infoChip(
                            'Supervisors', Icons.supervisor_account_rounded),
                        _infoChip('Research Assistants', Icons.group_rounded),
                        _infoChip(
                            'Ethics Officers', Icons.verified_user_rounded),
                      ],
                    ),
                  ),
                ),
              ),
            // Right form panel
            Expanded(
              flex: 5,
              child: Container(
                color: Colors.white,
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(48),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Create Account',
                              style: GoogleFonts.poppins(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1A1A2E)),
                            ),
                            const SizedBox(height: 6),
                            Text('Fill in your details to get started',
                                style: GoogleFonts.poppins(
                                    color: Colors.grey.shade600, fontSize: 14)),
                            const SizedBox(height: 32),
                            // Role selector
                            Text('I am a...',
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600, fontSize: 14)),
                            const SizedBox(height: 8),
                            _buildRoleSelector(),
                            const SizedBox(height: 20),
                            // Full name
                            _buildField(
                              controller: _nameController,
                              label: 'Full Name',
                              icon: Icons.person_outlined,
                              validator: (v) => (v == null || v.isEmpty)
                                  ? 'Please enter your name'
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            // Institution
                            _buildField(
                              controller: _institutionController,
                              label: 'University / Institution',
                              icon: Icons.account_balance_outlined,
                            ),
                            const SizedBox(height: 16),
                            // Email
                            _buildField(
                              controller: _emailController,
                              label: 'Email Address',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) {
                                if (v == null || v.isEmpty)
                                  return 'Please enter your email';
                                if (!v.contains('@')) return 'Invalid email';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            // Password
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
                                if (v == null || v.length < 6)
                                  return 'Password must be at least 6 characters';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            // Confirm password
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: _obscureConfirm,
                              decoration: InputDecoration(
                                labelText: 'Confirm Password',
                                prefixIcon: const Icon(Icons.lock_outlined),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscureConfirm
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined),
                                  onPressed: () => setState(
                                      () => _obscureConfirm = !_obscureConfirm),
                                ),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              validator: (v) {
                                if (v != _passwordController.text)
                                  return 'Passwords do not match';
                                return null;
                              },
                            ),
                            const SizedBox(height: 28),
                            // Register button
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed:
                                    authState.isLoading ? null : _register,
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
                                            strokeWidth: 2))
                                    : Text('Create Account',
                                        style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600)),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Already have an account? ',
                                    style: GoogleFonts.poppins(
                                        color: Colors.grey.shade600)),
                                TextButton(
                                  onPressed: () => context.go('/login'),
                                  child: Text('Sign In',
                                      style: GoogleFonts.poppins(
                                          color: AppTheme.kPrimary,
                                          fontWeight: FontWeight.w600)),
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

  Widget _buildRoleSelector() {
    final roles = [
      (UserRole.student, 'Student', Icons.school_rounded),
      (UserRole.supervisor, 'Supervisor', Icons.supervisor_account_rounded),
      (UserRole.admin, 'Admin', Icons.admin_panel_settings_rounded),
      (UserRole.enumerator, 'Enumerator', Icons.assignment_ind_rounded),
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: roles.map((r) {
        final isSelected = _selectedRole == r.$1;
        return GestureDetector(
          onTap: () => setState(() => _selectedRole = r.$1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.kPrimary : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: isSelected ? AppTheme.kPrimary : Colors.grey.shade300),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(r.$3,
                    size: 16,
                    color: isSelected ? Colors.white : Colors.grey.shade600),
                const SizedBox(width: 6),
                Text(r.$2,
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color:
                            isSelected ? Colors.white : Colors.grey.shade700)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _infoChip(String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.8), size: 18),
          const SizedBox(width: 10),
          Text(label,
              style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.85), fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: validator,
    );
  }
}
