import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import 'submit_flow.dart';

class StockCountScanPage extends StatefulWidget {
  const StockCountScanPage({super.key});

  @override
  State<StockCountScanPage> createState() => _StockCountScanPageState();
}

class _StockCountScanPageState extends State<StockCountScanPage> {
  Future<void> _showLotSerialDialog(
      BuildContext context, InventoryItemModel item) async {
    final app = context.read<AppState>();
    final isSerial = item.isSerialItem;
    // Pre-populate with any existing assignments
    final existing = app.scannedItems
        .where((s) => s.itemId == item.id)
        .expand((s) => s.lotSerialAssignments)
        .toList();

    final assignments = List<LotSerialAssignment>.from(existing);
    final numberCtrl = TextEditingController();
    final qtyCtrl = TextEditingController(text: isSerial ? '1' : '');

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: Text(isSerial ? 'Serial Numbers — ${item.name}' : 'Lot Numbers — ${item.name}'),
          content: SizedBox(
            width: 360,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (assignments.isNotEmpty) ...[
                    Text(isSerial ? 'Serial numbers:' : 'Lot assignments:',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 6),
                    ...assignments.asMap().entries.map((e) => Row(
                          children: [
                            Expanded(
                              child: Text('${e.value.number}  ×  ${e.value.qty}',
                                  style: const TextStyle(fontSize: 13)),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 16),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () =>
                                  setLocal(() => assignments.removeAt(e.key)),
                            ),
                          ],
                        )),
                    const Divider(height: 16),
                  ],
                  Text(isSerial ? 'Add serial number:' : 'Add lot number:',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: numberCtrl,
                          decoration: InputDecoration(
                            labelText: isSerial ? 'Serial #' : 'Lot #',
                            isDense: true,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      if (!isSerial) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: qtyCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Qty',
                              isDense: true,
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.add_circle),
                        onPressed: () {
                          final num = numberCtrl.text.trim();
                          final qty = isSerial ? 1 : (int.tryParse(qtyCtrl.text.trim()) ?? 0);
                          if (num.isEmpty || qty <= 0) return;
                          setLocal(() {
                            assignments.add(LotSerialAssignment(number: num, qty: qty));
                            numberCtrl.clear();
                            if (!isSerial) qtyCtrl.clear();
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            FilledButton(
              onPressed: assignments.isEmpty
                  ? null
                  : () {
                      final existing2 =
                          app.scannedItems.any((s) => s.itemId == item.id);
                      if (existing2) {
                        app.updateLotSerial(item.id, assignments);
                      } else {
                        app.addCatalogItem(item, lotSerialAssignments: assignments);
                      }
                      HapticFeedback.selectionClick();
                      Navigator.pop(ctx);
                    },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    numberCtrl.dispose();
    qtyCtrl.dispose();
  }

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

  Future<void> _submitFlow(BuildContext context) async {
    final submitted = await showSubmitFlow(context);
    if (submitted && context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final colorScheme = Theme.of(context).colorScheme;
    final query = _searchCtrl.text.trim().toLowerCase();
    final List<InventoryItemModel> filteredCatalog = query.isEmpty
        ? const []
        : app.catalogItems
            .where((it) => '${it.name} ${it.upc}'.toLowerCase().contains(query))
            .take(20)
            .toList();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Scan Items', style: TextStyle(fontWeight: FontWeight.w700)),
            if (app.selectedLocation != null)
              Text(app.selectedLocation!.name,
                  style:
                      TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
          ],
        ),
        actions: [
          if (app.scannedItems.isNotEmpty)
            TextButton.icon(
              onPressed: app.submitting ? null : () => _submitFlow(context),
              icon: app.submitting
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.cloud_upload_outlined, size: 18),
              label: Text(app.submitting ? 'Submitting…' : 'Submit'),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Wide (iPad / desktop ≥ 600 dp): camera left, list right
          // Narrow (phone): camera top 40%, list bottom 60%
          final isWide = constraints.maxWidth >= 600;

          final cameraPanel = _cameraError
              ? _NoCamera(
                  itemCount: app.scannedItems.fold(0, (s, i) => s + i.qty),
                  onSearch: () => setState(() => _showSearch = !_showSearch),
                  showSearch: _showSearch,
                )
              : _CameraView(
                  scanner: _scanner,
                  app: app,
                  colorScheme: colorScheme,
                  showSearch: _showSearch,
                  onToggleSearch: () => setState(() => _showSearch = !_showSearch),
                  onError: () => setState(() => _cameraError = true),
                  onLotSerialDetected: (item) =>
                      _showLotSerialDialog(context, item),
                );

          final itemsPanel = _ItemsPanel(
            app: app,
            colorScheme: colorScheme,
            showSearch: _showSearch,
            query: query,
            filteredCatalog: filteredCatalog,
            searchCtrl: _searchCtrl,
            onSearchChanged: () => setState(() {}),
            onLotSerialTap: (item) => _showLotSerialDialog(context, item),
          );

          return Column(
            children: [
              if (app.submitting) const LinearProgressIndicator(minHeight: 2),
              Expanded(
                child: isWide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(flex: 2, child: cameraPanel),
                          const VerticalDivider(width: 1),
                          Expanded(flex: 3, child: itemsPanel),
                        ],
                      )
                    : Column(
                        children: [
                          Expanded(flex: 3, child: cameraPanel),
                          const Divider(height: 1),
                          Expanded(flex: 7, child: itemsPanel),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Camera view ───────────────────────────────────────────────────────────────

class _CameraView extends StatelessWidget {
  final MobileScannerController scanner;
  final AppState app;
  final ColorScheme colorScheme;
  final bool showSearch;
  final VoidCallback onToggleSearch;
  final VoidCallback onError;
  final void Function(InventoryItemModel item)? onLotSerialDetected;

  const _CameraView({
    required this.scanner,
    required this.app,
    required this.colorScheme,
    required this.showSearch,
    required this.onToggleSearch,
    required this.onError,
    this.onLotSerialDetected,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        MobileScanner(
          controller: scanner,
          errorBuilder: (context, error, child) {
            debugPrint('[SCANNER] Error: $error');
            WidgetsBinding.instance.addPostFrameCallback((_) => onError());
            return const SizedBox.expand(child: ColoredBox(color: Colors.black));
          },
          onDetect: (capture) {
            for (final b in capture.barcodes) {
              final code = b.rawValue;
              if (code != null && code.isNotEmpty) {
                final matched = app.findItemByBarcode(code);
                if (matched != null &&
                    (matched.isLotItem || matched.isSerialItem) &&
                    onLotSerialDetected != null) {
                  onLotSerialDetected!(matched);
                } else {
                  app.addScanned(code);
                  HapticFeedback.mediumImpact();
                }
              }
            }
          },
        ),

        // Left/right scrims
        const _ScanScrim(),

        // Corner-marker frame
        const Center(child: _ScanFrame()),

        // Item count badge
        if (app.scannedItems.isNotEmpty)
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.white, size: 14),
                  const SizedBox(width: 5),
                  Text(
                    '${app.scannedItems.fold(0, (s, i) => s + i.qty)} items',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),

        // Search toggle icon — bottom right
        Positioned(
          bottom: 12,
          right: 12,
          child: GestureDetector(
            onTap: onToggleSearch,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: showSearch ? colorScheme.primary : Colors.black54,
                shape: BoxShape.circle,
              ),
              child: Icon(
                showSearch ? Icons.close : Icons.search,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Items panel ───────────────────────────────────────────────────────────────

class _ItemsPanel extends StatelessWidget {
  final AppState app;
  final ColorScheme colorScheme;
  final bool showSearch;
  final String query;
  final List<InventoryItemModel> filteredCatalog;
  final TextEditingController searchCtrl;
  final VoidCallback onSearchChanged;
  final void Function(InventoryItemModel item) onLotSerialTap;

  const _ItemsPanel({
    required this.app,
    required this.colorScheme,
    required this.showSearch,
    required this.query,
    required this.filteredCatalog,
    required this.searchCtrl,
    required this.onSearchChanged,
    required this.onLotSerialTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showSearch)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
            child: TextField(
              controller: searchCtrl,
              autofocus: true,
              onChanged: (_) => onSearchChanged(),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Name or UPC',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                isDense: true,
              ),
            ),
          ),
        if (showSearch && query.isNotEmpty)
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 180),
            child: filteredCatalog.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text('No matches',
                        style: TextStyle(color: colorScheme.onSurfaceVariant)),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: filteredCatalog.length,
                    itemBuilder: (_, i) {
                      final p = filteredCatalog[i];
                      final isLotSerial = p.isLotItem || p.isSerialItem;
                      return ListTile(
                        dense: true,
                        title: Text(p.name),
                        subtitle: Text(
                          isLotSerial
                              ? (p.isSerialItem ? 'Serialised' : 'Lot-numbered')
                              : (p.upc.isEmpty ? 'No barcode' : p.upc),
                          style: TextStyle(
                              color: isLotSerial
                                  ? colorScheme.primary
                                  : p.upc.isEmpty
                                      ? colorScheme.outline
                                      : colorScheme.onSurfaceVariant),
                        ),
                        trailing: Icon(
                          isLotSerial
                              ? Icons.list_alt_outlined
                              : Icons.add_circle_outline,
                          size: 20,
                          color: isLotSerial ? colorScheme.primary : null,
                        ),
                        onTap: () {
                          if (isLotSerial) {
                            onLotSerialTap(p);
                          } else {
                            app.addCatalogItem(p);
                            HapticFeedback.selectionClick();
                          }
                        },
                      );
                    },
                  ),
          ),
        if (showSearch) const Divider(height: 1),
        Expanded(
          child: app.scannedItems.isEmpty
              ? Center(
                  child: Text('Scan a barcode to start',
                      style: TextStyle(color: colorScheme.onSurfaceVariant)))
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: app.scannedItems.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, indent: 16, endIndent: 16),
                  itemBuilder: (_, i) {
                    final it = app.scannedItems[i];
                    final isUnmatched = it.itemId.startsWith('unknown:');
                    // Cross-check catalog for up-to-date lot/serial flags in case
                    // the ScannedItem was loaded from a stale DB row.
                    final catalogEntry = app.catalogItems
                        .where((c) => c.id == it.itemId)
                        .firstOrNull;
                    final isLotSerial = (catalogEntry?.isLotItem ?? it.isLotItem) ||
                        (catalogEntry?.isSerialItem ?? it.isSerialItem);
                    final needsDetail = isLotSerial && it.lotSerialAssignments.isEmpty;

                    String subtitle;
                    Color? subtitleColor;
                    if (isUnmatched) {
                      subtitle = 'Not matched — use Search to add';
                      subtitleColor = colorScheme.error.withValues(alpha: 0.7);
                    } else if (needsDetail) {
                      subtitle = 'Tap to enter ${it.isSerialItem ? 'serial' : 'lot'} numbers';
                      subtitleColor = colorScheme.error;
                    } else if (isLotSerial && it.lotSerialAssignments.isNotEmpty) {
                      subtitle = it.lotSerialAssignments
                          .map((a) => '${a.number} ×${a.qty}')
                          .join(', ');
                      subtitleColor = colorScheme.onSurfaceVariant;
                    } else {
                      subtitle = it.upc;
                      subtitleColor = null;
                    }

                    return ListTile(
                      dense: true,
                      onTap: isLotSerial && !isUnmatched
                          ? () {
                              if (catalogEntry != null) {
                                onLotSerialTap(catalogEntry);
                              }
                            }
                          : null,
                      leading: isUnmatched
                          ? Tooltip(
                              message:
                                  'Barcode not found in inventory — will be skipped on submit',
                              child: Icon(Icons.warning_amber_rounded,
                                  color: colorScheme.error, size: 20),
                            )
                          : needsDetail
                              ? Icon(Icons.warning_amber_rounded,
                                  color: colorScheme.error, size: 20)
                              : null,
                      title: Text(
                        it.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: isUnmatched || needsDetail
                              ? colorScheme.error
                              : null,
                        ),
                      ),
                      subtitle: Text(
                        subtitle,
                        style: TextStyle(fontSize: 12, color: subtitleColor),
                      ),
                      trailing: isLotSerial && !isUnmatched
                          ? IconButton(
                              icon: Icon(
                                Icons.edit_note,
                                size: 20,
                                color: needsDetail
                                    ? colorScheme.error
                                    : colorScheme.primary,
                              ),
                              onPressed: catalogEntry != null
                                  ? () => onLotSerialTap(catalogEntry)
                                  : null,
                              visualDensity: VisualDensity.compact,
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline,
                                      size: 20),
                                  onPressed: () => app.decreaseQty(it.itemId),
                                  visualDensity: VisualDensity.compact,
                                ),
                                SizedBox(
                                  width: 28,
                                  child: Text('${it.qty}',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16)),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline,
                                      size: 20),
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
    );
  }
}

// ── Scan overlay widgets ──────────────────────────────────────────────────────

class _ScanScrim extends StatelessWidget {
  const _ScanScrim();

  @override
  Widget build(BuildContext context) {
    // Use a fraction of the available space so it never overflows.
    return LayoutBuilder(builder: (context, constraints) {
      final frameW = (constraints.maxWidth * 0.55).clamp(160.0, 280.0);
      final side = (constraints.maxWidth - frameW) / 2;
      return Row(
        children: [
          SizedBox(width: side, child: Container(color: Colors.black45)),
          SizedBox(width: frameW),
          SizedBox(width: side, child: Container(color: Colors.black45)),
        ],
      );
    });
  }
}

class _ScanFrame extends StatelessWidget {
  const _ScanFrame();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return LayoutBuilder(builder: (context, constraints) {
      final w = (constraints.maxWidth * 0.55).clamp(160.0, 280.0);
      final h = (constraints.maxHeight * 0.55).clamp(80.0, 150.0);
      return SizedBox(
        width: w,
        height: h,
        child: CustomPaint(painter: _CornerPainter(color: color)),
      );
    });
  }
}

class _CornerPainter extends CustomPainter {
  final Color color;
  const _CornerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    const len = 28.0;

    // top-left
    canvas.drawLine(Offset.zero, const Offset(len, 0), paint);
    canvas.drawLine(Offset.zero, Offset(0, len), paint);
    // top-right
    canvas.drawLine(Offset(size.width, 0), Offset(size.width - len, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, len), paint);
    // bottom-left
    canvas.drawLine(Offset(0, size.height), Offset(len, size.height), paint);
    canvas.drawLine(Offset(0, size.height), Offset(0, size.height - len), paint);
    // bottom-right
    canvas.drawLine(Offset(size.width, size.height),
        Offset(size.width - len, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height),
        Offset(size.width, size.height - len), paint);
  }

  @override
  bool shouldRepaint(_CornerPainter old) => old.color != color;
}

// ── No-camera fallback ────────────────────────────────────────────────────────

class _NoCamera extends StatelessWidget {
  final int itemCount;
  final VoidCallback onSearch;
  final bool showSearch;

  const _NoCamera({
    required this.itemCount,
    required this.onSearch,
    required this.showSearch,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          width: double.infinity,
          color: colorScheme.surfaceContainerHighest,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.qr_code_scanner, size: 40, color: colorScheme.onSurfaceVariant),
              const SizedBox(height: 8),
              Text('Camera not available',
                  style: TextStyle(fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
              const SizedBox(height: 2),
              Text('Use search to add items',
                  style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
              if (itemCount > 0) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$itemCount items scanned',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onPrimaryContainer),
                  ),
                ),
              ],
            ],
          ),
        ),
        // Search icon — bottom right, matching camera view
        Positioned(
          bottom: 12,
          right: 12,
          child: GestureDetector(
            onTap: onSearch,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: showSearch ? colorScheme.primary : Colors.black26,
                shape: BoxShape.circle,
              ),
              child: Icon(
                showSearch ? Icons.close : Icons.search,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
