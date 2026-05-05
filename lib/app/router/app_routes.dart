class AppRoutes {
  AppRoutes._();

  // Splash & Onboarding
  static const String splash = '/';
  static const String onboarding = '/onboarding';

  // Auth
  static const String accountType = '/account-type';
  static const String login = '/login';
  static const String registerClient = '/register/client';
  static const String registerProvider = '/register/provider';
  static const String forgotPassword = '/forgot-password';

  // Client
  static const String clientHome = '/client';
  static const String clientCategories = '/client/categories';
  static const String clientCategoryProviders = '/client/categories/:slug';
  static const String clientMap = '/client/map';
  static const String clientProviderDetail = '/client/providers/:id';
  static const String clientCreateRequest = '/client/requests/new';
  static const String clientRequestDetail = '/client/requests/:id';
  static const String clientHistory = '/client/history';
  static const String clientChats = '/client/chats';
  static const String clientChatDetail = '/client/chats/:id';

  // Provider
  static const String providerHome = '/provider';
  static const String providerRequests = '/provider/requests';
  static const String providerRequestDetail = '/provider/requests/:id';
  static const String providerEarnings = '/provider/earnings';
  static const String providerProfile = '/provider/profile';
  static const String providerProfileEdit = '/provider/profile/edit';
  static const String providerGallery = '/provider/gallery';
  static const String providerVerification = '/provider/verification';
  static const String providerChats = '/provider/chats';
  static const String providerChatDetail = '/provider/chats/:id';

  // Shared
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String support = '/support';
  static const String reportProblem = '/report';
  static const String notifications = '/notifications';

  // Admin
  static const String adminHome = '/admin';
  static const String adminProviders = '/admin/providers';
  static const String adminUsers = '/admin/users';
  static const String adminReports = '/admin/reports';
}
