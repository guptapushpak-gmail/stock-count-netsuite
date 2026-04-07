import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart'; // keep — used in _startNewCount
import '../models/models.dart';
import '../state/app_state.dart';
import 'stock_count_scan_page.dart';

class StockCountSessionsPage extends StatefulWidget {
  const StockCountSessionsPage({super.key});

  @override
  State<StockCountSessionsPage> createState() => _StockCountSessionsPageState();
}

class _StockCountSessionsPageState extends State<StockCountSessionsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 2, vsync: this);

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _startNewCount(BuildContext context, AppState app) async {
    final accountOptions = app.adjustmentAccounts;
    final firstAccountId = accountOptions.isNotEmpty ? accountOptions.first.id : '';
    var selected = firstAccountId.isEmpty ? 'custom' : firstAccountId;
    final accountCtrl = TextEditingController(
      text: app.pendingAdjustmentAccountId.isNotEmpty
          ? app.pendingAdjustmentAccountId
          : firstAccountId,
    );
    final memoCtrl = TextEditingController(text: app.pendingMemo);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: const Text('New Stock Count'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: selected,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Adjustment Account *'),
                  items: [
                    ...accountOptions.map((a) => DropdownMenuItem(
                          value: a.id,
                          child: Text(a.name, overflow: TextOverflow.ellipsis, maxLines: 1),
                        )),
                    const DropdownMenuItem(value: 'custom', child: Text('Enter manually')),
                  ],
                  onChanged: (v) {
                    if (v == null) return;
                    setLocal(() => selected = v);
                    accountCtrl.text = v == 'custom' ? '' : v;
                  },
                ),
                if (selected == 'custom') ...[
                  const SizedBox(height: 8),
                  TextField(
                    controller: accountCtrl,
                    decoration: const InputDecoration(labelText: 'Account ID *'),
                  ),
                ],
                const SizedBox(height: 8),
                TextField(
                  controller: memoCtrl,
                  decoration: const InputDecoration(labelText: 'Memo'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Start Count'),
            ),
          ],
        ),
      ),
    );

    final accountId = accountCtrl.text.trim();
    accountCtrl.dispose();
    final memo = memoCtrl.text.trim();
    memoCtrl.dispose();

    if (confirmed != true || !context.mounted) return;
    if (accountId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adjustment account is required')),
      );
      return;
    }

    // Store for use at submit time
    app.pendingAdjustmentAccountId = accountId;
    app.pendingMemo = memo;

    final session = CountSession(
      id: const Uuid().v4(),
      locationId: app.selectedLocation?.id ?? 'unknown',
      locationName: app.selectedLocation?.name ?? 'Unknown Location',
      status: 'in_progress',
      createdAt: DateTime.now(),
      memo: memo,
    );
    context.read<AppState>().addSession(session);
    if (context.mounted) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const StockCountScanPage()));
    }
  }

  Future<void> _confirmDelete(BuildContext context, CountSession session) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Count?'),
        content: Text(
          'This will permanently delete the stock count from ${_formatDate(session.createdAt)}.'
          '${session.status == 'in_progress' ? '\n\nAll scanned items will be lost.' : ''}',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Theme.of(ctx).colorScheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<AppState>().deleteSession(session.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final colorScheme = Theme.of(context).colorScheme;

    final inProgress = app.sessions.where((s) => s.status == 'in_progress').toList();
    final completed = app.sessions.where((s) => s.status == 'completed').toList();

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
        bottom: TabBar(
          controller: _tabs,
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('In Progress'),
                  if (inProgress.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    _CountBadge(count: inProgress.length, color: colorScheme.tertiary),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Submitted'),
                  if (completed.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    _CountBadge(count: completed.length, color: colorScheme.secondary),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _startNewCount(context, app),
        icon: const Icon(Icons.add),
        label: const Text('New Count'),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _SessionList(
            sessions: inProgress,
                        emptyIcon: Icons.inventory_2_outlined,
            emptyTitle: 'No active counts',
            emptySubtitle: 'Tap + New Count to start',
            onTap: (s) async {
              await context.read<AppState>().resumeSession(s.id);
              if (context.mounted) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const StockCountScanPage()));
              }
            },
            onDelete: (s) => _confirmDelete(context, s),
          ),
          _SessionList(
            sessions: completed,
                        emptyIcon: Icons.check_circle_outline_rounded,
            emptyTitle: 'No submitted counts',
            emptySubtitle: 'Submitted counts appear here',
            onTap: null, // completed sessions are read-only
            onDelete: (s) => _confirmDelete(context, s),
          ),
        ],
      ),
    );
  }
}

// ── Session list ──────────────────────────────────────────────────────────────

class _SessionList extends StatelessWidget {
  final List<CountSession> sessions;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptySubtitle;
  final void Function(CountSession)? onTap;
  final void Function(CountSession) onDelete;

  const _SessionList({
    required this.sessions,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (sessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(emptyIcon, size: 56, color: colorScheme.outlineVariant),
            const SizedBox(height: 12),
            Text(emptyTitle, style: TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant)),
            const SizedBox(height: 4),
            Text(emptySubtitle, style: TextStyle(fontSize: 13, color: colorScheme.outline)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: sessions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final s = sessions[i];
        return _SessionCard(
          session: s,
          onTap: onTap != null ? () => onTap!(s) : null,
          onDelete: () => onDelete(s),
        );
      },
    );
  }
}

// ── Session card ──────────────────────────────────────────────────────────────

class _SessionCard extends StatelessWidget {
  final CountSession session;
  final VoidCallback? onTap;
  final VoidCallback onDelete;

  const _SessionCard({
    required this.session,
    required this.onTap,
    required this.onDelete,
  });

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dt.year, dt.month, dt.day);
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour < 12 ? 'AM' : 'PM';
    final timeStr = '$h:$m $ampm';
    if (date == today) return 'Today, $timeStr';
    if (date == today.subtract(const Duration(days: 1))) return 'Yesterday, $timeStr';
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[dt.month - 1]} ${dt.day}, $timeStr';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dismissible(
      key: ValueKey(session.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        onDelete();
        return false; // let the delete handler manage removal
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(Icons.delete_outline_rounded, color: colorScheme.onErrorContainer),
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (session.memo.isNotEmpty)
                        Text(
                          session.memo,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                      if (session.memo.isNotEmpty) const SizedBox(height: 2),
                      Text(
                        session.locationName,
                        style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        _formatDate(session.createdAt),
                        style: TextStyle(fontSize: 12, color: colorScheme.outline),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _StatChip(
                            label: '${session.skuCount} SKU${session.skuCount == 1 ? '' : 's'}',
                            icon: Icons.inventory_2_outlined,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 6),
                          _StatChip(
                            label: '${session.totalQty} unit${session.totalQty == 1 ? '' : 's'}',
                            icon: Icons.numbers_rounded,
                            color: colorScheme.secondary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (onTap != null)
                  Icon(Icons.chevron_right_rounded, color: colorScheme.outline),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _StatChip({required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  final int count;
  final Color color;
  const _CountBadge({required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$count',
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}

String _formatDate(DateTime dt) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final date = DateTime(dt.year, dt.month, dt.day);
  final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
  final m = dt.minute.toString().padLeft(2, '0');
  final ampm = dt.hour < 12 ? 'AM' : 'PM';
  final timeStr = '$h:$m $ampm';
  if (date == today) return 'Today, $timeStr';
  if (date == today.subtract(const Duration(days: 1))) return 'Yesterday, $timeStr';
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${months[dt.month - 1]} ${dt.day}, $timeStr';
}
