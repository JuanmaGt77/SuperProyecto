import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/account_type_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_client_screen.dart';
import '../../features/auth/presentation/screens/register_provider_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/client/home/presentation/screens/client_home_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/provider/home/presentation/screens/provider_home_screen.dart';
import '../../features/shared/placeholder_screen.dart';
import 'app_routes.dart';

class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> _rootNavKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  static GoRouter buildRouter() {
    return GoRouter(
      navigatorKey: _rootNavKey,
      initialLocation: AppRoutes.splash,
      debugLogDiagnostics: true,
      // TODO: Agregar redirect global para guardas por rol cuando AuthRepository esté listo
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

        // Cliente
        GoRoute(
          path: AppRoutes.clientHome,
          builder: (_, __) => const ClientHomeScreen(),
        ),
        GoRoute(
          path: '/client/categories/:slug',
          builder: (ctx, st) => PlaceholderScreen(
            title: 'Prestadores de ${st.pathParameters['slug']}',
            subtitle: 'Lista filtrada por categoría — se construye en Fase 4.',
            icon: Icons.list_alt_rounded,
          ),
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
            subtitle: 'Formulario de servicio + ubicación + fotos — Fase 6.',
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
            subtitle: 'Chat en tiempo real con Supabase Realtime — Fase 7.',
            icon: Icons.chat_bubble_rounded,
          ),
        ),

        // Prestador
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
            subtitle: 'Sube tu documento de identidad y selfie.',
            icon: Icons.verified_user_rounded,
          ),
        ),

        // Compartidas
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

        // Admin
        GoRoute(
          path: AppRoutes.adminHome,
          builder: (_, __) => const PlaceholderScreen(
            title: 'Panel de administración',
            subtitle: 'Gestión de prestadores, reportes y métricas — Fase 10.',
            icon: Icons.admin_panel_settings_rounded,
          ),
        ),
      ],
      errorBuilder: (_, state) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  size: 64, color: Colors.redAccent),
              const SizedBox(height: 16),
              Text('Ruta no encontrada: ${state.uri}'),
            ],
          ),
        ),
      ),
    );
  }
}
