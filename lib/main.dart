import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/app.dart';
import 'core/supabase/supabase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Localización español
  await initializeDateFormatting('es', null);

  // Orientación
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Inicializa Supabase solo si las credenciales están configuradas
  try {
    await SupabaseConfig.initialize();
  } catch (e) {
    debugPrint('⚠️  Supabase no inicializado: $e');
    debugPrint('Configura SUPABASE_URL y SUPABASE_ANON_KEY como variables de entorno (--dart-define).');
  }

  runApp(
    const ProviderScope(
      child: ServiLinkApp(),
    ),
  );
}
