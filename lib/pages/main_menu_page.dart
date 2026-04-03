import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';

import '../state/app_state.dart';
import 'stock_count_sessions_page.dart';

class MainMenuPage extends StatelessWidget {
  const MainMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            pinned: true,
            title: _CompanyLogo(logo: app.companyLogo),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout_rounded),
                tooltip: 'Sign out',
                onPressed: () => context.read<AppState>().logoutAndClearToken(),
              ),
              const SizedBox(width: 8),
            ],
          ),

          // Location card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [colorScheme.primary, colorScheme.tertiary],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.location_on_rounded, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            app.selectedLocation?.name ?? 'No location',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                          ),
                          if (app.selectedLocation?.subsidiaryName != null)
                            Text(
                              app.selectedLocation!.subsidiaryName!,
                              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
                            ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.read<AppState>().clearSelectedLocation(),
                      child: Text('Change', style: TextStyle(color: Colors.white.withOpacity(0.9))),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Menu grid
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.15,
              children: [
                _MenuCard(
                  icon: Icons.inventory_2_rounded,
                  label: 'Stock Count',
                  subtitle: 'Scan & count items',
                  color: colorScheme.primaryContainer,
                  onColor: colorScheme.onPrimaryContainer,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const StockCountSessionsPage()),
                  ),
                ),
                _MenuCard(
                  icon: Icons.history_rounded,
                  label: 'History',
                  subtitle: 'Past count sessions',
                  color: colorScheme.secondaryContainer,
                  onColor: colorScheme.onSecondaryContainer,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const StockCountSessionsPage()),
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

class _CompanyLogo extends StatelessWidget {
  final Uint8List? logo;
  const _CompanyLogo({required this.logo});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (logo != null) {
      return ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 36, maxWidth: 160),
        child: Image.memory(logo!, fit: BoxFit.contain),
      );
    }
    // Fallback wordmark
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(text: 'NetStore', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: colorScheme.onSurface)),
          TextSpan(text: ' Pro', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300, color: colorScheme.primary)),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final Color onColor;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 28, color: onColor),
              const Spacer(),
              Text(label, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: onColor)),
              const SizedBox(height: 2),
              Text(subtitle, style: TextStyle(fontSize: 12, color: onColor.withOpacity(0.7))),
            ],
          ),
        ),
      ),
    );
  }
}
