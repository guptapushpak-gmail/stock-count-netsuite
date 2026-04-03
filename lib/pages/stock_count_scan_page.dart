import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';

class StockCountScanPage extends StatefulWidget {
  const StockCountScanPage({super.key});

  @override
  State<StockCountScanPage> createState() => _StockCountScanPageState();
}

class _StockCountScanPageState extends State<StockCountScanPage> {
  late final MobileScannerController _scanner = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: Platform.isMacOS ? CameraFacing.front : CameraFacing.back,
  );
  final TextEditingController _searchCtrl = TextEditingController();
  bool _showSearch = false;
  bool _cameraError = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scanner.dispose();
    super.dispose();
  }

  void _showManualEntry(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Enter Barcode'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'UPC / barcode'),
          onSubmitted: (v) {
            if (v.trim().isNotEmpty) {
              context.read<AppState>().addScanned(v.trim());
              HapticFeedback.selectionClick();
            }
            Navigator.pop(ctx);
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                context.read<AppState>().addScanned(ctrl.text.trim());
                HapticFeedback.selectionClick();
              }
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitFlow(BuildContext context) async {
    final app = context.read<AppState>();
    final accountOptions = app.adjustmentAccounts;
    final firstAccount = accountOptions.isNotEmpty ? accountOptions.first.id : '';
    final accountCtrl = TextEditingController(text: firstAccount);
    final subCtrl = TextEditingController(text: app.selectedLocation?.subsidiaryId ?? '');
    final memoCtrl = TextEditingController(text: 'Stock count adjustment');
    var selected = firstAccount.isEmpty ? 'custom' : firstAccount;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: const Text('Submit Adjustment'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selected,
                  decoration: const InputDecoration(labelText: 'Adjustment Account *'),
                  items: [
                    ...accountOptions.map((a) => DropdownMenuItem(
                          value: a.id,
                          child: Text(a.name, overflow: TextOverflow.ellipsis),
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
                  TextField(controller: accountCtrl, decoration: const InputDecoration(labelText: 'Account ID *')),
                ],
                const SizedBox(height: 8),
                TextField(
                  controller: subCtrl,
                  decoration: InputDecoration(
                    labelText: 'Subsidiary ID',
                    helperText: app.selectedLocation?.subsidiaryName,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(controller: memoCtrl, decoration: const InputDecoration(labelText: 'Memo')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Continue')),
          ],
        ),
      ),
    );

    if (confirmed != true || !context.mounted) return;
    final accountId = accountCtrl.text.trim();
    if (accountId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adjustment account is required')),
      );
      return;
    }

    final really = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Submission'),
        content: Text('Submit inventory adjustment?\n\nItems: ${app.scannedItems.length}\nAccount: $accountId'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Submit')),
        ],
      ),
    );

    if (really != true || !context.mounted) return;

    try {
      final id = await context.read<AppState>().submitInventoryAdjustment(
            adjustmentAccountId: accountId,
            subsidiaryId: subCtrl.text.trim().isEmpty ? null : subCtrl.text.trim(),
            memo: memoCtrl.text.trim(),
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Adjustment created: $id'), backgroundColor: Colors.green.shade700),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Submit failed: $e'), backgroundColor: Colors.red.shade700),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final colorScheme = Theme.of(context).colorScheme;
    final query = _searchCtrl.text.trim().toLowerCase();
    final filteredCatalog = query.isEmpty
        ? const <dynamic>[]
        : app.catalogItems.where((it) {
            return '${it.name} ${it.upc}'.toLowerCase().contains(query);
          }).take(20).toList();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Scan Items', style: TextStyle(fontWeight: FontWeight.w700)),
            if (app.selectedLocation != null)
              Text(app.selectedLocation!.name, style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
          ],
        ),
        actions: [
          if (app.scannedItems.isNotEmpty)
            TextButton.icon(
              onPressed: app.submitting ? null : () => _submitFlow(context),
              icon: app.submitting
                  ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.cloud_upload_outlined, size: 18),
              label: Text(app.submitting ? 'Submitting…' : 'Submit'),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          if (app.submitting) const LinearProgressIndicator(minHeight: 2),

          // Camera / fallback panel
          Expanded(
            flex: 5,
            child: _cameraError
                ? _NoCamera(
                    itemCount: app.scannedItems.fold(0, (s, i) => s + i.qty),
                    onManualEntry: () => _showManualEntry(context),
                    onSearch: () => setState(() => _showSearch = !_showSearch),
                    showSearch: _showSearch,
                  )
                : Stack(
                    children: [
                      MobileScanner(
                        controller: _scanner,
                        errorBuilder: (context, error, child) {
                          debugPrint('[SCANNER] Error: $error');
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) setState(() => _cameraError = true);
                          });
                          return const SizedBox.expand(child: ColoredBox(color: Colors.black));
                        },
                        onDetect: (capture) {
                          for (final b in capture.barcodes) {
                            final code = b.rawValue;
                            if (code != null && code.isNotEmpty) {
                              app.addScanned(code);
                              HapticFeedback.mediumImpact();
                            }
                          }
                        },
                      ),
                      Center(
                        child: Container(
                          width: 220,
                          height: 120,
                          decoration: BoxDecoration(
                            border: Border.all(color: colorScheme.primary, width: 2.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      if (app.scannedItems.isNotEmpty)
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${app.scannedItems.fold(0, (s, i) => s + i.qty)} items',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: colorScheme.onPrimaryContainer),
                            ),
                          ),
                        ),
                      Positioned(
                        bottom: 12,
                        right: 12,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FloatingActionButton.small(
                              heroTag: 'manual',
                              onPressed: () => _showManualEntry(context),
                              child: const Icon(Icons.keyboard),
                            ),
                            const SizedBox(height: 8),
                            FloatingActionButton.small(
                              heroTag: 'search',
                              onPressed: () => setState(() => _showSearch = !_showSearch),
                              child: Icon(_showSearch ? Icons.close : Icons.search),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),

          // Search bar
          if (_showSearch)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: TextField(
                controller: _searchCtrl,
                autofocus: true,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Search by name or UPC',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  isDense: true,
                ),
              ),
            ),

          // Search results
          if (_showSearch && query.isNotEmpty)
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 160),
              child: filteredCatalog.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text('No matches', style: TextStyle(color: colorScheme.onSurfaceVariant)),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: filteredCatalog.length,
                      itemBuilder: (_, i) {
                        final p = filteredCatalog[i];
                        return ListTile(
                          dense: true,
                          title: Text(p.name),
                          subtitle: Text(p.upc),
                          trailing: const Icon(Icons.add_circle_outline, size: 20),
                          onTap: () {
                            app.addScanned(p.upc);
                            HapticFeedback.selectionClick();
                          },
                        );
                      },
                    ),
            ),

          // Scanned items list
          Expanded(
            flex: 4,
            child: app.scannedItems.isEmpty
                ? Center(child: Text('Scan a barcode to start', style: TextStyle(color: colorScheme.onSurfaceVariant)))
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: app.scannedItems.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, indent: 16, endIndent: 16),
                    itemBuilder: (_, i) {
                      final it = app.scannedItems[i];
                      return ListTile(
                        dense: true,
                        title: Text(it.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                        subtitle: Text(it.upc, style: const TextStyle(fontSize: 12)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, size: 20),
                              onPressed: () => app.decreaseQty(it.itemId),
                              visualDensity: VisualDensity.compact,
                            ),
                            SizedBox(
                              width: 28,
                              child: Text('${it.qty}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline, size: 20),
                              onPressed: () => app.increaseQty(it.itemId),
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// Shown when no camera is available — provides manual entry and search as primary inputs.
class _NoCamera extends StatelessWidget {
  final int itemCount;
  final VoidCallback onManualEntry;
  final VoidCallback onSearch;
  final bool showSearch;

  const _NoCamera({
    required this.itemCount,
    required this.onManualEntry,
    required this.onSearch,
    required this.showSearch,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: colorScheme.surfaceContainerHighest,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.qr_code_scanner, size: 52, color: colorScheme.onSurfaceVariant),
          const SizedBox(height: 12),
          Text('Camera not available', style: TextStyle(fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
          const SizedBox(height: 4),
          Text('Use keyboard entry or search below', style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: onManualEntry,
                icon: const Icon(Icons.keyboard),
                label: const Text('Enter Barcode'),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: onSearch,
                icon: Icon(showSearch ? Icons.close : Icons.search),
                label: Text(showSearch ? 'Close Search' : 'Search Items'),
              ),
            ],
          ),
          if (itemCount > 0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$itemCount items scanned',
                style: TextStyle(fontWeight: FontWeight.w600, color: colorScheme.onPrimaryContainer),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
