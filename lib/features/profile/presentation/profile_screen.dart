import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../providers/auth_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    if (_formKey.currentState!.validate()) {
      try {
        await ref.read(authProvider.notifier).updatePassword(
              _oldPasswordController.text,
              _newPasswordController.text,
            );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kata sandi berhasil diperbarui'),
              backgroundColor: Colors.green,
            ),
          );
          _oldPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal memperbarui: $e'),
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
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.account_circle, size: 80, color: AppColors.maroon)
                .animate()
                .scale(duration: 500.ms, curve: Curves.easeOutBack)
                .fade(duration: 500.ms),
            const SizedBox(height: AppSpacing.md),
            Text(
              user?.username ?? 'Pengguna',
              style: AppTypography.headingMedium,
              textAlign: TextAlign.center,
            ).animate().fade(duration: 600.ms, delay: 100.ms),
            Text(
              user?.email ?? '-',
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ).animate().fade(duration: 600.ms, delay: 200.ms),
            const SizedBox(height: AppSpacing.xl),
            
            // Divider
            const Divider().animate().fade(duration: 600.ms, delay: 300.ms),
            const SizedBox(height: AppSpacing.lg),
            
             const Text(
              'Ubah Kata Sandi',
              style: AppTypography.headingMedium,
            ).animate().fade(duration: 600.ms, delay: 400.ms).slideX(begin: -0.05),
            const SizedBox(height: AppSpacing.md),
            
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _oldPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'Kata Sandi Saat Ini',
                      prefixIcon: Icon(Icons.lock_clock_outlined),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Wajib diisi';
                      return null;
                    },
                  ).animate().fade(duration: 600.ms, delay: 500.ms).slideY(begin: 0.1),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _newPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'Kata Sandi Baru',
                      prefixIcon: Icon(Icons.vpn_key_outlined),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Wajib diisi';
                      if (value.length < 8) return 'Minimal 8 karakter';
                      return null;
                    },
                  ).animate().fade(duration: 600.ms, delay: 600.ms).slideY(begin: 0.1),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'Konfirmasi Kata Sandi Baru',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value != _newPasswordController.text) {
                        return 'Kata sandi baru tidak sama';
                      }
                      return null;
                    },
                  ).animate().fade(duration: 600.ms, delay: 700.ms).slideY(begin: 0.1),
                  const SizedBox(height: AppSpacing.lg),
                  PrimaryButton(
                    label: 'Perbarui Kata Sandi',
                    isLoading: authState.isLoading,
                    onPressed: _updatePassword,
                    icon: Icons.save,
                  ).animate().fade(duration: 600.ms, delay: 800.ms).slideY(begin: 0.1),
                ],
              ),
            ),
            
            const SizedBox(height: AppSpacing.xl),
            const Divider().animate().fade(duration: 600.ms, delay: 900.ms),
            const SizedBox(height: AppSpacing.xl),
            
            ElevatedButton.icon(
              onPressed: () {
                ref.read(authProvider.notifier).logout();
              },
              icon: const Icon(Icons.logout),
              label: const Text('Keluar (Logout)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.maroon,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              ),
            ).animate().fade(duration: 600.ms, delay: 1000.ms).slideY(begin: 0.1),
            const SizedBox(height: 100), // padding untuk bottom nav
          ],
        ),
      ),
    );
  }
}
