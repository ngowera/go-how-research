import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/app_models.dart';
import '../../core/providers/auth_provider.dart';

class GoogleSignInOption extends ConsumerWidget {
  final UserRole? role;
  final bool compact;

  const GoogleSignInOption({super.key, this.role, this.compact = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(authStateProvider).isLoading;
    final color = Theme.of(context).colorScheme;
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: Colors.grey.shade300)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text(
                'OR',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.1,
                ),
              ),
            ),
            Expanded(child: Divider(color: Colors.grey.shade300)),
          ],
        ),
        SizedBox(height: compact ? 6 : 12),
        SizedBox(
          width: double.infinity,
          height: compact ? 44 : 50,
          child: OutlinedButton.icon(
            onPressed: isLoading
                ? null
                : () => ref
                    .read(authStateProvider.notifier)
                    .signInWithGoogle(role: role),
            icon: Image.asset(
              'assets/images/google_signin_icon.png',
              width: 22,
              height: 22,
              fit: BoxFit.contain,
              semanticLabel: 'Google',
            ),
            label: const Text('Sign in with Google'),
            style: OutlinedButton.styleFrom(
              foregroundColor: color.onSurface,
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              textStyle: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}
