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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Stock Counts', style: TextStyle(fontWeight: FontWeight.w700)),
            if (app.selectedLocation != null)
              Text(
                app.selectedLocation!.name,
                style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
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
        icon: const Icon(Icons.add),
        label: const Text('New Count'),
      ),
      body: app.sessions.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.fact_check_outlined, size: 56, color: colorScheme.outlineVariant),
                  const SizedBox(height: 12),
                  Text(
                    'No stock counts yet',
                    style: TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tap + New Count to start',
                    style: TextStyle(fontSize: 13, color: colorScheme.outline),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              itemCount: app.sessions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final s = app.sessions[i];
                final sessionNumber = app.sessions.length - i;
                final locationName = app.locations
                    .where((l) => l.id == s.locationId)
                    .map((l) => l.name)
                    .firstOrNull ?? s.locationId;
                return _SessionCard(
                  session: s,
                  sessionNumber: sessionNumber,
                  locationName: locationName,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const StockCountScanPage()),
                  ),
                );
              },
            ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final CountSession session;
  final int sessionNumber;
  final String locationName;
  final VoidCallback onTap;

  const _SessionCard({
    required this.session,
    required this.sessionNumber,
    required this.locationName,
    required this.onTap,
  });

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dt.year, dt.month, dt.day);
    final timeStr = _formatTime(dt);

    if (date == today) return 'Today, $timeStr';
    if (date == today.subtract(const Duration(days: 1))) return 'Yesterday, $timeStr';
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[dt.month - 1]} ${dt.day}, $timeStr';
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $ampm';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isCompleted = session.status == 'completed';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Count #$sessionNumber',
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                        const SizedBox(width: 8),
                        _StatusBadge(isCompleted: isCompleted),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      locationName,
                      style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(session.createdAt),
                      style: TextStyle(fontSize: 12, color: colorScheme.outline),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: colorScheme.outline),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isCompleted;
  const _StatusBadge({required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isCompleted ? colorScheme.secondaryContainer : colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isCompleted ? 'Completed' : 'In Progress',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isCompleted ? colorScheme.onSecondaryContainer : colorScheme.onTertiaryContainer,
        ),
      ),
    );
  }
}
