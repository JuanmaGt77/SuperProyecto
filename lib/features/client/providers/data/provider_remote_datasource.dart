import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../shared/models/provider_model.dart';

class ProviderRemoteDataSource {
  final SupabaseClient _client;

  const ProviderRemoteDataSource(this._client);

  static const _select = '''
    *,
    users!inner(full_name, email, phone, avatar_url),
    provider_categories(service_categories(name, slug))
  ''';

  Future<List<ProviderModel>> fetchProviders({
    String? categorySlug,
    bool onlyAvailable = false,
  }) async {
    var query = _client
        .from('provider_profiles')
        .select(_select)
        .eq('verification_status', 'approved');

    if (onlyAvailable) {
      query = query.eq('is_available', true);
    }

    final response = await query.order('avg_rating', ascending: false);

    var providers = response
        .map<ProviderModel>((json) => _mapToModel(json))
        .toList();

    if (categorySlug != null && categorySlug.isNotEmpty) {
      providers = providers
          .where((p) => p.categorySlugs.contains(categorySlug))
          .toList();
    }

    return providers;
  }

  Future<ProviderModel?> fetchProviderById(String id) async {
    final response = await _client
        .from('provider_profiles')
        .select(_select)
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return _mapToModel(response);
  }

  ProviderModel _mapToModel(Map<String, dynamic> json) {
    final userMap = json['users'] as Map<String, dynamic>? ?? {};
    final providerCats =
        (json['provider_categories'] as List<dynamic>?) ?? [];

    final categoryNames = providerCats
        .map((pc) =>
            (pc['service_categories'] as Map<String, dynamic>?)?['name']
                as String?)
        .whereType<String>()
        .toList();

    final categorySlugs = providerCats
        .map((pc) =>
            (pc['service_categories'] as Map<String, dynamic>?)?['slug']
                as String?)
        .whereType<String>()
        .toList();

    final flat = Map<String, dynamic>.from(json)
      ..['full_name'] = userMap['full_name']
      ..['email'] = userMap['email']
      ..['phone'] = userMap['phone']
      ..['avatar_url'] = userMap['avatar_url']
      ..['category_names'] = categoryNames
      ..['category_slugs'] = categorySlugs
      ..remove('users')
      ..remove('provider_categories');

    return ProviderModel.fromJson(flat);
  }
}
