import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import 'main_menu_page.dart';

class LocationListPage extends StatelessWidget {
  const LocationListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Locations')),
      body: Column(
        children: [
          if (app.loading) const LinearProgressIndicator(minHeight: 2),
          if (app.error != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(app.error!, style: const TextStyle(color: Colors.red)),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: app.locations.length,
              itemBuilder: (_, i) {
                final loc = app.locations[i];
                return ListTile(
                  title: Text(loc.name),
                  subtitle: Text('ID: ${loc.id} • Subsidiary: ${loc.subsidiaryName ?? '-'} (${loc.subsidiaryId ?? '-'})'),
                  onTap: () async {
                    await context.read<AppState>().downloadDataForLocation(loc);
                    if (context.mounted && context.read<AppState>().error == null) {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainMenuPage()));
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
