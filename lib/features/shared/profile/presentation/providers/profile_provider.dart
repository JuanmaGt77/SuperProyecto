import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/cloudinary/cloudinary_service.dart';
import '../../../../../core/supabase/supabase_config.dart';
import '../../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../../shared/models/user_model.dart';

class ProfileState {
  final bool isLoading;
  final String? error;
  final String? successMessage;

  const ProfileState({
    this.isLoading = false,
    this.error,
    this.successMessage,
  });

  ProfileState copyWith({
    bool? isLoading,
    String? error,
    String? successMessage,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      successMessage: successMessage,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final Ref _ref;
  final SupabaseClient _client = SupabaseConfig.client;

  ProfileNotifier(this._ref) : super(const ProfileState());

  Future<bool> updateProfile({
    required String fullName,
    String? phone,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) throw Exception('Sin sesión activa');

      await _client.from('users').update({
        'full_name': fullName,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
      }).eq('id', userId);

      await _ref.read(authProvider.notifier).refreshUser();
      state = state.copyWith(isLoading: false, successMessage: 'Perfil actualizado');
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Error al actualizar: $e');
      return false;
    }
  }

  Future<bool> updateAvatar(File imageFile) async {
    state = state.copyWith(isLoading: true);
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) throw Exception('Sin sesión activa');

      final result = await CloudinaryService.instance.uploadImage(
        imageFile: imageFile,
        folder: 'proyect/avatars',
        publicId: 'avatar_$userId',
      );

      await _client.from('users').update({
        'avatar_url': result.secureUrl,
        'avatar_public_id': result.publicId,
      }).eq('id', userId);

      await _ref.read(authProvider.notifier).refreshUser();
      state = state.copyWith(isLoading: false, successMessage: 'Foto actualizada');
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Error al subir foto: $e');
      return false;
    }
  }

  void clearMessages() {
    state = state.copyWith(error: null, successMessage: null);
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>(
  (ref) => ProfileNotifier(ref),
);
