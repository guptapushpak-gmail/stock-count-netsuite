import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';

import '../state/app_state.dart';
import 'product_lookup_page.dart';
import 'stock_count_sessions_page.dart';

class MainMenuPage extends StatefulWidget {
  const MainMenuPage({super.key});

  @override
  State<MainMenuPage> createState() => _MainMenuPageState();
}

class _MainMenuPageState extends State<MainMenuPage> {
  int _tab = 0;

  void _changeLocation(BuildContext context) {
    context.read<AppState>().clearSelectedLocation();
    // clearSelectedLocation sets selectedLocation = null and calls notifyListeners,
    // so _AppRouter will rebuild and show LocationListPage automatically.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tab == 0 ? _HomeTab(onChangeLocation: () => _changeLocation(context)) : const _SettingsTab(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings_rounded), label: 'Settings'),
        ],
      ),
    );
  }
}

// ── Home tab ──────────────────────────────────────────────────────────────────

class _HomeTab extends StatelessWidget {
  final VoidCallback onChangeLocation;
  const _HomeTab({required this.onChangeLocation});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final colorScheme = Theme.of(context).colorScheme;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          automaticallyImplyLeading: false,
          pinned: true,
          title: _CompanyLogo(logo: app.companyLogo),
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
                      color: Colors.white.withValues(alpha: 0.2),
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
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13),
                          ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: onChangeLocation,
                    child: Text('Change', style: TextStyle(color: Colors.white.withValues(alpha: 0.9))),
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
                icon: Icons.search_rounded,
                label: 'Product Lookup',
                subtitle: 'Search by name or UPC',
                color: colorScheme.secondaryContainer,
                onColor: colorScheme.onSecondaryContainer,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProductLookupPage()),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Settings tab ──────────────────────────────────────────────────────────────

class _SettingsTab extends StatefulWidget {
  const _SettingsTab();

  @override
  State<_SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<_SettingsTab> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      if (mounted) setState(() => _version = '${info.version} (${info.buildNumber})');
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final colorScheme = Theme.of(context).colorScheme;

    // User initials for avatar
    final userName = app.currentUserName ?? '';
    final initials = userName.trim().isEmpty
        ? '?'
        : userName.trim().split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase();

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          automaticallyImplyLeading: false,
          pinned: true,
          expandedHeight: 160,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [colorScheme.primary, colorScheme.tertiary],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.white.withValues(alpha: 0.25),
                            child: Text(
                              initials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userName.isEmpty ? 'Signed In' : userName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 17,
                                  ),
                                ),
                                if (app.currentUserEmail?.isNotEmpty == true)
                                  Text(
                                    app.currentUserEmail!,
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.8),
                                      fontSize: 13,
                                    ),
                                  ),
                                if (app.currentRoleName?.isNotEmpty == true)
                                  Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      app.currentRoleName!,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
          sliver: SliverList(
            delegate: SliverChildListDelegate([

              // ── NetSuite section ────────────────────────────────────────────
              _SectionLabel(label: 'NetSuite'),
              const SizedBox(height: 8),
              _InfoCard(children: [
                _InfoRow(
                  icon: Icons.cloud_outlined,
                  label: 'Account',
                  value: app.accountId ?? '—',
                ),
                if (app.selectedLocation != null) ...[
                  const Divider(height: 1, indent: 44),
                  _InfoRow(
                    icon: Icons.location_on_outlined,
                    label: 'Location',
                    value: app.selectedLocation!.name,
                  ),
                ],
                if (app.selectedLocation?.subsidiaryName != null) ...[
                  const Divider(height: 1, indent: 44),
                  _InfoRow(
                    icon: Icons.account_tree_outlined,
                    label: 'Subsidiary',
                    value: app.selectedLocation!.subsidiaryName!,
                  ),
                ],
              ]),

              const SizedBox(height: 20),

              // ── Catalog section ─────────────────────────────────────────────
              _SectionLabel(label: 'Catalog'),
              const SizedBox(height: 8),
              _InfoCard(children: [
                _InfoRow(
                  icon: Icons.inventory_2_outlined,
                  label: 'Items synced',
                  value: '${app.catalogItems.length}',
                  valueColor: colorScheme.primary,
                ),
                const Divider(height: 1, indent: 44),
                _InfoRow(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Adjustment accounts',
                  value: '${app.adjustmentAccounts.length}',
                  valueColor: colorScheme.primary,
                ),
              ]),

              const SizedBox(height: 20),

              // ── App section ─────────────────────────────────────────────────
              _SectionLabel(label: 'App'),
              const SizedBox(height: 8),
              _InfoCard(children: [
                _InfoRow(
                  icon: Icons.info_outline_rounded,
                  label: 'Version',
                  value: _version.isEmpty ? '—' : _version,
                ),
              ]),

              const SizedBox(height: 32),

              // ── Sign out ────────────────────────────────────────────────────
              OutlinedButton.icon(
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Sign Out'),
                      content: const Text('Are you sure you want to sign out?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sign Out')),
                      ],
                    ),
                  );
                  if (confirmed == true && context.mounted) {
                    context.read<AppState>().logoutAndClearToken();
                  }
                },
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Sign Out'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.error,
                  side: BorderSide(color: colorScheme.error.withValues(alpha: 0.4)),
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: TextStyle(fontSize: 14, color: colorScheme.onSurface)),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor ?? colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

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
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(text: 'NetStore', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: colorScheme.onSurface)),
          TextSpan(text: ' Next', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300, color: colorScheme.primary)),
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
              Text(label, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: onColor)),
              const SizedBox(height: 2),
              Text(subtitle, style: TextStyle(fontSize: 11, color: onColor.withValues(alpha: 0.7)), maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}
