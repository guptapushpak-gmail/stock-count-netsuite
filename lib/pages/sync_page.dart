import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';

// ── Step model ────────────────────────────────────────────────────────────────

enum _StepStatus { pending, active, done, error }

class _Step {
  final String label;
  final IconData icon;
  _StepStatus status = _StepStatus.pending;
  String detail = '';

  _Step({required this.label, required this.icon});
}

// ── Page ──────────────────────────────────────────────────────────────────────

class SyncPage extends StatefulWidget {
  final LocationModel location;

  const SyncPage({super.key, required this.location});

  @override
  State<SyncPage> createState() => _SyncPageState();
}

class _SyncPageState extends State<SyncPage> {
  late final List<_Step> _steps = [
    _Step(label: 'Inventory Items', icon: Icons.inventory_2_outlined),
    _Step(label: 'Adjustment Accounts', icon: Icons.account_balance_outlined),
    _Step(label: 'Saving to Device', icon: Icons.save_outlined),
  ];

  bool _done = false;
  String? _errorMessage;

  double get _progress {
    if (_steps.isEmpty) return 0;
    final finished = _steps.where((s) => s.status == _StepStatus.done).length;
    return finished / _steps.length;
  }

  @override
  void initState() {
    super.initState();
    // Defer until after the first frame so notifyListeners() inside
    // syncDataForLocation doesn't fire during the widget build phase.
    WidgetsBinding.instance.addPostFrameCallback((_) => _startSync());
  }

  Future<void> _startSync() async {
    setState(() {
      _done = false;
      _errorMessage = null;
      for (final s in _steps) {
        s.status = _StepStatus.pending;
        s.detail = '';
      }
    });

    try {
      await context.read<AppState>().syncDataForLocation(
        widget.location,
        onStep: (stepIndex, active, detail) {
          if (!mounted) return;
          setState(() {
            _steps[stepIndex].status = active ? _StepStatus.active : _StepStatus.done;
            _steps[stepIndex].detail = detail;
          });
        },
      );

      if (mounted) {
        setState(() => _done = true);
        // Brief pause to show the completed state before navigating.
        await Future.delayed(const Duration(milliseconds: 800));
        if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
      }
    } catch (e) {
      if (!mounted) return;
      // If the token expired, AppState already cleared auth — the router will
      // redirect to the login page automatically. Just pop this screen.
      if (AppState.isAuthError(e) ||
          e.toString().toLowerCase().contains('session expired')) {
        Navigator.of(context).popUntil((r) => r.isFirst);
        return;
      }
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        for (final s in _steps) {
          if (s.status == _StepStatus.active) s.status = _StepStatus.error;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Column(
        children: [
          _Header(
            location: widget.location,
            progress: _progress,
            done: _done,
            hasError: _errorMessage != null,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              children: [
                ..._steps.map((step) => _StepTile(step: step)),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 20),
                  _ErrorCard(message: _errorMessage!, onRetry: _startSync),
                ],
                if (_done) ...[
                  const SizedBox(height: 24),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_rounded,
                            color: colorScheme.primary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Sync complete — opening location…',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final LocationModel location;
  final double progress;
  final bool done;
  final bool hasError;

  const _Header({
    required this.location,
    required this.progress,
    required this.done,
    required this.hasError,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final topPad = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24, topPad + 20, 24, 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorScheme.primary, colorScheme.tertiary],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.sync_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    done ? 'Sync Complete' : hasError ? 'Sync Error' : 'Syncing Data',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    location.name,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: done ? 1.0 : progress,
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            done
                ? 'All data synced successfully'
                : hasError
                    ? 'Some steps failed'
                    : '${(progress * 100).round()}% complete',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Step tile ─────────────────────────────────────────────────────────────────

class _StepTile extends StatelessWidget {
  final _Step step;

  const _StepTile({required this.step});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Color iconColor;
    Widget leadingIcon;

    switch (step.status) {
      case _StepStatus.pending:
        iconColor = colorScheme.outlineVariant;
        leadingIcon = Icon(Icons.radio_button_unchecked_rounded,
            color: iconColor, size: 22);
      case _StepStatus.active:
        iconColor = colorScheme.primary;
        leadingIcon = SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: iconColor,
          ),
        );
      case _StepStatus.done:
        iconColor = colorScheme.primary;
        leadingIcon = Icon(Icons.check_circle_rounded, color: iconColor, size: 22);
      case _StepStatus.error:
        iconColor = colorScheme.error;
        leadingIcon = Icon(Icons.error_rounded, color: iconColor, size: 22);
    }

    final isPending = step.status == _StepStatus.pending;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 36, child: leadingIcon),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: isPending
                        ? colorScheme.onSurface.withValues(alpha: 0.4)
                        : colorScheme.onSurface,
                  ),
                ),
                if (step.detail.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    step.detail,
                    style: TextStyle(
                      fontSize: 13,
                      color: step.status == _StepStatus.error
                          ? colorScheme.error
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Right-side detail icon for done/error
          if (step.status == _StepStatus.done)
            Icon(step.icon, color: colorScheme.primary.withValues(alpha: 0.5), size: 18)
          else if (step.status == _StepStatus.active)
            Icon(step.icon, color: colorScheme.primary, size: 18)
          else
            Icon(step.icon, color: colorScheme.outlineVariant, size: 18),
        ],
      ),
    );
  }
}

// ── Error card ────────────────────────────────────────────────────────────────

class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded,
                  color: colorScheme.onErrorContainer, size: 18),
              const SizedBox(width: 8),
              Text(
                'Sync failed',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onErrorContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onErrorContainer.withValues(alpha: 0.85),
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.tonal(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ),
        ],
      ),
    );
  }
}
