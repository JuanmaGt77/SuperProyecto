import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../shared/models/provider_model.dart';
import '../../data/provider_remote_datasource.dart';

enum ProviderSort { rating, distance, reviews }

class ProvidersState {
  final List<ProviderModel> providers;
  final List<ProviderModel> filtered;
  final bool isLoading;
  final String? error;
  final String searchQuery;
  final bool onlyAvailable;
  final ProviderSort sort;

  const ProvidersState({
    this.providers = const [],
    this.filtered = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
    this.onlyAvailable = false,
    this.sort = ProviderSort.rating,
  });

  ProvidersState copyWith({
    List<ProviderModel>? providers,
    List<ProviderModel>? filtered,
    bool? isLoading,
    String? error,
    String? searchQuery,
    bool? onlyAvailable,
    ProviderSort? sort,
  }) {
    return ProvidersState(
      providers: providers ?? this.providers,
      filtered: filtered ?? this.filtered,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
      onlyAvailable: onlyAvailable ?? this.onlyAvailable,
      sort: sort ?? this.sort,
    );
  }
}

class ProvidersNotifier extends StateNotifier<ProvidersState> {
  final ProviderRemoteDataSource _dataSource;

  ProvidersNotifier(this._dataSource) : super(const ProvidersState());

  Future<void> load({String? categorySlug}) async {
    state = state.copyWith(isLoading: true);
    try {
      final providers = await _dataSource.fetchProviders(
        categorySlug: categorySlug,
      );
      state = state.copyWith(
        isLoading: false,
        providers: providers,
        filtered: _applyFilters(providers, state.searchQuery, state.onlyAvailable, state.sort),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void search(String query) {
    state = state.copyWith(
      searchQuery: query,
      filtered: _applyFilters(state.providers, query, state.onlyAvailable, state.sort),
    );
  }

  void toggleAvailable(bool v) {
    state = state.copyWith(
      onlyAvailable: v,
      filtered: _applyFilters(state.providers, state.searchQuery, v, state.sort),
    );
  }

  void setSort(ProviderSort sort) {
    state = state.copyWith(
      sort: sort,
      filtered: _applyFilters(state.providers, state.searchQuery, state.onlyAvailable, sort),
    );
  }

  List<ProviderModel> _applyFilters(
    List<ProviderModel> all,
    String query,
    bool onlyAvailable,
    ProviderSort sort,
  ) {
    var list = all.where((p) {
      final q = query.toLowerCase();
      final matchSearch = q.isEmpty ||
          (p.fullName?.toLowerCase().contains(q) ?? false) ||
          p.categoryNames.any((c) => c.toLowerCase().contains(q));
      final matchAvail = !onlyAvailable || p.isAvailable;
      return matchSearch && matchAvail;
    }).toList();

    switch (sort) {
      case ProviderSort.rating:
        list.sort((a, b) => b.avgRating.compareTo(a.avgRating));
      case ProviderSort.reviews:
        list.sort((a, b) => b.totalReviews.compareTo(a.totalReviews));
      case ProviderSort.distance:
        list.sort((a, b) {
          if (a.distanceKm == null) return 1;
          if (b.distanceKm == null) return -1;
          return a.distanceKm!.compareTo(b.distanceKm!);
        });
    }

    return list;
  }
}

// ── Providers ──────────────────────────────────────────────────────────────

final _dataSourceProvider = Provider<ProviderRemoteDataSource>((ref) {
  return ProviderRemoteDataSource(Supabase.instance.client);
});

// Keyed by categorySlug (null = all categories)
final providersNotifierProvider = StateNotifierProvider.autoDispose
    .family<ProvidersNotifier, ProvidersState, String?>((ref, categorySlug) {
  return ProvidersNotifier(ref.read(_dataSourceProvider));
});

// Shorthand used by ClientHomeScreen (no category filter)
final nearbyProvidersProvider = providersNotifierProvider(null);

// Single provider detail
final providerDetailProvider =
    FutureProvider.autoDispose.family<ProviderModel?, String>((ref, id) async {
  final ds = ref.read(_dataSourceProvider);
  return ds.fetchProviderById(id);
});
