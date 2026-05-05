import 'package:equatable/equatable.dart';

enum QuoteStatus { pending, accepted, rejected, cancelled, expired }

extension QuoteStatusExt on QuoteStatus {
  String get value {
    switch (this) {
      case QuoteStatus.pending: return 'pending';
      case QuoteStatus.accepted: return 'accepted';
      case QuoteStatus.rejected: return 'rejected';
      case QuoteStatus.cancelled: return 'cancelled';
      case QuoteStatus.expired: return 'expired';
    }
  }

  String get displayName {
    switch (this) {
      case QuoteStatus.pending: return 'Pendiente';
      case QuoteStatus.accepted: return 'Aceptada';
      case QuoteStatus.rejected: return 'Rechazada';
      case QuoteStatus.cancelled: return 'Cancelada';
      case QuoteStatus.expired: return 'Expirada';
    }
  }

  static QuoteStatus fromString(String value) {
    return QuoteStatus.values.firstWhere(
      (s) => s.value == value,
      orElse: () => QuoteStatus.pending,
    );
  }
}

class QuoteModel extends Equatable {
  final String id;
  final String requestId;
  final String providerId;
  final double price;
  final String description;
  final bool includesMaterials;
  final String? estimatedDuration;
  final String? conditions;
  final DateTime? proposedDate;
  final QuoteStatus status;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Joined
  final String? providerName;
  final String? providerAvatarUrl;
  final double? providerRating;

  const QuoteModel({
    required this.id,
    required this.requestId,
    required this.providerId,
    required this.price,
    required this.description,
    this.includesMaterials = false,
    this.estimatedDuration,
    this.conditions,
    this.proposedDate,
    this.status = QuoteStatus.pending,
    this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
    this.providerName,
    this.providerAvatarUrl,
    this.providerRating,
  });

  factory QuoteModel.fromJson(Map<String, dynamic> json) {
    return QuoteModel(
      id: json['id'] as String,
      requestId: json['request_id'] as String,
      providerId: json['provider_id'] as String,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String,
      includesMaterials: json['includes_materials'] as bool? ?? false,
      estimatedDuration: json['estimated_duration'] as String?,
      conditions: json['conditions'] as String?,
      proposedDate: json['proposed_date'] != null
          ? DateTime.parse(json['proposed_date'] as String)
          : null,
      status: QuoteStatusExt.fromString(json['status'] as String? ?? 'pending'),
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      providerName: json['provider_name'] as String?,
      providerAvatarUrl: json['provider_avatar_url'] as String?,
      providerRating: (json['provider_rating'] as num?)?.toDouble(),
    );
  }

  bool get isExpired =>
      expiresAt != null && DateTime.now().isAfter(expiresAt!);

  @override
  List<Object?> get props => [id, status, updatedAt];
}
