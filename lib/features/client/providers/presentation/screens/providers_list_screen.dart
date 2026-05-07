import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../shared/models/category_model.dart';
import '../../../home/presentation/widgets/provider_card.dart';
import '../providers/providers_notifier.dart';

class ProvidersListScreen extends ConsumerStatefulWidget {
  final String? categorySlug;

  const ProvidersListScreen({super.key, this.categorySlug});

  @override
  ConsumerState<ProvidersListScreen> createState() => _ProvidersListScreenState();
}

class _ProvidersListScreenState extends ConsumerState<ProvidersListScreen> {
  final _searchController = TextEditingController();
  late final CategoryModel? _category;

  @override
  void initState() {
    super.initState();
    _category = widget.categorySlug != null
        ? CategoryModel.defaults
            .where((c) => c.slug == widget.categorySlug)
            .firstOrNull
        : null;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(providersNotifierProvider(widget.categorySlug).notifier)
          .load(categorySlug: widget.categorySlug);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(providersNotifierProvider(widget.categorySlug));
    final catColor = _category?.fallbackColor ?? AppColors.primary;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          _buildAppBar(catColor),
          _buildSearchAndFilters(state, catColor),
        ],
        body: _buildBody(state),
      ),
    );
  }

  Widget _buildAppBar(Color catColor) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: _category != null ? 120 : 60,
      backgroundColor: AppColors.surface,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: AppColors.grey900),
        onPressed: () => context.pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: _category != null
            ? Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      catColor.withAlpha(200),
                      catColor.withAlpha(120),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(56, 12, 20, 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(50),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _category!.fallbackIcon,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _category!.name,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Prestadores disponibles',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  color: Colors.white.withAlpha(200),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : null,
        title: _category == null
            ? const Text(
                'Todos los prestadores',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey900,
                ),
              )
            : null,
        collapseMode: CollapseMode.pin,
      ),
    );
  }

  Widget _buildSearchAndFilters(ProvidersState state, Color catColor) {
    return SliverToBoxAdapter(
      child: Container(
        color: AppColors.surface,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.grey300),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (q) =>
                    ref.read(providersNotifierProvider(widget.categorySlug).notifier).search(q),
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: AppColors.grey900,
                ),
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre o categoría...',
                  hintStyle: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: AppColors.grey500,
                  ),
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: AppColors.grey500, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded,
                              color: AppColors.grey500, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            ref
                                .read(providersNotifierProvider(widget.categorySlug).notifier)
                                .search('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Filter chips row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'Disponibles',
                    icon: Icons.circle,
                    isActive: state.onlyAvailable,
                    activeColor: AppColors.success,
                    onTap: () => ref
                        .read(providersNotifierProvider(widget.categorySlug).notifier)
                        .toggleAvailable(!state.onlyAvailable),
                  ),
                  const SizedBox(width: 8),
                  _SortChip(
                    label: 'Calificación',
                    icon: Icons.star_rounded,
                    isActive: state.sort == ProviderSort.rating,
                    onTap: () => ref
                        .read(providersNotifierProvider(widget.categorySlug).notifier)
                        .setSort(ProviderSort.rating),
                  ),
                  const SizedBox(width: 8),
                  _SortChip(
                    label: 'Distancia',
                    icon: Icons.place_rounded,
                    isActive: state.sort == ProviderSort.distance,
                    onTap: () => ref
                        .read(providersNotifierProvider(widget.categorySlug).notifier)
                        .setSort(ProviderSort.distance),
                  ),
                  const SizedBox(width: 8),
                  _SortChip(
                    label: 'Reseñas',
                    icon: Icons.rate_review_rounded,
                    isActive: state.sort == ProviderSort.reviews,
                    onTap: () => ref
                        .read(providersNotifierProvider(widget.categorySlug).notifier)
                        .setSort(ProviderSort.reviews),
                  ),
                ],
              ),
            ),
            if (!state.isLoading && state.filtered.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '${state.filtered.length} prestador${state.filtered.length == 1 ? '' : 'es'} encontrado${state.filtered.length == 1 ? '' : 's'}',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: AppColors.grey500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(ProvidersState state) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (state.error != null) {
      return _buildErrorState(state.error!);
    }

    if (state.filtered.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: state.filtered.length,
      itemBuilder: (context, i) {
        final p = state.filtered[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: ProviderCard(
            name: p.fullName ?? 'Prestador',
            category: p.primaryCategoryName,
            rating: p.avgRating,
            reviews: p.totalReviews,
            distanceKm: p.distanceKm ?? 0,
            isAvailable: p.isAvailable,
            isVerified: p.isVerified,
            avatarUrl: p.avatarUrl,
            onTap: () => context.push('/client/providers/${p.id}'),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.grey200,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_search_rounded,
              size: 48,
              color: AppColors.grey500,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No encontramos prestadores',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.grey700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Intenta con otros filtros o amplía tu búsqueda',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: AppColors.grey500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded,
                size: 48, color: AppColors.grey400),
            const SizedBox(height: 16),
            const Text(
              'Error al cargar prestadores',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.grey700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: AppColors.grey500,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => ref
                  .read(providersNotifierProvider(widget.categorySlug).notifier)
                  .load(categorySlug: widget.categorySlug),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text(
                'Reintentar',
                style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Filter chip widget ──────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? activeColor.withAlpha(20) : AppColors.grey100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? activeColor : AppColors.grey300,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 12,
              color: isActive ? activeColor : AppColors.grey500,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActive ? activeColor : AppColors.grey600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _SortChip({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _FilterChip(
      label: label,
      icon: icon,
      isActive: isActive,
      activeColor: AppColors.primary,
      onTap: onTap,
    );
  }
}
