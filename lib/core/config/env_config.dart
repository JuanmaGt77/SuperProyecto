class EnvConfig {
  EnvConfig._();

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://rktlejtvqffmikchgbnl.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_m_qQTV66nqC-7cr9nI5_PA_kg_VySWX',
  );

  static const String googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: 'YOUR_GOOGLE_MAPS_API_KEY',
  );

  static const String cloudinaryCloudName = String.fromEnvironment(
    'CLOUDINARY_CLOUD_NAME',
    defaultValue: 'YOUR_CLOUD_NAME',
  );

  static const String cloudinaryUploadPreset = String.fromEnvironment(
    'CLOUDINARY_UPLOAD_PRESET',
    defaultValue: 'servilink_unsigned',
  );

  // Para cargas firmadas — este valor solo existe en Edge Functions, no en Flutter
  // static const String cloudinaryApiSecret = 'NEVER_IN_FLUTTER';

  static bool get isProduction =>
      const bool.fromEnvironment('IS_PRODUCTION', defaultValue: false);

  static bool get isDevelopment => !isProduction;
}
