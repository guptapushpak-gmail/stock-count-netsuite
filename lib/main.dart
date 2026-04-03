import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state/app_state.dart';
import 'pages/auth_page.dart';
import 'pages/location_list_page.dart';
import 'pages/main_menu_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState()..bootstrap(),
      child: const StockCountApp(),
    ),
  );
}

class StockCountApp extends StatelessWidget {
  const StockCountApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NetStore Pro Next',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const _AppRouter(),
    );
  }
}

class _AppRouter extends StatelessWidget {
  const _AppRouter();

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();

    // Show splash while bootstrap is running
    if (app.loading) {
      return const _SplashScreen();
    }

    // Authenticated + location selected → home/menu
    if (app.authenticated && app.selectedLocation != null) {
      return const MainMenuPage();
    }

    // Authenticated → pick a location
    if (app.authenticated && app.locations.isNotEmpty) {
      return const LocationListPage();
    }

    // Not authenticated — show login
    return const AuthPage();
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [colorScheme.primary, colorScheme.tertiary],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.inventory_2_rounded, color: Colors.white, size: 38),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.primary),
            ),
          ],
        ),
      ),
    );
  }
}
