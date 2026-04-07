import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';

/// Submits the current stock count using the account/memo already stored on
/// [AppState.pendingAdjustmentAccountId] / [AppState.pendingMemo].
///
/// Shows a confirmation dialog, performs the API call, and returns true on
/// success.  On auth error, pops to root.
Future<bool> showSubmitFlow(BuildContext context) async {
  final app = context.read<AppState>();
  final accountId = app.pendingAdjustmentAccountId.trim();
  final memo = app.pendingMemo.trim();

  if (accountId.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No adjustment account set. Please start a new count.')),
    );
    return false;
  }

  final really = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Confirm Submission'),
      content: Text(
        'Submit inventory adjustment?\n\nItems: ${app.scannedItems.length}\nAccount: $accountId',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Submit'),
        ),
      ],
    ),
  );

  if (really != true || !context.mounted) return false;

  try {
    final id = await context.read<AppState>().submitInventoryAdjustment(
          adjustmentAccountId: accountId,
          subsidiaryId: app.selectedLocation?.subsidiaryId,
          memo: memo,
        );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Adjustment created: $id'),
          backgroundColor: Colors.green.shade700,
        ),
      );
    }
    return true;
  } catch (e) {
    if (!context.mounted) return false;
    if (AppState.isAuthError(e) || e.toString().toLowerCase().contains('session expired')) {
      Navigator.of(context).popUntil((r) => r.isFirst);
      return false;
    }
    final msg = e.toString().replaceFirst('Exception: ', '');
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Submission Failed'),
        content: SingleChildScrollView(child: Text(msg)),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    return false;
  }
}
