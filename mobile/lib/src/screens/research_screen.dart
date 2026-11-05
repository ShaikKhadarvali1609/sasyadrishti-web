import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ResearchScreen extends StatefulWidget {
  const ResearchScreen({super.key});

  @override
  State<ResearchScreen> createState() => _ResearchScreenState();
}

class _ResearchScreenState extends State<ResearchScreen> {
  ResearchMetrics? _metrics;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMetrics();
  }

  Future<void> _loadMetrics() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getResearchMetrics();
      if (mounted) setState(() => _metrics = data);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Research & Evaluation Dashboard')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Failed to load metrics: $_error'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Model Architecture & Performance Benchmark',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),

                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _buildRow('Neural Architecture:', _metrics!.architecture),
                              _buildRow('Model Parameter Count:', '${_metrics!.parameterCount} params'),
                              _buildRow('Checkpoint Size:', '${_metrics!.modelSizeMb} MB'),
                              _buildRow('Validation Accuracy:', '${_metrics!.validationAccuracyPercent}%', color: Colors.green[800]),
                              _buildRow('Macro F1-Score:', '${_metrics!.f1ScoreMacro}', color: Colors.green[800]),
                              _buildRow('Mean CPU Latency:', '${_metrics!.meanInferenceLatencyMs} ms / sample'),
                              _buildRow('Class Count:', '${_metrics!.numClasses} categories'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      const Text(
                        'Target Diagnostic Classes (6-Class Subset)',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),

                      Card(
                        child: Column(
                          children: List.generate(_metrics!.classNames.length, (i) {
                            final name = _metrics!.classNames[i];
                            final cleanName = name.replaceAll('_', ' ');
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: name.contains('Healthy') ? Colors.green[100] : Colors.amber[100],
                                child: Icon(
                                  name.contains('Healthy') ? Icons.check_circle_outline : Icons.bug_report,
                                  color: name.contains('Healthy') ? Colors.green : Colors.brown,
                                ),
                              ),
                              title: Text(cleanName, style: const TextStyle(fontWeight: FontWeight.w500)),
                              subtitle: Text('Index: $i | PyTorch Checkpoint Weight'),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(height: 20),

                      const Text(
                        'Validation Matrix (600 Image Empirical Test)',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),

                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Table(
                            border: TableBorder.all(color: Colors.grey[300]!),
                            columnWidths: const {
                              0: FlexColumnWidth(3),
                              1: FlexColumnWidth(1),
                              2: FlexColumnWidth(1),
                              3: FlexColumnWidth(1),
                            },
                            children: [
                              const TableRow(
                                decoration: BoxDecoration(color: Color(0xFFF5F5F5)),
                                children: [
                                  Padding(padding: EdgeInsets.all(8), child: Text('Class', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                  Padding(padding: EdgeInsets.all(8), child: Text('TP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                  Padding(padding: EdgeInsets.all(8), child: Text('FP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                  Padding(padding: EdgeInsets.all(8), child: Text('FN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                ],
                              ),
                              ..._metrics!.confusionMatrix.entries.map((entry) {
                                final values = entry.value as Map<String, dynamic>;
                                return TableRow(
                                  children: [
                                    Padding(padding: const EdgeInsets.all(6), child: Text(entry.key.replaceAll('_', ' '), style: const TextStyle(fontSize: 11))),
                                    Padding(padding: const EdgeInsets.all(6), child: Text('${values["TP"]}', style: const TextStyle(fontSize: 11))),
                                    Padding(padding: const EdgeInsets.all(6), child: Text('${values["FP"]}', style: const TextStyle(fontSize: 11))),
                                    Padding(padding: const EdgeInsets.all(6), child: Text('${values["FN"]}', style: const TextStyle(fontSize: 11))),
                                  ],
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
