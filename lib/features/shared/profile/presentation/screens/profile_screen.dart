import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../app/router/app_routes.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../core/widgets/app_avatar.dart';
import '../../../../../features/auth/presentation/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildHeader(context, ref, user),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  _buildInfoCard(user),
                  const SizedBox(height: 16),
                  _buildMenuSection(context, ref),
                  const SizedBox(height: 32),
                  _buildLogoutButton(context, ref),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, user) {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 16,
          bottom: 32,
          left: 20,
          right: 20,
        ),
        decoration: const BoxDecoration(
          gradient: AppColors.cardGradient,
        ),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: AppColors.white),
                  onPressed: () => context.pop(),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit_rounded, color: AppColors.white),
                  onPressed: () => context.push(AppRoutes.profile + '/edit'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Stack(
              children: [
                AppAvatar(
                  name: user.fullName,
                  imageUrl: user.avatarUrl,
                  size: 88,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => context.push(AppRoutes.profile + '/edit'),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt_rounded,
                          size: 14, color: AppColors.primary),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              user.fullName,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.white.withAlpha(40),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                user.role.value == 'client' ? 'Cliente' : 'Prestador',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: AppColors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        children: [
          _infoRow(Icons.email_outlined, 'Correo', user.email),
          if (user.phone != null && user.phone!.isNotEmpty) ...[
            const Divider(height: 24, color: AppColors.grey200),
            _infoRow(Icons.phone_outlined, 'Teléfono', user.phone!),
          ],
          const Divider(height: 24, color: AppColors.grey200),
          _infoRow(
            Icons.calendar_today_outlined,
            'Miembro desde',
            '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}',
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  color: AppColors.grey500,
                )),
            Text(value,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.grey900,
                )),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuSection(BuildContext context, WidgetRef ref) {
    final items = [
      (Icons.notifications_outlined, 'Notificaciones', AppRoutes.notifications),
      (Icons.settings_outlined, 'Configuración', AppRoutes.settings),
      (Icons.support_agent_outlined, 'Soporte', AppRoutes.support),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          return Column(
            children: [
              ListTile(
                leading: Icon(item.$1, color: AppColors.grey600, size: 20),
                title: Text(item.$2,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: AppColors.grey800,
                    )),
                trailing: const Icon(Icons.chevron_right_rounded,
                    color: AppColors.grey400),
                onTap: () => context.push(item.$3),
              ),
              if (i < items.length - 1)
                const Divider(height: 1, indent: 56, color: AppColors.grey200),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Cerrar sesión',
                  style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
              content: const Text('¿Estás seguro que deseas cerrar sesión?',
                  style: TextStyle(fontFamily: 'Poppins')),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Cerrar sesión',
                      style: TextStyle(color: AppColors.error)),
                ),
              ],
            ),
          );
          if (confirm == true) {
            await ref.read(authProvider.notifier).signOut();
          }
        },
        icon: const Icon(Icons.logout_rounded, color: AppColors.error),
        label: const Text('Cerrar sesión',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              color: AppColors.error,
            )),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.error),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
