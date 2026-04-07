import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/app_database.dart';
import 'state/app_state.dart';
import 'pages/auth_page.dart';
import 'pages/location_list_page.dart';
import 'pages/main_menu_page.dart';
import 'pages/netsuite_auth_webview.dart';
import 'services/netsuite_api.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(db)..bootstrap(),
      child: const StockCountApp(),
    ),
  );
}

class StockCountApp extends StatelessWidget {
  const StockCountApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NetStore Next',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      // Wraps every screen so re-auth can be triggered from anywhere.
      builder: (context, child) => _ReAuthOverlay(child: child!),
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

// ── Re-auth overlay ───────────────────────────────────────────────────────────

/// Wraps the entire app and watches [AppState.needsReAuth].
/// When the flag is set (e.g. because an API call received a 401), it
/// presents the NetSuite OAuth WebView on top of whatever screen is active.
/// The user can re-authenticate without losing any in-progress work.
class _ReAuthOverlay extends StatefulWidget {
  final Widget child;
  const _ReAuthOverlay({required this.child});

  @override
  State<_ReAuthOverlay> createState() => _ReAuthOverlayState();
}

class _ReAuthOverlayState extends State<_ReAuthOverlay> {
  bool _dialogShowing = false;

  @override
  void initState() {
    super.initState();
    context.read<AppState>().addListener(_onStateChanged);
  }

  @override
  void dispose() {
    context.read<AppState>().removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    final app = context.read<AppState>();
    if (app.needsReAuth && !_dialogShowing && mounted) {
      _dialogShowing = true;
      // Defer so the current build frame completes before showing the dialog.
      WidgetsBinding.instance.addPostFrameCallback((_) => _showReAuthDialog());
    }
  }

  Future<void> _showReAuthDialog() async {
    if (!mounted) return;
    final app = context.read<AppState>();

    final cfg = NetSuiteAuthConfig(
      clientId: kNetSuiteClientId,
      clientSecret: kNetSuiteClientSecret,
      redirectUri: kNetSuiteRedirectUri,
    );
    final oauthState = AppState.generateRandomState();
    final authorizeUrl = cfg.buildAuthorizeUrl(state: oauthState);

    final callbackUrl = await showNetSuiteAuthWebView(
      context,
      authorizeUrl,
      Uri.parse(kNetSuiteRedirectUri).scheme,
    );

    if (!mounted) return;

    if (callbackUrl != null) {
      await app.completeReAuth(
        cfg: cfg,
        callbackUrl: callbackUrl,
        expectedState: oauthState,
      );
    } else {
      await app.cancelReAuth();
    }

    _dialogShowing = false;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

// ── Splash ────────────────────────────────────────────────────────────────────

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
