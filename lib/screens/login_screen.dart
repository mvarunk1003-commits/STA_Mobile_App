import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController(text: 'admin');
  final _passwordController = TextEditingController(text: 'admin123');
  bool _obscurePassword = true;

  void _prefill(String u, String p) {
    setState(() {
      _usernameController.text = u;
      _passwordController.text = p;
    });
  }

  void _showServerSettings(BuildContext context, AppProvider provider) {
    final serverController = TextEditingController(text: provider.api.baseUrl);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Server Connection'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Configure the Node.js API server endpoint:',
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: serverController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Server Base URL',
                hintText: 'http://10.0.2.2:5055',
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                ActionChip(
                  label: const Text('Port 5055 (LAN)'),
                  onPressed: () => serverController.text = 'http://192.168.0.56:5055',
                ),
                ActionChip(
                  label: const Text('Emulator (10.0.2.2)'),
                  onPressed: () => serverController.text = 'http://10.0.2.2:5055',
                ),
                ActionChip(
                  label: const Text('Localhost'),
                  onPressed: () => serverController.text = 'http://localhost:5055',
                ),
              ],
            )
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final newUrl = serverController.text.trim();
              await provider.api.setBaseUrl(newUrl);
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Server URL set to: $newUrl')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade900, Colors.deepPurple.shade800, const Color(0xFF0D1B2A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Card(
                elevation: 12,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                color: Colors.white.withAlpha(245),
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header Logo & Title
                      Container(
                        width: 88,
                        height: 88,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.amber.withAlpha(80), blurRadius: 12, spreadRadius: 2),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Icon(Icons.account_balance, size: 48, color: Colors.amber.shade800),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'STPA',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: 2),
                      ),
                      const Text(
                        'Organization Management Portal',
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                      const SizedBox(height: 20),

                      // Error Banner
                      if (provider.errorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: Colors.red, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  provider.errorMessage!,
                                  style: TextStyle(color: Colors.red.shade800, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Username field
                      TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username or Email',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Password field
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Login button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.indigo.shade800,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: provider.isLoading
                              ? null
                              : () => provider.login(
                                    _usernameController.text.trim(),
                                    _passwordController.text.trim(),
                                  ),
                          child: provider.isLoading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                )
                              : const Text('SECURE LOGIN', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),

                      const SizedBox(height: 20),
                      const Text('Quick Test Roles:', style: TextStyle(fontSize: 12, color: Colors.black54)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        alignment: WrapAlignment.center,
                        children: [
                          ActionChip(
                            label: const Text('Admin', style: TextStyle(fontSize: 11)),
                            avatar: const Icon(Icons.shield, size: 14),
                            onPressed: () => _prefill('admin', 'admin123'),
                          ),
                          ActionChip(
                            label: const Text('State', style: TextStyle(fontSize: 11)),
                            avatar: const Icon(Icons.flag, size: 14),
                            onPressed: () => _prefill('karnataka', 'karnataka123'),
                          ),
                          ActionChip(
                            label: const Text('District', style: TextStyle(fontSize: 11)),
                            avatar: const Icon(Icons.location_city, size: 14),
                            onPressed: () => _prefill('bengaluru', 'bengaluru123'),
                          ),
                          ActionChip(
                            label: const Text('Taluk', style: TextStyle(fontSize: 11)),
                            avatar: const Icon(Icons.place, size: 14),
                            onPressed: () => _prefill('bengalurusouth', 'bengalurusouth123'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      TextButton.icon(
                        icon: const Icon(Icons.settings_ethernet, size: 16),
                        label: Text('Server: ${provider.api.baseUrl}', style: const TextStyle(fontSize: 11)),
                        onPressed: () => _showServerSettings(context, provider),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
