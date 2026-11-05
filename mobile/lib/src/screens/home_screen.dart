import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../services/api_service.dart';
import '../themes/app_theme.dart';
import '../screens/disease_screen.dart';
import '../screens/irrigation_screen.dart';
import '../screens/research_screen.dart';
import '../screens/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  SensorData? _sensor;
  WeatherData? _weather;
  IrrigationResult? _irrigation;
  List<Map<String, dynamic>> _recentScans = [];
  bool _isLoading = true;
  bool _isConnected = false;
  String _selectedPlot = 'Green Valley Plot #1 — Tomato';

  final List<String> _farmPlots = [
    'Green Valley Plot #1 — Tomato',
    'Polyhouse A — Tomato',
    'Open Field North — Tomato',
  ];

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    try {
      final sensorFuture = ApiService.getLatestSensorReading();
      final weatherFuture = ApiService.getCurrentWeather();
      final historyFuture = ApiService.getLocalDiseaseHistory();

      final results = await Future.wait([sensorFuture, weatherFuture, historyFuture]);

      final sensor = results[0] as SensorData?;
      final weather = results[1] as WeatherData?;
      final history = results[2] as List<Map<String, dynamic>>;

      // Check backend health
      bool connected = false;
      try {
        final res = await http
            .get(Uri.parse('${ApiService.baseUrl}/health'))
            .timeout(const Duration(seconds: 2));
        connected = (res.statusCode == 200);
      } catch (_) {
        connected = (sensor != null || weather != null);
      }

      final irrigation = ApiService.calculateOfflineIrrigation(
        crop: 'tomato',
        stage: 'flowering',
        moisture: sensor?.soilMoisture ?? 45.0,
        area: 10.0,
      );

      if (mounted) {
        setState(() {
          _sensor = sensor;
          _weather = weather;
          _recentScans = history;
          _irrigation = irrigation;
          _isConnected = connected;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _generateAgronomicAdvisory({
    required double moisture,
    required double temp,
    required double humidity,
    required double rain,
  }) {
    if (rain > 2.0) {
      return 'Precipitation of ${rain.toStringAsFixed(1)} mm recorded. Soil saturation imminent. Postpone irrigation to avoid root hypoxia and wash-off.';
    }
    if (moisture < 35.0) {
      if (temp > 30.0) {
        return 'CRITICAL DEFICIT: Soil moisture (${moisture.toStringAsFixed(1)}%) is severely depleted during high heat (${temp.toStringAsFixed(1)}°C). Initiate irrigation immediately before midday to protect crop turgor.';
      }
      return 'MOISTURE DEFICIT: Soil moisture (${moisture.toStringAsFixed(1)}%) is below optimal range (50-70%). Run FAO-56 irrigation cycle to replenish root zone.';
    }
    if (humidity > 80.0 && temp >= 20.0 && temp <= 28.0) {
      return 'HIGH PATHOGEN RISK: High atmospheric humidity (${humidity.toStringAsFixed(0)}%) with warm temperature (${temp.toStringAsFixed(1)}°C) creates ideal sporulation conditions for fungal blights. Avoid wetting foliage.';
    }
    if (temp > 32.0) {
      return 'HEAT STRESS ADVISORY: Ambient temperature is ${temp.toStringAsFixed(1)}°C. High vapor-pressure deficit increases tomato blossom-end rot risk. Ensure consistent root-zone moisture and morning watering.';
    }
    if (moisture > 75.0) {
      return 'EXCESS MOISTURE: Soil moisture (${moisture.toStringAsFixed(1)}%) is above optimal field capacity. Suspend irrigation and verify field drainage to prevent root rot.';
    }
    return 'OPTIMAL MICROCLIMATE: Temperature (${temp.toStringAsFixed(1)}°C) and moisture (${moisture.toStringAsFixed(1)}%) are ideal for tomato growth. Maintain scheduled scouting.';
  }

  Map<String, dynamic> _getFieldHealthStatus() {
    if (_recentScans.isEmpty) {
      return {
        'status': 'HEALTHY',
        'color': const Color(0xFF2E7D32),
        'icon': Icons.check_circle_outline,
        'subtitle': 'No active alerts',
      };
    }
    final latest = _recentScans.first;
    final pred = (latest['prediction'] ?? '').toString();
    final common = (latest['common_name'] ?? pred).toString();

    if (pred == 'Tomato_Healthy') {
      return {
        'status': 'HEALTHY',
        'color': const Color(0xFF2E7D32),
        'icon': Icons.verified_outlined,
        'subtitle': 'Canopy clear',
      };
    } else if (pred == 'Tomato_leaf_late_blight' || pred == 'Tomato_leaf_yellow_curl_virus') {
      return {
        'status': 'CRITICAL ALERT',
        'color': const Color(0xFFC62828),
        'icon': Icons.warning_rounded,
        'subtitle': common,
      };
    } else {
      return {
        'status': 'ATTENTION',
        'color': const Color(0xFFE65100),
        'icon': Icons.warning_amber_rounded,
        'subtitle': common,
      };
    }
  }

  Widget _buildSoilMoistureGauge(double moisture) {
    Color gaugeColor;
    String zoneText;
    if (moisture < 35.0) {
      gaugeColor = const Color(0xFFC62828);
      zoneText = 'Deficit (<35%)';
    } else if (moisture <= 65.0) {
      gaugeColor = const Color(0xFF2E7D32);
      zoneText = 'Optimal (35-65%)';
    } else {
      gaugeColor = const Color(0xFF1976D2);
      zoneText = 'Saturated (>65%)';
    }

    final double progress = (moisture / 100.0).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${moisture.toStringAsFixed(1)}%',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: gaugeColor),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: gaugeColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                zoneText,
                style: TextStyle(color: gaugeColor, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(gaugeColor),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final healthInfo = _getFieldHealthStatus();
    final double moisture = _sensor?.soilMoisture ?? 45.0;
    final double temp = _weather?.temperature ?? _sensor?.temperature ?? 26.0;
    final double humidity = _weather?.humidity ?? _sensor?.humidity ?? 60.0;
    final double rain = _weather?.precipitationMm ?? 0.0;
    final double et0 = _weather?.dailyEt0Mm ?? 4.2;

    final agronomicAdvisory = _generateAgronomicAdvisory(
      moisture: moisture,
      temp: temp,
      humidity: humidity,
      rain: rain,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('SasyaDrishti'),
        actions: [
          // Connection Status Badge
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _isConnected ? const Color(0xFF2E7D32) : Colors.black26,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isConnected ? Colors.lightGreenAccent : Colors.white38,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _isConnected ? Colors.greenAccent : Colors.orangeAccent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _isConnected ? 'Cloud Live' : 'Offline Engine',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          ),
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh, size: 22),
            onPressed: _loadAllData,
            tooltip: 'Refresh Telemetry',
          ),
          IconButton(
            icon: const Icon(Icons.tune, size: 22),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadAllData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Plot Selector Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: AppTheme.forestGreen, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedPlot,
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down, color: AppTheme.forestGreen),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1B2E1D),
                          ),
                          items: _farmPlots.map((plot) {
                            return DropdownMenuItem<String>(
                              value: plot,
                              child: Text(plot),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedPlot = val);
                          },
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.sageSurface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '10 m² Plot',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.forestGreen),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Farm Overview 2x2 Stat Cards
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Monitored Crop',
                      value: 'Tomato',
                      subtitle: 'MobileNetV3 Active',
                      icon: Icons.grass,
                      iconColor: AppTheme.forestGreen,
                      iconBg: const Color(0xFFE8F5E9),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Field Health',
                      value: healthInfo['status'] as String,
                      subtitle: healthInfo['subtitle'] as String,
                      icon: healthInfo['icon'] as IconData,
                      iconColor: healthInfo['color'] as Color,
                      iconBg: (healthInfo['color'] as Color).withValues(alpha: 0.12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.opacity, color: Colors.blue, size: 18),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Soil Moisture',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black54),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            _buildSoilMoistureGauge(moisture),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.wb_sunny, color: Colors.orange, size: 18),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Live Climate',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black54),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${temp.toStringAsFixed(1)} °C',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B2E1D)),
                            ),
                            Text(
                              'RH: ${humidity.toStringAsFixed(0)}% • ET₀: ${et0.toStringAsFixed(1)}mm',
                              style: const TextStyle(fontSize: 11, color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Contextual Agronomic Advisory Card
              Card(
                color: const Color(0xFFF1F8E9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: Color(0xFFC8E6C9), width: 1.2),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppTheme.forestGreen,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.psychology, color: Colors.white, size: 18),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'AI AGRONOMIC ADVISORY',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                    color: AppTheme.forestGreen,
                                  ),
                                ),
                                Text(
                                  'Plot #1 Microclimate Recommendation',
                                  style: TextStyle(fontSize: 11, color: Colors.black54),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.forestGreen.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'ACTIVE',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.forestGreen),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        agronomicAdvisory,
                        style: const TextStyle(fontSize: 13, height: 1.35, color: Color(0xFF1B2E1D)),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.info_outline, size: 13, color: Colors.black45),
                          const SizedBox(width: 4),
                          Text(
                            'Derived from Open-Meteo & FAO-56 Penman-Monteith guidelines',
                            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Recent Disease Detections Feed
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Leaf Pathology Scans',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1B2E1D)),
                  ),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      visualDensity: VisualDensity.compact,
                    ),
                    icon: const Icon(Icons.biotech, size: 16, color: AppTheme.forestGreen),
                    label: const Text('Crop Doctor', style: TextStyle(fontSize: 12, color: AppTheme.forestGreen)),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DiseaseScreen()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              if (_recentScans.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.sageSurface,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.camera_alt_outlined, color: AppTheme.forestGreen, size: 24),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'No Leaf Scans Today',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1B2E1D)),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Tap Crop Doctor to diagnose tomato leaf pathology.',
                                style: TextStyle(fontSize: 11, color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            side: const BorderSide(color: AppTheme.forestGreen),
                          ),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const DiseaseScreen()),
                          ),
                          child: const Text('Scan Leaf', style: TextStyle(fontSize: 11, color: AppTheme.forestGreen)),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SizedBox(
                  height: 115,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _recentScans.length,
                    itemBuilder: (ctx, idx) {
                      final scan = _recentScans[idx];
                      final pred = (scan['prediction'] ?? 'Tomato_Healthy').toString();
                      final name = (scan['common_name'] ?? pred).toString();
                      final conf = (scan['confidence'] as num?)?.toDouble() ?? 0.0;
                      final confPct = conf > 1.0 ? conf : (conf * 100.0);
                      final bool isHealthy = pred == 'Tomato_Healthy';
                      final bool isCritical = pred.contains('late_blight') || pred.contains('yellow_curl');

                      final cardColor = isHealthy
                          ? const Color(0xFF2E7D32)
                          : isCritical
                              ? const Color(0xFFC62828)
                              : const Color(0xFFE65100);

                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DiseaseScreen(initialDiseaseId: pred),
                          ),
                        ),
                        child: Container(
                          width: 200,
                          margin: const EdgeInsets.only(right: 10, bottom: 4),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: cardColor.withValues(alpha: 0.3)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(
                                    isHealthy ? Icons.verified : Icons.warning_rounded,
                                    size: 18,
                                    color: cardColor,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: cardColor.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${confPct.toStringAsFixed(1)}%',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: cardColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1B2E1D),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    (scan['timestamp'] ?? '').toString().substring(0, 10),
                                    style: const TextStyle(fontSize: 10, color: Colors.black45),
                                  ),
                                  const Icon(Icons.arrow_forward_ios, size: 10, color: Colors.black38),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

              const SizedBox(height: 14),

              // Smart Irrigation Recommendation Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: Colors.blue.shade200, width: 1.1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.water_drop, color: Colors.blue, size: 18),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Smart Irrigation (FAO-56)',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0D47A1),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Watchdog: 180s',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildIrrigationStat(
                              label: 'Water Needed',
                              value: '${_irrigation?.waterRequiredMm.toStringAsFixed(1) ?? '3.5'} mm',
                              subtext: '${_irrigation?.totalWaterLiters.toStringAsFixed(0) ?? '35'} Liters',
                            ),
                          ),
                          Container(width: 1, height: 35, color: Colors.grey.shade200),
                          Expanded(
                            child: _buildIrrigationStat(
                              label: 'Pump Runtime',
                              value: '${_irrigation?.pumpDurationSeconds.toStringAsFixed(0) ?? '90'}s',
                              subtext: 'Auto safety cap',
                            ),
                          ),
                          Container(width: 1, height: 35, color: Colors.grey.shade200),
                          Expanded(
                            child: _buildIrrigationStat(
                              label: 'ETc Demand',
                              value: '${_irrigation?.etcMm.toStringAsFixed(1) ?? '4.8'} mm',
                              subtext: 'Kc: 1.15',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1565C0),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.water, size: 18),
                          label: const Text('Irrigation', style: TextStyle(fontWeight: FontWeight.bold)),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const IrrigationScreen()),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Quick Actions Grid (4 Cards)
              const Text(
                'Quick Control Actions',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1B2E1D)),
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: _buildActionTile(
                      icon: Icons.camera_alt_rounded,
                      iconBg: const Color(0xFFE8F5E9),
                      iconColor: AppTheme.forestGreen,
                      title: 'Crop Doctor',
                      subtitle: 'AI Pathology & Advisory',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const DiseaseScreen()),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildActionTile(
                      icon: Icons.water_drop_rounded,
                      iconBg: Colors.blue.shade50,
                      iconColor: const Color(0xFF1976D2),
                      title: 'Irrigation Pump',
                      subtitle: 'FAO-56 Water Control',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const IrrigationScreen()),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildActionTile(
                      icon: Icons.analytics_rounded,
                      iconBg: Colors.purple.shade50,
                      iconColor: Colors.deepPurple,
                      title: 'Research Data',
                      subtitle: '88.33% Acc • Kaggle Benchmark',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ResearchScreen()),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildActionTile(
                      icon: Icons.settings_remote_rounded,
                      iconBg: Colors.teal.shade50,
                      iconColor: Colors.teal,
                      title: 'IoT & Telemetry',
                      subtitle: 'ESP32 & API Config',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Real-time IoT Telemetry Stream Card
              Card(
                elevation: 1.5,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _sensor != null ? Icons.sensors : Icons.sensors_off,
                                color: _sensor != null ? AppTheme.forestGreen : Colors.grey,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Hardware Telemetry Stream',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1B2E1D)),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.sageSurface,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _sensor != null ? 'SRC: ${_sensor!.source.toUpperCase()}' : 'STANDBY',
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.forestGreen),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTelemetryMini(
                              label: 'Soil Moisture',
                              val: '${_sensor?.soilMoisture.toStringAsFixed(1) ?? '45.0'}%',
                              icon: Icons.opacity,
                              color: Colors.blue,
                            ),
                          ),
                          Expanded(
                            child: _buildTelemetryMini(
                              label: 'Ambient Temp',
                              val: '${_sensor?.temperature.toStringAsFixed(1) ?? '26.4'} °C',
                              icon: Icons.thermostat,
                              color: Colors.orange,
                            ),
                          ),
                          Expanded(
                            child: _buildTelemetryMini(
                              label: 'Relative Hum',
                              val: '${_sensor?.humidity.toStringAsFixed(0) ?? '62'}%',
                              icon: Icons.water,
                              color: Colors.teal,
                            ),
                          ),
                          Expanded(
                            child: _buildTelemetryMini(
                              label: 'Solar Lux',
                              val: _sensor?.lightIntensity.toStringAsFixed(0) ?? '850',
                              icon: Icons.light_mode,
                              color: Colors.amber.shade700,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _sensor != null && _sensor!.timestamp.isNotEmpty
                                ? 'Last packet: ${_sensor!.timestamp}'
                                : 'Hardware stream ready (ESP32 / Telemetry Simulator)',
                            style: const TextStyle(fontSize: 11, color: Colors.black54),
                          ),
                          Text(
                            _sensor != null ? 'Node #${_sensor!.id}' : 'Awaiting',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.forestGreen),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black54),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1B2E1D)),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIrrigationStat({
    required String label,
    required String value,
    required String subtext,
  }) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1))),
        const SizedBox(height: 2),
        Text(subtext, style: const TextStyle(fontSize: 10, color: Colors.black45)),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1B2E1D)),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTelemetryMini({
    required String label,
    required String val,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(height: 4),
        Text(
          val,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1B2E1D)),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 9, color: Colors.black54),
        ),
      ],
    );
  }
}
