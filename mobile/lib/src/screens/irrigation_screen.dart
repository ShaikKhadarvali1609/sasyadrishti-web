import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class IrrigationScreen extends StatefulWidget {
  const IrrigationScreen({super.key});

  @override
  State<IrrigationScreen> createState() => _IrrigationScreenState();
}

class _IrrigationScreenState extends State<IrrigationScreen> {
  String _selectedStage = 'flowering';
  final TextEditingController _areaController = TextEditingController(text: '10.0');
  final TextEditingController _moistureController = TextEditingController(text: '45.0');
  
  IrrigationResult? _result;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isPumpRunning = false;
  String? _pumpMessage;

  @override
  void initState() {
    super.initState();
    _fetchLatestMoisture();
  }

  Future<void> _fetchLatestMoisture() async {
    final sensor = await ApiService.getLatestSensorReading();
    if (sensor != null && mounted) {
      setState(() {
        _moistureController.text = sensor.soilMoisture.toStringAsFixed(1);
      });
    }
  }

  Future<void> _calculateIrrigation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final area = double.tryParse(_areaController.text) ?? 10.0;
    final moisture = double.tryParse(_moistureController.text) ?? 45.0;

    try {
      final res = await ApiService.calculateIrrigation(
        crop: 'tomato',
        stage: _selectedStage,
        moisture: moisture,
        area: area,
      );
      setState(() {
        _result = res;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _triggerPump(bool start) async {
    try {
      final duration = _result != null ? _result!.pumpDurationSeconds : 30.0;
      final res = await ApiService.controlPump(start ? 'START' : 'STOP', duration: duration);
      setState(() {
        _isPumpRunning = start;
        _pumpMessage = res['message'] as String?;
      });
    } catch (e) {
      setState(() {
        _pumpMessage = 'Control error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Irrigation Decision Engine')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'FAO-56 Penman-Monteith Water Balance',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: _selectedStage,
                      decoration: const InputDecoration(labelText: 'Tomato Growth Stage'),
                      items: const [
                        DropdownMenuItem(value: 'initial', child: Text('Initial Stage (Kc = 0.60)')),
                        DropdownMenuItem(value: 'flowering', child: Text('Flowering / Fruit Set (Kc = 1.15)')),
                        DropdownMenuItem(value: 'late-season', child: Text('Maturity / Harvest (Kc = 0.80)')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedStage = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _moistureController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Soil Moisture (%)',
                              suffixText: '%',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.sync),
                          onPressed: _fetchLatestMoisture,
                          tooltip: 'Sync with latest sensor',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _areaController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Cultivated Field Area (m²)',
                        suffixText: 'm²',
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _calculateIrrigation,
                      icon: const Icon(Icons.calculate),
                      label: const Text('Calculate Water Requirement'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            if (_isLoading)
              const Center(child: CircularProgressIndicator()),

            if (_errorMessage != null)
              Card(
                color: Colors.red[50],
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(_errorMessage!, style: TextStyle(color: Colors.red[800])),
                ),
              ),

            if (_result != null) ...[
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Agronomic Decision', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Chip(
                            label: Text(_result!.calculationMethod, style: const TextStyle(fontSize: 10)),
                            backgroundColor: Colors.blue[50],
                          ),
                        ],
                      ),
                      const Divider(),
                      _buildMetricRow('Reference ET₀ (mm/day):', '${_result!.et0Mm} mm'),
                      _buildMetricRow('Crop Coefficient (Kc):', '${_result!.kcValue}'),
                      _buildMetricRow('Crop ETc (mm/day):', '${_result!.etcMm} mm'),
                      _buildMetricRow('Net Water Needed:', '${_result!.waterRequiredMm} mm (${_result!.waterRequiredLitersM2} L/m²)'),
                      const Divider(),
                      _buildMetricRow(
                        'Total Volume for ${_result!.fieldAreaM2} m²:',
                        '${_result!.totalWaterLiters} Liters',
                        isBold: true,
                      ),
                      _buildMetricRow(
                        'Recommended Pump Run:',
                        '${_result!.pumpDurationSeconds} seconds',
                        isBold: true,
                        valueColor: Colors.green[800],
                      ),
                      if (_result!.safetyCapped)
                        const Padding(
                          padding: EdgeInsets.only(top: 6),
                          child: Text(
                            '⚠ Duration was capped at maximum hardware watchdog limit (180s) to prevent over-irrigation.',
                            style: TextStyle(color: Colors.orange, fontSize: 12),
                          ),
                        ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isPumpRunning ? null : () => _triggerPump(true),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                              icon: const Icon(Icons.power_settings_new),
                              label: const Text('Start Pump (Safe Cycle)'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: !_isPumpRunning ? null : () => _triggerPump(false),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            icon: const Icon(Icons.stop),
                            label: const Text('Emergency Stop'),
                          ),
                        ],
                      ),
                      if (_pumpMessage != null) ...[
                        const SizedBox(height: 8),
                        Text(_pumpMessage!, style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, {bool isBold = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: valueColor ?? (isBold ? Colors.black : Colors.black87),
              fontSize: isBold ? 15 : 14,
            ),
          ),
        ],
      ),
    );
  }
}
