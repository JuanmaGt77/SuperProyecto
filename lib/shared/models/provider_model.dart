import 'package:equatable/equatable.dart';

enum VerificationStatus { pending, inReview, approved, rejected, suspended }

extension VerificationStatusExt on VerificationStatus {
  String get value {
    switch (this) {
      case VerificationStatus.pending:
        return 'pending';
      case VerificationStatus.inReview:
        return 'in_review';
      case VerificationStatus.approved:
        return 'approved';
      case VerificationStatus.rejected:
        return 'rejected';
      case VerificationStatus.suspended:
        return 'suspended';
    }
  }

  String get displayName {
    switch (this) {
      case VerificationStatus.pending:
        return 'Pendiente';
      case VerificationStatus.inReview:
        return 'En revisión';
      case VerificationStatus.approved:
        return 'Aprobado';
      case VerificationStatus.rejected:
        return 'Rechazado';
      case VerificationStatus.suspended:
        return 'Suspendido';
    }
  }

  static VerificationStatus fromString(String value) {
    switch (value) {
      case 'in_review':
        return VerificationStatus.inReview;
      case 'approved':
        return VerificationStatus.approved;
      case 'rejected':
        return VerificationStatus.rejected;
      case 'suspended':
        return VerificationStatus.suspended;
      default:
        return VerificationStatus.pending;
    }
  }
}

class ProviderModel extends Equatable {
  final String id;
  final String userId;
  final String? bio;
  final int yearsExperience;
  final double? baseLat;
  final double? baseLng;
  final double? currentLat;
  final double? currentLng;
  final double coverageRadiusKm;
  final List<String> workZones;
  final double? baseRate;
  final bool isAvailable;
  final bool isVerified;
  final VerificationStatus verificationStatus;
  final DateTime? verifiedAt;
  final double avgRating;
  final int totalReviews;
  final int totalJobs;
  final Map<String, dynamic>? schedule;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Joined fields
  final String? fullName;
  final String? email;
  final String? phone;
  final String? avatarUrl;
  final List<String> categoryNames;
  final List<String> categorySlugs;
  final double? distanceKm;

  const ProviderModel({
    required this.id,
    required this.userId,
    this.bio,
    this.yearsExperience = 0,
    this.baseLat,
    this.baseLng,
    this.currentLat,
    this.currentLng,
    this.coverageRadiusKm = 10.0,
    this.workZones = const [],
    this.baseRate,
    this.isAvailable = false,
    this.isVerified = false,
    this.verificationStatus = VerificationStatus.pending,
    this.verifiedAt,
    this.avgRating = 0.0,
    this.totalReviews = 0,
    this.totalJobs = 0,
    this.schedule,
    required this.createdAt,
    required this.updatedAt,
    this.fullName,
    this.email,
    this.phone,
    this.avatarUrl,
    this.categoryNames = const [],
    this.categorySlugs = const [],
    this.distanceKm,
  });

  factory ProviderModel.fromJson(Map<String, dynamic> json) {
    return ProviderModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      bio: json['bio'] as String?,
      yearsExperience: json['years_experience'] as int? ?? 0,
      coverageRadiusKm: (json['coverage_radius_km'] as num?)?.toDouble() ?? 10.0,
      workZones: (json['work_zones'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      baseRate: (json['base_rate'] as num?)?.toDouble(),
      isAvailable: json['is_available'] as bool? ?? false,
      isVerified: json['is_verified'] as bool? ?? false,
      verificationStatus: VerificationStatusExt.fromString(
        json['verification_status'] as String? ?? 'pending',
      ),
      verifiedAt: json['verified_at'] != null
          ? DateTime.parse(json['verified_at'] as String)
          : null,
      avgRating: (json['avg_rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['total_reviews'] as int? ?? 0,
      totalJobs: json['total_jobs'] as int? ?? 0,
      schedule: json['schedule'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      // Joined
      fullName: json['full_name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      categoryNames: (json['category_names'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      categorySlugs: (json['category_slugs'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
    );
  }

  String get primaryCategoryName =>
      categoryNames.isNotEmpty ? categoryNames.first : 'Sin categoría';

  String get ratingDisplay => avgRating.toStringAsFixed(1);

  bool get isApproved => verificationStatus == VerificationStatus.approved;

  @override
  List<Object?> get props => [id, userId, isAvailable, verificationStatus];
}
