import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/database/hive_service.dart';
import 'core/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // import google_sign_in.dart tidak dibutuhkan lagi di sini jika tidak dipanggil
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // init Hive & Session
  await HiveService.init();

  // init Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // init Notifications
  await NotificationService.init();

  // init intl Locale
  await initializeDateFormatting('id_ID', null);

  runApp(const ProviderScope(child: DuitKuApp()));
}

class DuitKuApp extends ConsumerWidget {
  const DuitKuApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'DuitKu',
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
