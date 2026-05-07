import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/auth_provider.dart';

class RegisterClientScreen extends ConsumerStatefulWidget {
  const RegisterClientScreen({super.key});

  @override
  ConsumerState<RegisterClientScreen> createState() =>
      _RegisterClientScreenState();
}

class _RegisterClientScreenState extends ConsumerState<RegisterClientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _acceptTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _onRegister() async {
    debugPrint('[Register] _onRegister called');
    if (!_formKey.currentState!.validate()) {
      debugPrint('[Register] form validation FAILED');
      return;
    }
    if (!_acceptTerms) {
      debugPrint('[Register] terms not accepted');
      _showError('Debes aceptar los términos y condiciones');
      return;
    }

    debugPrint('[Register] calling signUpClient...');
    final success = await ref.read(authProvider.notifier).signUpClient(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          fullName: _nameController.text.trim(),
          phone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
        );
    debugPrint('[Register] signUpClient returned: $success');

    if (!mounted) return;

    if (success) {
      debugPrint('[Register] navigating to clientHome');
      context.go(AppRoutes.clientHome);
    } else {
      final error = ref.read(authProvider).error;
      debugPrint('[Register] error: $error');
      _showError(error ?? 'Error al crear la cuenta');
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error al crear la cuenta'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Crear cuenta'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: isLoading ? null : () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: AppSpacing.lg,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.person_search_rounded,
                          color: AppColors.primary, size: 28),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Cuenta de Cliente — Encuentra prestadores cercanos rápidamente.',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primaryDark,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                AppTextField(
                  label: 'Nombre completo',
                  hint: 'Ej: Juan Pérez',
                  controller: _nameController,
                  validator: Validators.fullName,
                  enabled: !isLoading,
                  prefixIcon: const Icon(Icons.person_outline_rounded,
                      color: AppColors.grey500, size: 20),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Correo electrónico',
                  hint: 'tucorreo@ejemplo.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                  enabled: !isLoading,
                  prefixIcon: const Icon(Icons.mail_outline_rounded,
                      color: AppColors.grey500, size: 20),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Teléfono (opcional)',
                  hint: '+57 300 000 0000',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  validator: Validators.phone,
                  enabled: !isLoading,
                  prefixIcon: const Icon(Icons.phone_outlined,
                      color: AppColors.grey500, size: 20),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Contraseña',
                  hint: 'Mínimo 6 caracteres',
                  controller: _passwordController,
                  obscureText: true,
                  validator: Validators.password,
                  enabled: !isLoading,
                  prefixIcon: const Icon(Icons.lock_outline_rounded,
                      color: AppColors.grey500, size: 20),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Confirmar contraseña',
                  hint: 'Repite tu contraseña',
                  controller: _confirmController,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  validator: (v) =>
                      Validators.passwordConfirm(v, _passwordController.text),
                  enabled: !isLoading,
                  prefixIcon: const Icon(Icons.lock_outline_rounded,
                      color: AppColors.grey500, size: 20),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: _acceptTerms,
                      onChanged: isLoading
                          ? null
                          : (v) => setState(() => _acceptTerms = v ?? false),
                      activeColor: AppColors.primary,
                    ),
                    const Expanded(
                      child: Text(
                        'Acepto los términos y condiciones y la política de privacidad.',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: AppColors.grey700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                AppButton(
                  label: 'Crear cuenta',
                  isLoading: isLoading,
                  onPressed: isLoading ? null : _onRegister,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
