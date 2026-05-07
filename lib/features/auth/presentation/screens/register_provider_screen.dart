import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../shared/models/category_model.dart';
import '../providers/auth_provider.dart';

class RegisterProviderScreen extends ConsumerStatefulWidget {
  const RegisterProviderScreen({super.key});

  @override
  ConsumerState<RegisterProviderScreen> createState() =>
      _RegisterProviderScreenState();
}

class _RegisterProviderScreenState
    extends ConsumerState<RegisterProviderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _bioController = TextEditingController();
  final _experienceController = TextEditingController();
  CategoryModel? _selectedCategory;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _bioController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  Future<void> _onRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      _showError('Selecciona tu categoría principal');
      return;
    }

    final success = await ref.read(authProvider.notifier).signUpProvider(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          fullName: _nameController.text.trim(),
          categorySlug: _selectedCategory!.slug,
          yearsExperience:
              int.tryParse(_experienceController.text.trim()) ?? 0,
          bio: _bioController.text.trim(),
          phone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
        );

    if (!mounted) return;

    if (success) {
      context.go(AppRoutes.providerHome);
    } else {
      final error = ref.read(authProvider).error;
      _showError(error ?? 'Error al crear la cuenta');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider).isLoading;
    final categories = CategoryModel.defaults;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Registro de Prestador'),
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
                    color: AppColors.secondarySurface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.handyman_rounded,
                          color: AppColors.secondary, size: 28),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Tu perfil será revisado antes de aparecer en la app.',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.secondaryDark,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Selecciona tu categoría principal',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.grey700,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: categories.map((cat) {
                    final selected = _selectedCategory?.slug == cat.slug;
                    return GestureDetector(
                      onTap: isLoading
                          ? null
                          : () => setState(() => _selectedCategory = cat),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: selected
                              ? cat.fallbackColor.withAlpha(30)
                              : AppColors.grey100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected
                                ? cat.fallbackColor
                                : AppColors.grey300,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(cat.fallbackIcon,
                                size: 18,
                                color: selected
                                    ? cat.fallbackColor
                                    : AppColors.grey600),
                            const SizedBox(width: 6),
                            Text(
                              cat.name,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: selected
                                    ? cat.fallbackColor
                                    : AppColors.grey700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                AppTextField(
                  label: 'Nombre completo',
                  hint: 'Ej: Juan Pérez',
                  controller: _nameController,
                  validator: Validators.fullName,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Correo electrónico',
                  hint: 'tucorreo@ejemplo.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Teléfono (opcional)',
                  hint: '+57 300 000 0000',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  validator: Validators.phone,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Años de experiencia',
                  hint: 'Ej: 5',
                  controller: _experienceController,
                  keyboardType: TextInputType.number,
                  validator: (v) => Validators.required(v, 'La experiencia'),
                  enabled: !isLoading,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Descripción de tu trabajo',
                  hint: 'Cuéntanos qué tipos de servicios ofreces...',
                  controller: _bioController,
                  maxLines: 4,
                  validator: (v) =>
                      Validators.minLength(v, 20, 'La descripción'),
                  enabled: !isLoading,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Contraseña',
                  hint: 'Mínimo 6 caracteres',
                  controller: _passwordController,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  validator: Validators.password,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 24),
                AppButton(
                  label: 'Crear cuenta de prestador',
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
