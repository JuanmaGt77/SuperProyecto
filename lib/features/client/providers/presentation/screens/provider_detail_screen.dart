import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../app/router/app_routes.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../core/widgets/app_avatar.dart';
import '../../../../../core/widgets/app_badge.dart';
import '../../../../../shared/models/category_model.dart';
import '../../../../../shared/models/provider_model.dart';
import '../providers/providers_notifier.dart';

class ProviderDetailScreen extends ConsumerWidget {
  final String providerId;

  const ProviderDetailScreen({super.key, required this.providerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncProvider = ref.watch(providerDetailProvider(providerId));

    return asyncProvider.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 48, color: AppColors.grey400),
              const SizedBox(height: 12),
              const Text(
                'No se pudo cargar el perfil',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey700,
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () =>
                    ref.invalidate(providerDetailProvider(providerId)),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
      data: (provider) {
        if (provider == null) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => context.pop(),
              ),
            ),
            body: const Center(child: Text('Prestador no encontrado')),
          );
        }
        return _ProviderDetailView(provider: provider);
      },
    );
  }
}

class _ProviderDetailView extends StatelessWidget {
  final ProviderModel provider;

  const _ProviderDetailView({required this.provider});

  @override
  Widget build(BuildContext context) {
    final primaryCat = provider.categorySlugs.isNotEmpty
        ? CategoryModel.defaults
            .where((c) => c.slug == provider.categorySlugs.first)
            .firstOrNull
        : null;

    final headerColor = primaryCat?.fallbackColor ?? AppColors.primary;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildHero(context, headerColor),
              _buildStats(),
              _buildAbout(),
              _buildCategories(),
              _buildScheduleOrDetails(),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
          _buildBottomBar(context),
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context, Color headerColor) {
    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      backgroundColor: headerColor,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: CircleAvatar(
          backgroundColor: Colors.black26,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded,
                color: Colors.white, size: 20),
            onPressed: () => context.pop(),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: CircleAvatar(
            backgroundColor: Colors.black26,
            child: IconButton(
              icon: const Icon(Icons.share_rounded,
                  color: Colors.white, size: 18),
              onPressed: () {},
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                headerColor,
                headerColor.withAlpha(200),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                AppAvatar(
                  name: provider.fullName ?? 'P',
                  imageUrl: provider.avatarUrl,
                  size: 90,
                  showStatus: true,
                  isOnline: provider.isAvailable,
                  backgroundColor: Colors.white,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      provider.fullName ?? 'Prestador',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    if (provider.isVerified) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.verified,
                          color: Colors.white, size: 20),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  provider.primaryCategoryName,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: Colors.white.withAlpha(200),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppBadge(
                      label: provider.isAvailable ? 'Disponible' : 'No disponible',
                      variant: provider.isAvailable
                          ? BadgeVariant.success
                          : BadgeVariant.neutral,
                      small: true,
                    ),
                    if (provider.isVerified) ...[
                      const SizedBox(width: 8),
                      const VerifiedBadge(small: true),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStats() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Row(
          children: [
            Expanded(
              child: _StatBox(
                icon: Icons.star_rounded,
                value: provider.ratingDisplay,
                label: 'Calificación',
                color: const Color(0xFFF59E0B),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatBox(
                icon: Icons.rate_review_rounded,
                value: '${provider.totalReviews}',
                label: 'Reseñas',
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatBox(
                icon: Icons.work_rounded,
                value: '${provider.totalJobs}',
                label: 'Trabajos',
                color: AppColors.success,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatBox(
                icon: Icons.calendar_today_rounded,
                value: '${provider.yearsExperience}',
                label: 'Años exp.',
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAbout() {
    if (provider.bio == null || provider.bio!.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: _Section(
          title: 'Acerca de',
          child: Text(
            provider.bio!,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: AppColors.grey700,
              height: 1.6,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    if (provider.categoryNames.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: _Section(
          title: 'Servicios que ofrece',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: provider.categorySlugs.asMap().entries.map((e) {
              final idx = e.key;
              final slug = e.value;
              final name = provider.categoryNames.length > idx
                  ? provider.categoryNames[idx]
                  : slug;
              final cat = CategoryModel.defaults
                  .where((c) => c.slug == slug)
                  .firstOrNull;
              final color = cat?.fallbackColor ?? AppColors.primary;
              final icon = cat?.fallbackIcon ?? Icons.handyman_rounded;
              return _CategoryChip(name: name, color: color, icon: icon);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleOrDetails() {
    final details = <_DetailRow>[];

    if (provider.baseRate != null) {
      details.add(_DetailRow(
        icon: Icons.attach_money_rounded,
        label: 'Tarifa base',
        value: '\$${provider.baseRate!.toStringAsFixed(0)} / hora',
        color: AppColors.success,
      ));
    }

    if (provider.coverageRadiusKm > 0) {
      details.add(_DetailRow(
        icon: Icons.radar_rounded,
        label: 'Radio de cobertura',
        value: '${provider.coverageRadiusKm.toStringAsFixed(0)} km',
        color: AppColors.primary,
      ));
    }

    if (provider.distanceKm != null) {
      details.add(_DetailRow(
        icon: Icons.place_rounded,
        label: 'Distancia',
        value: '${provider.distanceKm!.toStringAsFixed(1)} km de ti',
        color: AppColors.secondary,
      ));
    }

    if (details.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: _Section(
          title: 'Detalles',
          child: Column(
            children: details
                .map((d) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: d.color.withAlpha(20),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(d.icon, size: 16, color: d.color),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              d.label,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                color: AppColors.grey600,
                              ),
                            ),
                          ),
                          Text(
                            d.value,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.grey900,
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(
            16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 16,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Chat button
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.grey300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.chat_bubble_outline_rounded,
                    color: AppColors.primary),
                onPressed: () => context.push(AppRoutes.clientChats),
              ),
            ),
            const SizedBox(width: 12),
            // Request button
            Expanded(
              child: ElevatedButton(
                onPressed: provider.isAvailable
                    ? () => context.push(AppRoutes.clientCreateRequest)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.grey300,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  provider.isAvailable
                      ? 'Solicitar servicio'
                      : 'No disponible ahora',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sub-widgets ─────────────────────────────────────────────────────────────

class _StatBox extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatBox({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.grey900,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10,
              color: AppColors.grey500,
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.grey900,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String name;
  final Color color;
  final IconData icon;

  const _CategoryChip({
    required this.name,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            name,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
}
