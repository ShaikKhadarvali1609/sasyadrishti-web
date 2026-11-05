import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../services/api_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _urlController;
  String _testStatus = '';
  bool _isTesting = false;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: ApiService.baseUrl);
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    setState(() {
      _isTesting = true;
      _testStatus = 'Testing connection...';
    });

    final targetUrl = _urlController.text.trim();
    try {
      final res = await http.get(Uri.parse('$targetUrl/health')).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        await ApiService.setApiBaseUrl(targetUrl);
        setState(() {
          _testStatus = 'Connected & Saved to device! ($targetUrl)';
        });
      } else {
        setState(() {
          _testStatus = 'Server error: ${res.statusCode}';
        });
      }
    } catch (e) {
      // Allow saving even if offline, with notice
      await ApiService.setApiBaseUrl(targetUrl);
      setState(() {
        _testStatus = 'Saved ($targetUrl), but server currently unreachable ($e)';
      });
    } finally {
      setState(() {
        _isTesting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('System Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Backend Configuration', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _urlController,
                      decoration: const InputDecoration(
                        labelText: 'FastAPI Backend Base URL',
                        hintText: 'https://your-space.hf.space or http://192.168.x.x:8000',
                        prefixIcon: Icon(Icons.link),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isTesting ? null : _testConnection,
                      icon: const Icon(Icons.save),
                      label: const Text('Save & Test Endpoint'),
                    ),
                    if (_testStatus.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        _testStatus,
                        style: TextStyle(
                          color: _testStatus.contains('Connected') ? Colors.green[800] : Colors.orange[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text('Network Guidelines', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            const Card(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      dense: true,
                      leading: Icon(Icons.cloud_done, color: Colors.blue),
                      title: Text('Cloud Hosted (Hugging Face / Cloud Run)'),
                      subtitle: Text('Enter HTTPS URL: https://<your-space>.hf.space (Works anywhere with internet)'),
                    ),
                    ListTile(
                      dense: true,
                      leading: Icon(Icons.wifi, color: Colors.green),
                      title: Text('Local Wi-Fi Network'),
                      subtitle: Text('Enter Laptop LAN IP: http://192.168.x.x:8000 (Phone and laptop on same Wi-Fi)'),
                    ),
                    ListTile(
                      dense: true,
                      leading: Icon(Icons.phone_android, color: Colors.purple),
                      title: Text('Android Emulator'),
                      subtitle: Text('Use http://10.0.2.2:8000 (Routes directly to laptop localhost)'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
