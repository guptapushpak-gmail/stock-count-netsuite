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
  final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );
  final TextEditingController _searchCtrl = TextEditingController();
  // accounts loaded from NetSuite via AppState.adjustmentAccounts

  @override
  void dispose() {
    _searchCtrl.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final query = _searchCtrl.text.trim().toLowerCase();
    final filteredCatalog = query.isEmpty
        ? const []
        : app.catalogItems.where((it) {
            final hay = '${it.name} ${it.upc} ${it.id}'.toLowerCase();
            return hay.contains(query);
          }).take(30).toList(growable: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Items'),
        actions: [
          TextButton(
            onPressed: app.submitting
                ? null
                : () async {
                    final accountOptions = app.adjustmentAccounts;
                    final firstAccount = accountOptions.isNotEmpty ? accountOptions.first.id : '';
                    final accountCtrl = TextEditingController(text: firstAccount);
                    final subCtrl = TextEditingController(text: app.selectedLocation?.subsidiaryId ?? '');
                    final memoCtrl = TextEditingController(text: 'Stock count adjustment');
                    var selected = firstAccount.isEmpty ? 'custom' : firstAccount;

                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => StatefulBuilder(
                        builder: (ctx, setLocalState) => AlertDialog(
                          title: const Text('Submit Inventory Adjustment'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              DropdownButtonFormField<String>(
                                value: selected,
                                decoration: const InputDecoration(labelText: 'Adjustment Account *'),
                                items: [
                                  ...accountOptions.map(
                                    (a) => DropdownMenuItem(
                                      value: a.id,
                                      child: Text(a.name.isEmpty ? a.id : '${a.id} • ${a.name}'),
                                    ),
                                  ),
                                  const DropdownMenuItem(
                                    value: 'custom',
                                    child: Text('Custom account ID'),
                                  ),
                                ],
                                onChanged: (v) {
                                  if (v == null) return;
                                  setLocalState(() => selected = v);
                                  if (v != 'custom') {
                                    accountCtrl.text = v;
                                  } else {
                                    accountCtrl.text = '';
                                  }
                                },
                              ),
                              if (selected == 'custom') ...[
                                const SizedBox(height: 8),
                                TextField(
                                  controller: accountCtrl,
                                  decoration: const InputDecoration(labelText: 'Custom Adjustment Account ID *'),
                                ),
                              ],
                              const SizedBox(height: 8),
                              TextField(
                                controller: subCtrl,
                                decoration: InputDecoration(
                                  labelText: 'Subsidiary ID (auto from location)',
                                  helperText: app.selectedLocation?.subsidiaryName == null
                                      ? null
                                      : 'Subsidiary: ${app.selectedLocation!.subsidiaryName}',
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: memoCtrl,
                                decoration: const InputDecoration(labelText: 'Memo'),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Continue'),
                            ),
                          ],
                        ),
                      ),
                    );

                    if (confirmed != true || !context.mounted) return;
                    final accountId = accountCtrl.text.trim();
                    if (accountId.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Adjustment Account ID is required')),
                      );
                      return;
                    }

                    final reallySubmit = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Confirm Submission'),
                        content: Text(
                          'Submit inventory adjustment now?\n\n'
                          'Scanned lines: ${app.scannedItems.length}\n'
                          'Account: $accountId',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('No'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Yes, Submit'),
                          ),
                        ],
                      ),
                    );

                    if (reallySubmit != true || !context.mounted) return;

                    try {
                      final id = await context.read<AppState>().submitInventoryAdjustment(
                            adjustmentAccountId: accountId,
                            subsidiaryId: subCtrl.text.trim().isEmpty ? null : subCtrl.text.trim(),
                            memo: memoCtrl.text.trim(),
                          );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Inventory adjustment created: $id')),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Submit failed: $e')),
                        );
                      }
                    }
                  },
            child: Text(app.submitting ? 'Submitting...' : 'Submit'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          if (app.loading || app.submitting) const LinearProgressIndicator(minHeight: 2),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              'Loaded items with UPC: ${app.catalogItems.length}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search by name, UPC or ID',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Flexible(
            flex: 1,
            child: MobileScanner(
              controller: controller,
              onDetect: (capture) {
                final app = context.read<AppState>();
                var added = false;
                for (final b in capture.barcodes) {
                  final code = b.rawValue;
                  if (code != null && code.isNotEmpty) {
                    app.addScanned(code);
                    added = true;
                  }
                }
                if (added) {
                  HapticFeedback.mediumImpact();
                }
              },
            ),
          ),
          Flexible(
            flex: 3,
            child: Column(
              children: [
                const SizedBox(height: 8),
                const SizedBox(height: 0),
                Expanded(
                  child: ListView(
                    children: [
                      if (query.isNotEmpty) ...[
                        const ListTile(
                          dense: true,
                          title: Text('Matching products', style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                        if (filteredCatalog.isEmpty)
                          const ListTile(title: Text('No matching products')),
                        ...filteredCatalog.map(
                          (p) => ListTile(
                            dense: true,
                            title: Text(p.name),
                            subtitle: Text('ID: ${p.id} • UPC: ${p.upc}'),
                            trailing: const Icon(Icons.add),
                            onTap: () {
                              context.read<AppState>().addScanned(p.upc);
                              HapticFeedback.selectionClick();
                            },
                          ),
                        ),
                        const Divider(),
                      ],
                      const ListTile(
                        dense: true,
                        title: Text('Scanned items', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                      ...app.scannedItems.map((it) {
                        return ListTile(
                          title: Text(it.name),
                          subtitle: Text('ID: ${it.itemId} • UPC: ${it.upc}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () => context.read<AppState>().decreaseQty(it.itemId),
                              ),
                              Text('${it.qty}', style: const TextStyle(fontWeight: FontWeight.w700)),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: () => context.read<AppState>().increaseQty(it.itemId),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
