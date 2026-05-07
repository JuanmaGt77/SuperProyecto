import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/account_type_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_client_screen.dart';
import '../../features/auth/presentation/screens/register_provider_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/client/home/presentation/screens/client_home_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/provider/home/presentation/screens/provider_home_screen.dart';
import '../../features/client/providers/presentation/screens/provider_detail_screen.dart';
import '../../features/client/providers/presentation/screens/providers_list_screen.dart';
import '../../features/shared/placeholder_screen.dart';
import '../../features/shared/profile/presentation/screens/profile_screen.dart';
import '../../features/shared/profile/presentation/screens/profile_edit_screen.dart';
import '../../shared/models/user_model.dart';
import 'app_routes.dart';

class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> _rootNavKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  // Rutas que no requieren autenticación
  static const _publicRoutes = [
    AppRoutes.splash,
    AppRoutes.onboarding,
    AppRoutes.accountType,
    AppRoutes.login,
    AppRoutes.registerClient,
    AppRoutes.registerProvider,
    AppRoutes.forgotPassword,
  ];

  static GoRouter buildRouter(WidgetRef ref) {
    final authNotifier = ref.read(authProvider.notifier);

    return GoRouter(
      navigatorKey: _rootNavKey,
      initialLocation: AppRoutes.splash,
      refreshListenable: _AuthChangeNotifier(ref),
      redirect: (context, state) {
        final authState = ref.read(authProvider);
        final location = state.matchedLocation;
        final isPublic = _publicRoutes.contains(location);

        // Splash siempre pasa — maneja su propia lógica
        if (location == AppRoutes.splash) return null;

        // Si está cargando, dejar en splash
        if (authState.isLoading) return AppRoutes.splash;

        // Si no está autenticado y va a ruta privada → login
        if (!authState.isAuthenticated && !isPublic) {
          return AppRoutes.login;
        }

        // Si está autenticado y va a ruta pública → redirigir a su home
        if (authState.isAuthenticated && isPublic) {
          return _homeForRole(authState.user!.role);
        }

        // Verificar acceso por rol
        if (authState.isAuthenticated && authState.user != null) {
          final role = authState.user!.role;
          if (location.startsWith('/client') && role != UserRole.client && role != UserRole.admin) {
            return _homeForRole(role);
          }
          if (location.startsWith('/provider') && role != UserRole.provider && role != UserRole.admin) {
            return _homeForRole(role);
          }
          if (location.startsWith('/admin') && role != UserRole.admin) {
            return _homeForRole(role);
          }
        }

        return null;
      },
      routes: [
        GoRoute(
          path: AppRoutes.splash,
          builder: (_, __) => const SplashScreen(),
        ),
        GoRoute(
          path: AppRoutes.onboarding,
          builder: (_, __) => const OnboardingScreen(),
        ),
        GoRoute(
          path: AppRoutes.accountType,
          builder: (_, __) => const AccountTypeScreen(),
        ),
        GoRoute(
          path: AppRoutes.login,
          builder: (_, __) => const LoginScreen(),
        ),
        GoRoute(
          path: AppRoutes.registerClient,
          builder: (_, __) => const RegisterClientScreen(),
        ),
        GoRoute(
          path: AppRoutes.registerProvider,
          builder: (_, __) => const RegisterProviderScreen(),
        ),
        GoRoute(
          path: AppRoutes.forgotPassword,
          builder: (_, __) => const ForgotPasswordScreen(),
        ),

        // ── Cliente ──────────────────────────────────────────────────────────
        GoRoute(
          path: AppRoutes.clientHome,
          builder: (_, __) => const ClientHomeScreen(),
        ),
        GoRoute(
          path: '/client/categories/:slug',
          builder: (_, st) => ProvidersListScreen(
            categorySlug: st.pathParameters['slug'],
          ),
        ),
        GoRoute(
          path: '/client/providers/:id',
          builder: (_, st) => ProviderDetailScreen(
            providerId: st.pathParameters['id']!,
          ),
        ),
        GoRoute(
          path: AppRoutes.clientCategories,
          builder: (_, __) => const ProvidersListScreen(),
        ),
        GoRoute(
          path: AppRoutes.clientMap,
          builder: (_, __) => const PlaceholderScreen(
            title: 'Mapa de prestadores',
            subtitle: 'Google Maps + PostGIS — Fase 5.',
            icon: Icons.map_rounded,
          ),
        ),
        GoRoute(
          path: AppRoutes.clientCreateRequest,
          builder: (_, __) => const PlaceholderScreen(
            title: 'Crear solicitud',
            subtitle: 'Formulario de servicio — Fase 6.',
            icon: Icons.add_box_rounded,
          ),
        ),
        GoRoute(
          path: AppRoutes.clientHistory,
          builder: (_, __) => const PlaceholderScreen(
            title: 'Historial de servicios',
            icon: Icons.history_rounded,
          ),
        ),
        GoRoute(
          path: AppRoutes.clientChats,
          builder: (_, __) => const PlaceholderScreen(
            title: 'Mis chats',
            subtitle: 'Chat en tiempo real — Fase 7.',
            icon: Icons.chat_bubble_rounded,
          ),
        ),

        // ── Prestador ────────────────────────────────────────────────────────
        GoRoute(
          path: AppRoutes.providerHome,
          builder: (_, __) => const ProviderHomeScreen(),
        ),
        GoRoute(
          path: AppRoutes.providerEarnings,
          builder: (_, __) => const PlaceholderScreen(
            title: 'Mis ganancias',
            icon: Icons.attach_money_rounded,
          ),
        ),
        GoRoute(
          path: AppRoutes.providerVerification,
          builder: (_, __) => const PlaceholderScreen(
            title: 'Verificación de cuenta',
            subtitle: 'Sube tu documento e identidad.',
            icon: Icons.verified_user_rounded,
          ),
        ),

        // ── Compartidas ──────────────────────────────────────────────────────
        GoRoute(
          path: AppRoutes.profile,
          builder: (_, __) => const ProfileScreen(),
          routes: [
            GoRoute(
              path: 'edit',
              builder: (_, __) => const ProfileEditScreen(),
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.notifications,
          builder: (_, __) => const PlaceholderScreen(
            title: 'Notificaciones',
            icon: Icons.notifications_rounded,
          ),
        ),
        GoRoute(
          path: AppRoutes.settings,
          builder: (_, __) => const PlaceholderScreen(
            title: 'Configuración',
            icon: Icons.settings_rounded,
          ),
        ),
        GoRoute(
          path: AppRoutes.support,
          builder: (_, __) => const PlaceholderScreen(
            title: 'Soporte',
            icon: Icons.support_agent_rounded,
          ),
        ),

        // ── Admin ────────────────────────────────────────────────────────────
        GoRoute(
          path: AppRoutes.adminHome,
          builder: (_, __) => const PlaceholderScreen(
            title: 'Panel de administración',
            subtitle: 'Gestión de prestadores y reportes — Fase 10.',
            icon: Icons.admin_panel_settings_rounded,
          ),
        ),
      ],
      errorBuilder: (_, state) => Scaffold(
        appBar: AppBar(title: const Text('Página no encontrada')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
              const SizedBox(height: 16),
              Text('Ruta no encontrada: ${state.uri}'),
            ],
          ),
        ),
      ),
    );
  }

  static String _homeForRole(UserRole role) {
    switch (role) {
      case UserRole.client:
        return AppRoutes.clientHome;
      case UserRole.provider:
        return AppRoutes.providerHome;
      case UserRole.admin:
        return AppRoutes.adminHome;
    }
  }
}

/// Notifica al router cuando cambia el estado de auth
class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(WidgetRef ref) {
    ref.listen(authProvider, (_, __) => notifyListeners());
  }
}
