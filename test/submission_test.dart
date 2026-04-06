import 'package:flutter_test/flutter_test.dart';
import 'package:netstore_next/models/models.dart';

// ---------------------------------------------------------------------------
// Pure unit tests for the adjustment-line building logic.
// These mirror exactly what AppState.submitInventoryAdjustment does so we can
// validate edge cases without spinning up a real DB or hitting NetSuite.
// ---------------------------------------------------------------------------

/// Reproduces the line-building logic from AppState.submitInventoryAdjustment.
({List<Map<String, dynamic>> lines, List<String> skipped}) buildLines(
  List<ScannedItem> scannedItems,
  Map<String, double> onHand,
) {
  final countedByItem = <String, int>{};
  for (final s in scannedItems) {
    if (s.itemId.startsWith('unknown:')) continue;
    countedByItem[s.itemId] = (countedByItem[s.itemId] ?? 0) + s.qty;
  }

  final lines = <Map<String, dynamic>>[];
  final skipped = <String>[];

  countedByItem.forEach((id, countedQty) {
    final currentQty = onHand[id];
    if (currentQty == null) {
      final name = scannedItems
          .firstWhere((s) => s.itemId == id,
              orElse: () => ScannedItem(itemId: id, upc: '', name: id, qty: 0))
          .name;
      skipped.add(name);
    } else {
      final adjust = countedQty - currentQty.toInt();
      if (adjust != 0) lines.add({'itemId': id, 'adjustQtyBy': adjust});
    }
  });

  return (lines: lines, skipped: skipped);
}

void main() {
  group('Adjustment line builder', () {
    test('produces correct adjustQtyBy when counted > on-hand', () {
      final scanned = [
        ScannedItem(itemId: '100', upc: '', name: 'Widget A', qty: 5),
      ];
      final onHand = {'100': 3.0};

      final result = buildLines(scanned, onHand);

      expect(result.lines.length, 1);
      expect(result.lines[0]['itemId'], '100');
      expect(result.lines[0]['adjustQtyBy'], 2); // 5 - 3
      expect(result.skipped, isEmpty);
    });

    test('produces negative adjustQtyBy when counted < on-hand', () {
      final scanned = [
        ScannedItem(itemId: '101', upc: '', name: 'Widget B', qty: 2),
      ];
      final onHand = {'101': 10.0};

      final result = buildLines(scanned, onHand);

      expect(result.lines.length, 1);
      expect(result.lines[0]['adjustQtyBy'], -8); // 2 - 10
    });

    test('skips line when counted qty equals on-hand (no difference)', () {
      final scanned = [
        ScannedItem(itemId: '102', upc: '', name: 'Widget C', qty: 7),
      ];
      final onHand = {'102': 7.0};

      final result = buildLines(scanned, onHand);

      expect(result.lines, isEmpty);
      expect(result.skipped, isEmpty);
    });

    test('skips item with no on-hand balance record and adds to skipped list', () {
      final scanned = [
        ScannedItem(itemId: '103', upc: '', name: 'Lot Item', qty: 3),
      ];
      final onHand = <String, double>{}; // no balance record

      final result = buildLines(scanned, onHand);

      expect(result.lines, isEmpty);
      expect(result.skipped, contains('Lot Item'));
    });

    test('ignores unknown: prefixed items (unmatched barcodes)', () {
      final scanned = [
        ScannedItem(itemId: 'unknown:999999', upc: '999999', name: 'Unknown barcode: 999999', qty: 2),
        ScannedItem(itemId: '200', upc: '111', name: 'Real Item', qty: 3),
      ];
      final onHand = {'200': 1.0};

      final result = buildLines(scanned, onHand);

      expect(result.lines.length, 1);
      expect(result.lines[0]['itemId'], '200');
      expect(result.lines[0]['adjustQtyBy'], 2); // 3 - 1
    });

    test('aggregates qty when same item scanned multiple times', () {
      final scanned = [
        ScannedItem(itemId: '300', upc: '', name: 'Widget D', qty: 3),
        ScannedItem(itemId: '300', upc: '', name: 'Widget D', qty: 2),
      ];
      final onHand = {'300': 0.0};

      final result = buildLines(scanned, onHand);

      expect(result.lines.length, 1);
      expect(result.lines[0]['adjustQtyBy'], 5); // (3+2) - 0
    });

    test('handles multiple items: some adjustable, some skipped, some no diff', () {
      final scanned = [
        ScannedItem(itemId: '400', upc: '', name: 'Item A', qty: 5),  // diff
        ScannedItem(itemId: '401', upc: '', name: 'Item B', qty: 10), // no diff
        ScannedItem(itemId: '402', upc: '', name: 'Lot Item', qty: 2), // skipped
      ];
      final onHand = {'400': 3.0, '401': 10.0}; // 402 missing

      final result = buildLines(scanned, onHand);

      expect(result.lines.length, 1);
      expect(result.lines[0]['itemId'], '400');
      expect(result.lines[0]['adjustQtyBy'], 2);
      expect(result.skipped, contains('Lot Item'));
    });

    test('empty scanned list produces no lines and no skipped', () {
      final result = buildLines([], {});
      expect(result.lines, isEmpty);
      expect(result.skipped, isEmpty);
    });

    test('fractional on-hand is truncated to int for delta calculation', () {
      final scanned = [
        ScannedItem(itemId: '500', upc: '', name: 'Widget E', qty: 4),
      ];
      final onHand = {'500': 2.7}; // truncates to 2

      final result = buildLines(scanned, onHand);

      expect(result.lines[0]['adjustQtyBy'], 2); // 4 - 2
    });
  });
}
