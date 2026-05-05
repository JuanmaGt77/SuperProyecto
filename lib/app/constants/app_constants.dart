class AppConstants {
  AppConstants._();

  static const String appName = 'ServiLink';
  static const String appTagline = 'Tu servicio, a un toque de distancia';
  static const String appVersion = '1.0.0';

  // Supabase
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  // Google Maps
  static const String googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: '',
  );

  // Cloudinary
  static const String cloudinaryCloudName = String.fromEnvironment(
    'CLOUDINARY_CLOUD_NAME',
    defaultValue: '',
  );
  static const String cloudinaryUploadPreset = String.fromEnvironment(
    'CLOUDINARY_UPLOAD_PRESET',
    defaultValue: 'servilink_unsigned',
  );

  // Defaults
  static const double defaultCoverageRadiusKm = 10.0;
  static const double maxCoverageRadiusKm = 50.0;
  static const int defaultSearchRadiusKm = 10;
  static const double platformFeePercent = 10.0;
  static const int quoteExpiryHours = 24;

  // Pagination
  static const int defaultPageSize = 20;

  // Service categories
  static const List<Map<String, String>> serviceCategories = [
    {
      'slug': 'mecanico',
      'name': 'Mecánico',
      'fullName': 'Mecánico Automotriz',
      'icon': 'assets/icons/cat_car.svg',
      'color': '#EF4444',
    },
    {
      'slug': 'albanil',
      'name': 'Albañil',
      'fullName': 'Albañil',
      'icon': 'assets/icons/cat_brick.svg',
      'color': '#F97316',
    },
    {
      'slug': 'electricista',
      'name': 'Electricista',
      'fullName': 'Electricista',
      'icon': 'assets/icons/cat_bolt.svg',
      'color': '#EAB308',
    },
    {
      'slug': 'soldador',
      'name': 'Soldador',
      'fullName': 'Soldador',
      'icon': 'assets/icons/cat_flame.svg',
      'color': '#3B82F6',
    },
    {
      'slug': 'plomero',
      'name': 'Plomero',
      'fullName': 'Plomero',
      'icon': 'assets/icons/cat_pipe.svg',
      'color': '#22C55E',
    },
  ];

  // Service statuses
  static const String statusCreated = 'created';
  static const String statusWaitingProvider = 'waiting_provider';
  static const String statusQuoteSent = 'quote_sent';
  static const String statusQuoteAccepted = 'quote_accepted';
  static const String statusProviderOnWay = 'provider_on_way';
  static const String statusProviderArrived = 'provider_arrived';
  static const String statusInProgress = 'in_progress';
  static const String statusCompleted = 'completed';
  static const String statusPaymentPending = 'payment_pending';
  static const String statusPaid = 'paid';
  static const String statusCancelled = 'cancelled';
  static const String statusReported = 'reported';

  // User roles
  static const String roleClient = 'client';
  static const String roleProvider = 'provider';
  static const String roleAdmin = 'admin';

  // Verification statuses
  static const String verificationPending = 'pending';
  static const String verificationInReview = 'in_review';
  static const String verificationApproved = 'approved';
  static const String verificationRejected = 'rejected';
  static const String verificationSuspended = 'suspended';

  // Cloudinary folders
  static const String cloudinaryAvatars = 'servilink/avatars';
  static const String cloudinaryGallery = 'servilink/gallery';
  static const String cloudinaryRequests = 'servilink/requests';
  static const String cloudinaryChat = 'servilink/chat';
  static const String cloudinaryReviews = 'servilink/reviews';
  static const String cloudinaryDocuments = 'servilink/documents';
}
