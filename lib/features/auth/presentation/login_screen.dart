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

class LoginScreen extends ConsumerStatefulWidget {
  final bool showUnauthenticatedMessage;

  const LoginScreen({super.key, this.showUnauthenticatedMessage = false});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.showUnauthenticatedMessage) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Anda belum login. Silakan masuk terlebih dahulu.'),
            backgroundColor: AppColors.maroon,
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        await ref.read(authProvider.notifier).login(
              _usernameController.text,
              _passwordController.text,
            );
        if (mounted && ref.read(authProvider).isAuthenticated) {
          context.go(Routes.homePath);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal masuk: $e'),
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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.pagePadding),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.lock_person_rounded, size: 64, color: AppColors.maroon)
                      .animate(onPlay: (controller) => controller.repeat(reverse: true))
                      .shimmer(duration: 2.seconds, color: AppColors.gold.withOpacity(0.8)),
                  const SizedBox(height: AppSpacing.md),
                  const Text(
                    'Selamat Datang',
                    style: AppTypography.displayLarge,
                    textAlign: TextAlign.center,
                  ).animate().fade(duration: 600.ms).slideY(begin: 0.2, curve: Curves.easeOutQuart),
                  const SizedBox(height: AppSpacing.xs),
                  const Text(
                    'Masuk untuk menggunakan SongketAI',
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
                  ).animate().fade(duration: 600.ms, delay: 300.ms).slideX(begin: 0.1, curve: Curves.easeOutQuart),
                  const SizedBox(height: AppSpacing.xl),
                  PrimaryButton(
                    label: 'Masuk',
                    isLoading: authState.isLoading,
                    onPressed: _login,
                    icon: Icons.login,
                  ).animate().fade(duration: 600.ms, delay: 400.ms).slideY(begin: 0.2, curve: Curves.easeOutQuart),
                  const SizedBox(height: AppSpacing.md),
                  TextButton(
                    onPressed: () => context.push(Routes.registerPath),
                    child: const Text('Belum punya akun? Daftar sekarang'),
                  ).animate().fade(duration: 600.ms, delay: 500.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
