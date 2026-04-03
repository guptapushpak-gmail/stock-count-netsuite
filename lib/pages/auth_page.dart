import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();

    return Scaffold(
      body: Stack(
        children: [
          if (app.loading)
            const Positioned(
              top: 0, left: 0, right: 0,
              child: LinearProgressIndicator(minHeight: 2),
            ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const _NetStoreProNextLogo(),
                  const SizedBox(height: 56),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: app.loading
                          ? null
                          : () => context.read<AppState>().loginWithNetSuite(),
                      child: app.loading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Padding(
                              padding: EdgeInsets.symmetric(vertical: 6),
                              child: Text(
                                'Login With Netsuite',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                    ),
                  ),
                  if (app.error != null) ...[
                    const SizedBox(height: 16),
                    Text(app.error!, style: const TextStyle(color: Colors.red)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NetStoreProNextLogo extends StatelessWidget {
  const _NetStoreProNextLogo();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icon mark
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [colorScheme.primary, colorScheme.tertiary],
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(Icons.inventory_2_rounded, color: Colors.white, size: 38),
        ),
        const SizedBox(height: 20),
        // Wordmark
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'NetStore',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
              TextSpan(
                text: ' Pro',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w300,
                  color: colorScheme.primary,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'N E X T',
          style: TextStyle(
            fontSize: 11,
            letterSpacing: 5,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
