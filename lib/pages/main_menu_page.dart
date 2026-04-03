import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import 'auth_page.dart';
import 'stock_count_sessions_page.dart';

class MainMenuPage extends StatefulWidget {
  const MainMenuPage({super.key});

  @override
  State<MainMenuPage> createState() => _MainMenuPageState();
}

class _MainMenuPageState extends State<MainMenuPage> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: Text(_tab == 0 ? 'Home' : 'Settings')),
      body: _tab == 0
          ? Center(
              child: IconButton.filledTonal(
                iconSize: 54,
                icon: const Icon(Icons.inventory_2),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const StockCountSessionsPage()));
                },
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ListTile(
                  title: const Text('Selected Location'),
                  subtitle: Text(app.selectedLocation?.name ?? '-'),
                ),
                ListTile(
                  title: const Text('Subsidiary'),
                  subtitle: Text(app.selectedLocation?.subsidiaryName ?? '-'),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () async {
                    await context.read<AppState>().logoutAndClearToken();
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const AuthPage()),
                        (_) => false,
                      );
                    }
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                ),
              ],
            ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: [
            Expanded(
              child: TextButton.icon(
                onPressed: () => setState(() => _tab = 0),
                icon: Icon(Icons.home, color: _tab == 0 ? Theme.of(context).colorScheme.primary : null),
                label: Text('Home', style: TextStyle(color: _tab == 0 ? Theme.of(context).colorScheme.primary : null)),
              ),
            ),
            Expanded(
              child: TextButton.icon(
                onPressed: () => setState(() => _tab = 1),
                icon: Icon(Icons.settings, color: _tab == 1 ? Theme.of(context).colorScheme.primary : null),
                label: Text('Settings', style: TextStyle(color: _tab == 1 ? Theme.of(context).colorScheme.primary : null)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
