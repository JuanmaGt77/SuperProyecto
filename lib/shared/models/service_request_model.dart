import 'package:equatable/equatable.dart';

enum ServiceStatus {
  created,
  waitingProvider,
  quoteSent,
  quoteAccepted,
  providerOnWay,
  providerArrived,
  inProgress,
  completed,
  paymentPending,
  paid,
  cancelled,
  reported,
}

extension ServiceStatusExt on ServiceStatus {
  String get value {
    switch (this) {
      case ServiceStatus.created: return 'created';
      case ServiceStatus.waitingProvider: return 'waiting_provider';
      case ServiceStatus.quoteSent: return 'quote_sent';
      case ServiceStatus.quoteAccepted: return 'quote_accepted';
      case ServiceStatus.providerOnWay: return 'provider_on_way';
      case ServiceStatus.providerArrived: return 'provider_arrived';
      case ServiceStatus.inProgress: return 'in_progress';
      case ServiceStatus.completed: return 'completed';
      case ServiceStatus.paymentPending: return 'payment_pending';
      case ServiceStatus.paid: return 'paid';
      case ServiceStatus.cancelled: return 'cancelled';
      case ServiceStatus.reported: return 'reported';
    }
  }

  String get displayName {
    switch (this) {
      case ServiceStatus.created: return 'Solicitud creada';
      case ServiceStatus.waitingProvider: return 'Esperando respuesta';
      case ServiceStatus.quoteSent: return 'Cotización enviada';
      case ServiceStatus.quoteAccepted: return 'Cotización aceptada';
      case ServiceStatus.providerOnWay: return 'Prestador en camino';
      case ServiceStatus.providerArrived: return 'Prestador llegó';
      case ServiceStatus.inProgress: return 'En progreso';
      case ServiceStatus.completed: return 'Servicio finalizado';
      case ServiceStatus.paymentPending: return 'Pago pendiente';
      case ServiceStatus.paid: return 'Pagado';
      case ServiceStatus.cancelled: return 'Cancelado';
      case ServiceStatus.reported: return 'Reportado';
    }
  }

  static ServiceStatus fromString(String value) {
    return ServiceStatus.values.firstWhere(
      (s) => s.value == value,
      orElse: () => ServiceStatus.created,
    );
  }
}

enum UrgencyLevel { normal, urgent, scheduled }

extension UrgencyLevelExt on UrgencyLevel {
  String get value {
    switch (this) {
      case UrgencyLevel.normal: return 'normal';
      case UrgencyLevel.urgent: return 'urgent';
      case UrgencyLevel.scheduled: return 'scheduled';
    }
  }

  String get displayName {
    switch (this) {
      case UrgencyLevel.normal: return 'Normal';
      case UrgencyLevel.urgent: return 'Urgente';
      case UrgencyLevel.scheduled: return 'Programado';
    }
  }

  static UrgencyLevel fromString(String value) {
    switch (value) {
      case 'urgent': return UrgencyLevel.urgent;
      case 'scheduled': return UrgencyLevel.scheduled;
      default: return UrgencyLevel.normal;
    }
  }
}

class ServiceRequestModel extends Equatable {
  final String id;
  final String clientId;
  final String? providerId;
  final String categoryId;
  final String title;
  final String description;
  final double? lat;
  final double? lng;
  final String? address;
  final UrgencyLevel urgency;
  final DateTime? scheduledAt;
  final double? estimatedBudget;
  final ServiceStatus status;
  final String paymentMethod;
  final double? totalAmount;
  final double? platformFee;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Joined
  final String? categoryName;
  final String? clientName;
  final String? providerName;
  final List<String> imageUrls;

  const ServiceRequestModel({
    required this.id,
    required this.clientId,
    this.providerId,
    required this.categoryId,
    required this.title,
    required this.description,
    this.lat,
    this.lng,
    this.address,
    this.urgency = UrgencyLevel.normal,
    this.scheduledAt,
    this.estimatedBudget,
    this.status = ServiceStatus.created,
    this.paymentMethod = 'cash',
    this.totalAmount,
    this.platformFee,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.categoryName,
    this.clientName,
    this.providerName,
    this.imageUrls = const [],
  });

  factory ServiceRequestModel.fromJson(Map<String, dynamic> json) {
    return ServiceRequestModel(
      id: json['id'] as String,
      clientId: json['client_id'] as String,
      providerId: json['provider_id'] as String?,
      categoryId: json['category_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      address: json['address'] as String?,
      urgency: UrgencyLevelExt.fromString(json['urgency'] as String? ?? 'normal'),
      scheduledAt: json['scheduled_at'] != null
          ? DateTime.parse(json['scheduled_at'] as String)
          : null,
      estimatedBudget: (json['estimated_budget'] as num?)?.toDouble(),
      status: ServiceStatusExt.fromString(json['status'] as String? ?? 'created'),
      paymentMethod: json['payment_method'] as String? ?? 'cash',
      totalAmount: (json['total_amount'] as num?)?.toDouble(),
      platformFee: (json['platform_fee'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      categoryName: json['category_name'] as String?,
      clientName: json['client_name'] as String?,
      providerName: json['provider_name'] as String?,
      imageUrls: (json['image_urls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toInsert() => {
        'client_id': clientId,
        if (providerId != null) 'provider_id': providerId,
        'category_id': categoryId,
        'title': title,
        'description': description,
        'address': address,
        'urgency': urgency.value,
        if (scheduledAt != null) 'scheduled_at': scheduledAt!.toIso8601String(),
        if (estimatedBudget != null) 'estimated_budget': estimatedBudget,
        'status': status.value,
        'payment_method': paymentMethod,
        if (notes != null) 'notes': notes,
      };

  @override
  List<Object?> get props => [id, status, updatedAt];
}
