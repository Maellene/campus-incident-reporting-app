import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/custom_button.dart';

class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key});

  Future<void> _check(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    await auth.checkEmailVerified();
    if (!auth.isEmailVerified && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your email is not verified yet')),
      );
    }
  }

  Future<void> _resend(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final sent = await auth.resendVerification();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          sent
              ? 'Verification email sent'
              : auth.errorMessage ?? 'Could not send the email',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final email = auth.firebaseUser?.email ?? '';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.mark_email_unread_outlined,
                  size: 72, color: AppTheme.primary),
              const SizedBox(height: 24),
              const Text(
                'Verify your email',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'We sent a verification link to\n$email\nOpen it, then come back and tap the button below.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 32),
              CustomButton(
                label: 'I have verified my email',
                isLoading: auth.isLoading,
                onPressed: () => _check(context),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => _resend(context),
                child: const Text('Resend email'),
              ),
              TextButton(
                onPressed: () => context.read<AuthProvider>().logout(),
                child: const Text('Log out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}