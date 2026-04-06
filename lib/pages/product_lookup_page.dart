import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';

class ProductLookupPage extends StatefulWidget {
  const ProductLookupPage({super.key});

  @override
  State<ProductLookupPage> createState() => _ProductLookupPageState();
}

class _ProductLookupPageState extends State<ProductLookupPage> {
  final TextEditingController _ctrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  List<InventoryItemModel> _filter(List<InventoryItemModel> catalog) {
    if (_query.isEmpty) return const [];
    final q = _query.toLowerCase();
    return catalog.where((it) {
      return it.name.toLowerCase().contains(q) || it.upc.contains(q);
    }).take(50).toList();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final colorScheme = Theme.of(context).colorScheme;
    final results = _filter(app.catalogItems);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Product Lookup', style: TextStyle(fontWeight: FontWeight.w700)),
            if (app.selectedLocation != null)
              Text(app.selectedLocation!.name,
                  style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _ctrl,
              autofocus: true,
              onChanged: (v) => setState(() => _query = v.trim()),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search by name or UPC',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _ctrl.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
              ),
            ),
          ),
          if (_query.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.search, size: 56, color: colorScheme.outlineVariant),
                    const SizedBox(height: 12),
                    Text('Search ${app.catalogItems.length} items',
                        style: TextStyle(color: colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 4),
                    Text('by name or barcode',
                        style: TextStyle(fontSize: 13, color: colorScheme.outline)),
                  ],
                ),
              ),
            )
          else if (results.isEmpty)
            Expanded(
              child: Center(
                child: Text('No matches for "$_query"',
                    style: TextStyle(color: colorScheme.onSurfaceVariant)),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                itemCount: results.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final item = results[i];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (item.upc.isNotEmpty)
                          Text('UPC: ${item.upc}',
                              style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant))
                        else
                          Text('No barcode',
                              style: TextStyle(fontSize: 12, color: colorScheme.outline)),
                        Text('ID: ${item.id}',
                            style: TextStyle(fontSize: 11, color: colorScheme.outline)),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.copy_outlined, size: 18, color: colorScheme.outline),
                      tooltip: 'Copy UPC',
                      onPressed: item.upc.isEmpty
                          ? null
                          : () {
                              Clipboard.setData(ClipboardData(text: item.upc));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Copied: ${item.upc}'),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
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
