import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      try {
        await ref.read(authProvider.notifier).register(
              _usernameController.text,
              _emailController.text,
              _passwordController.text,
            );
        if (mounted && ref.read(authProvider).isAuthenticated) {
          context.go(Routes.homePath);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Pendaftaran gagal: $e'),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Akun'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.person_add_alt_1_rounded, size: 64, color: AppColors.maroon)
                    .animate(onPlay: (controller) => controller.repeat(reverse: true))
                    .shimmer(duration: 2.seconds, color: AppColors.gold.withOpacity(0.8)),
                const SizedBox(height: AppSpacing.md),
                const Text(
                  'Daftar Baru',
                  style: AppTypography.displayLarge,
                  textAlign: TextAlign.center,
                ).animate().fade(duration: 600.ms).slideY(begin: 0.2, curve: Curves.easeOutQuart),
                const SizedBox(height: AppSpacing.xs),
                const Text(
                  'Lengkapi data di bawah untuk bergabung',
                  style: AppTypography.bodyMedium,
                  textAlign: TextAlign.center,
                ).animate().fade(duration: 600.ms, delay: 100.ms).slideY(begin: 0.2, curve: Curves.easeOutQuart),
                const SizedBox(height: AppSpacing.xl),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) => value!.isEmpty ? 'Username tidak boleh kosong' : null,
                ).animate().fade(duration: 600.ms, delay: 200.ms).slideX(begin: -0.1, curve: Curves.easeOutQuart),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Email tidak boleh kosong';
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Format email tidak valid';
                    }
                    return null;
                  },
                ).animate().fade(duration: 600.ms, delay: 300.ms).slideX(begin: 0.1, curve: Curves.easeOutQuart),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.vpn_key_outlined),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Password tidak boleh kosong';
                    if (value.length < 8) return 'Password minimal 8 karakter';
                    return null;
                  },
                ).animate().fade(duration: 600.ms, delay: 400.ms).slideX(begin: -0.1, curve: Curves.easeOutQuart),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Konfirmasi Password',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'Password tidak sama';
                    }
                    return null;
                  },
                ).animate().fade(duration: 600.ms, delay: 500.ms).slideX(begin: 0.1, curve: Curves.easeOutQuart),
                const SizedBox(height: AppSpacing.xl),
                PrimaryButton(
                  label: 'Daftar',
                  isLoading: authState.isLoading,
                  onPressed: _register,
                  icon: Icons.person_add,
                ).animate().fade(duration: 600.ms, delay: 600.ms).slideY(begin: 0.2, curve: Curves.easeOutQuart),
                const SizedBox(height: AppSpacing.md),
                TextButton(
                  onPressed: () => context.pop(), // Pop to return to Login
                  child: const Text('Sudah punya akun? Masuk di sini'),
                ).animate().fade(duration: 600.ms, delay: 700.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
