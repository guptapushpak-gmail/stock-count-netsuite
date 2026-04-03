import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import 'stock_count_scan_page.dart';

class StockCountSessionsPage extends StatelessWidget {
  const StockCountSessionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Stock Counts')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final session = CountSession(
            id: const Uuid().v4(),
            locationId: app.selectedLocation?.id ?? 'unknown',
            status: 'started',
            createdAt: DateTime.now(),
          );
          context.read<AppState>().addSession(session);
          Navigator.push(context, MaterialPageRoute(builder: (_) => const StockCountScanPage()));
        },
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: app.sessions.length,
        itemBuilder: (_, i) {
          final s = app.sessions[i];
          return ListTile(
            leading: const Icon(Icons.fact_check),
            title: Text('Session ${s.id.substring(0, 8)}'),
            subtitle: Text('${s.status} • ${s.createdAt}'),
          );
        },
      ),
    );
  }
}
