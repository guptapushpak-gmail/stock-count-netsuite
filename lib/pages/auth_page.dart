import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import 'location_list_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _account = TextEditingController(text: 'TSTDRV1743198');
  final _clientId = TextEditingController(text: '01660c019fe6f6a4fc3a21fdabb7b1195018f4d9587b201a17aad9663b94b9b3');
  final _clientSecret = TextEditingController(text: '76b91568d6379c70c4ca80040e3fc749279994792905f6ec6e8bd980da52d0a2');
  final _redirectUri = TextEditingController(text: 'stockcount://callback');
  final _roleId = TextEditingController(text: '3');
  final _loginHint = TextEditingController(text: 'pushpak.gupta@solcall.com.au');

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();

    if (app.authenticated && app.locations.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LocationListPage()),
        );
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text('NetSuite Authentication')),
      body: Column(
        children: [
          if (app.loading) const LinearProgressIndicator(minHeight: 2),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextField(controller: _account, decoration: const InputDecoration(labelText: 'NetSuite Account ID')),
                const SizedBox(height: 10),
                TextField(controller: _clientId, decoration: const InputDecoration(labelText: 'OAuth Client ID')),
                const SizedBox(height: 10),
                TextField(controller: _clientSecret, obscureText: true, decoration: const InputDecoration(labelText: 'OAuth Client Secret')),
                const SizedBox(height: 10),
                TextField(controller: _redirectUri, decoration: const InputDecoration(labelText: 'Redirect URI')),
                const SizedBox(height: 10),
                TextField(controller: _roleId, decoration: const InputDecoration(labelText: 'Role ID (e.g. 3 for Administrator)')),
                const SizedBox(height: 10),
                TextField(controller: _loginHint, decoration: const InputDecoration(labelText: 'Login email (locked)')),
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: app.loading
                      ? null
                      : () async {
                          await context.read<AppState>().loginWithNetSuite(
                                account: _account.text.trim(),
                                clientId: _clientId.text.trim(),
                                clientSecret: _clientSecret.text.trim(),
                                redirectUri: _redirectUri.text.trim(),
                                roleId: _roleId.text.trim(),
                                loginHint: _loginHint.text.trim(),
                              );
                        },
                  child: app.loading
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Login via NetSuite OAuth & Download Locations'),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: app.loading
                      ? null
                      : () async {
                          await context.read<AppState>().logoutAndClearToken();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Saved token cleared. Please login again.')),
                            );
                          }
                        },
                  icon: const Icon(Icons.logout),
                  label: const Text('Clear saved login token'),
                ),
                if (app.error != null) ...[
                  const SizedBox(height: 12),
                  Text(app.error!, style: const TextStyle(color: Colors.red)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

