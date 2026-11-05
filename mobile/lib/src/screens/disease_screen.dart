import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/disease_advisory_data.dart';
import '../../services/api_service.dart';
import '../../services/disease_service.dart';

class DiseaseScreen extends StatefulWidget {
  final String? initialDiseaseId;
  const DiseaseScreen({super.key, this.initialDiseaseId});

  @override
  State<DiseaseScreen> createState() => _DiseaseScreenState();
}

class _DiseaseScreenState extends State<DiseaseScreen> {
  XFile? _image;
  Uint8List? _imageBytes;
  DiseaseResult? _result;
  DiseaseAdvisory? _advisory;
  String? _errorMessage;
  bool _isLoading = false;
  bool _isTelugu = false;
  WeatherData? _weather;
  List<Map<String, dynamic>> _savedHistory = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialDiseaseId != null) {
      _advisory = getOfflineAdvisory(widget.initialDiseaseId!);
      _result = DiseaseResult(
        prediction: widget.initialDiseaseId!,
        confidence: 0.95,
        status: 'OFFLINE_ADVISORY',
        probabilities: [0.95],
        classNames: [widget.initialDiseaseId!],
      );
    }
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    _loadLocalHistory();
    final w = await ApiService.getCurrentWeather();
    if (mounted) {
      setState(() => _weather = w);
    }
  }

  Future<void> _loadLocalHistory() async {
    final history = await ApiService.getLocalDiseaseHistory();
    if (mounted) {
      setState(() {
        _savedHistory = history;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: source,
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 88,
    );
    if (image == null) return;

    final bytes = await image.readAsBytes();

    setState(() {
      _image = image;
      _imageBytes = bytes;
      _isLoading = true;
      _errorMessage = null;
      _result = null;
      _advisory = null;
    });

    try {
      final result = await DiseaseService.predictDisease(image);
      final advisory = getOfflineAdvisory(result.prediction);

      setState(() {
        _result = result;
        _advisory = advisory;
      });

      // Save to local device storage for persistent offline access
      await ApiService.saveLocalDiseaseRecord({
        'crop': 'Tomato',
        'prediction': result.prediction,
        'common_name': advisory.commonName,
        'confidence': result.confidence,
        'status': result.status,
        'severity': advisory.severity,
        'timestamp': DateTime.now().toIso8601String().substring(0, 19).replaceAll('T', ' '),
      });
      await _loadLocalHistory();
    } catch (e) {
      setState(() {
        _errorMessage = 'Cloud AI Backend Unreachable: $e\n\n'
            'Note: You can configure a live HTTPS API endpoint in Settings, '
            'or tap "Explore Sample Pathology Reports" to inspect all verified advisory reports.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _selectSampleDisease(String diseaseId) {
    final advisory = getOfflineAdvisory(diseaseId);
    setState(() {
      _result = DiseaseResult(
        prediction: diseaseId,
        confidence: 0.965,
        status: 'VERIFIED_ADVISORY',
        probabilities: [0.965],
        classNames: [diseaseId],
      );
      _advisory = advisory;
      _image = null;
      _imageBytes = null;
      _errorMessage = null;
    });
    ApiService.saveLocalDiseaseRecord({
      'crop': 'Tomato',
      'prediction': diseaseId,
      'common_name': advisory.commonName,
      'confidence': 0.965,
      'status': 'VERIFIED_ADVISORY',
      'severity': advisory.severity,
      'timestamp': DateTime.now().toIso8601String().substring(0, 19).replaceAll('T', ' '),
    });
    _loadLocalHistory();
  }

  void _showSampleLeafDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.biotech, color: Color(0xFF1B5E20)),
            SizedBox(width: 8),
            Text('Sample Disease Profiles', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              _buildSampleTile('Tomato_Early_Blight', 'Early Blight', 'Alternaria solani', Icons.coronavirus, Colors.amber.shade800),
              _buildSampleTile('Tomato_leaf_late_blight', 'Late Blight', 'Phytophthora infestans', Icons.warning, Colors.red.shade700),
              _buildSampleTile('Tomato_mold_leaf', 'Leaf Mold', 'Passalora fulva', Icons.cloud, Colors.orange.shade700),
              _buildSampleTile('Tomato_septora_leaf_spot', 'Septoria Leaf Spot', 'Septoria lycopersici', Icons.grain, Colors.brown),
              _buildSampleTile('Tomato_leaf_yellow_curl_virus', 'Yellow Leaf Curl Virus', 'TYLCV / Begomovirus', Icons.bolt, Colors.purple),
              _buildSampleTile('Tomato_Healthy', 'Healthy Leaf', 'Solanum lycopersicum', Icons.eco, Colors.green),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildSampleTile(String id, String name, String sci, IconData icon, Color color) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withAlpha(30),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(sci, style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12)),
      onTap: () {
        Navigator.pop(context);
        _selectSampleDisease(id);
      },
    );
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Wrap(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  'Select Tomato Leaf Image',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle),
                  child: const Icon(Icons.camera_alt, color: Color(0xFF1B5E20)),
                ),
                title: const Text('Capture with Camera', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Take a sharp, close-up photo of the symptomatic leaf'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
                  child: const Icon(Icons.photo_library, color: Colors.blue),
                ),
                title: const Text('Upload from Gallery', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Select a saved leaf photo from your album'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.amber.shade50, shape: BoxShape.circle),
                  child: const Icon(Icons.psychology, color: Colors.amber),
                ),
                title: const Text('Explore Sample Pathology Reports', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Directly inspect verified AI Crop Doctor advisories for all 6 classes'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showSampleLeafDialog();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _copyAdvisorySummary() {
    if (_advisory == null || _result == null) return;
    final text = '''
SASYA DRISHTI — CROP DOCTOR ADVISORY REPORT
Crop: ${_advisory!.crop}
Diagnosis: ${_advisory!.commonName} (${_advisory!.scientificName})
Pathogen: ${_advisory!.pathogenType} | Severity: ${_advisory!.severity}
Confidence: ${(_result!.confidence * 100).toStringAsFixed(1)}%

IMMEDIATE PRECAUTIONS:
${_advisory!.immediateActions.map((a) => '• $a').join('\n')}

MANAGEMENT:
${_advisory!.culturalAndBiological.map((c) => '• $c').join('\n')}

FERTILIZER GUIDANCE:
${_advisory!.fertilizerRecommendation}

Sources: ${_advisory!.sources.join(', ')}
''';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Advisory report copied to clipboard!'),
        backgroundColor: Color(0xFF1B5E20),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Color _getSeverityColor(String level) {
    switch (level) {
      case 'CRITICAL':
        return const Color(0xFFC62828);
      case 'HIGH':
      case 'MODERATE_HIGH':
        return const Color(0xFFE65100);
      case 'MODERATE':
        return const Color(0xFFF57C00);
      case 'OPTIMAL':
        return const Color(0xFF2E7D32);
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Crop Doctor'),
        actions: [
          // Language Switcher: English / Telugu
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.white.withValues(alpha: 0.18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              icon: const Icon(Icons.translate, size: 16),
              label: Text(
                _isTelugu ? 'English' : 'తెలుగు',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              onPressed: () => setState(() => _isTelugu = !_isTelugu),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Scanning Call to Action Card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.biotech, color: Color(0xFF1B5E20), size: 28),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tomato Foliar Diagnosis',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'MobileNetV3 AI + ICAR/TNAU Clinical Advisory',
                                style: TextStyle(fontSize: 12, color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _showImagePickerOptions,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(46),
                        backgroundColor: const Color(0xFF1B5E20),
                      ),
                      icon: const Icon(Icons.add_a_photo, size: 20),
                      label: Text(
                        _image == null ? 'Scan Tomato Leaf' : 'Scan Another Leaf',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Image Preview Card
            if (_imageBytes != null) ...[
              const SizedBox(height: 12),
              Stack(
                alignment: Alignment.topRight,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.memory(
                      _imageBytes!,
                      height: 230,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Examined Leaf',
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],

            // Loading State
            if (_isLoading) ...[
              const SizedBox(height: 24),
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(strokeWidth: 3, color: Color(0xFF1B5E20)),
                    SizedBox(height: 12),
                    Text(
                      'Evaluating Leaf Pathology with MobileNetV3...',
                      style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1B5E20)),
                    ),
                  ],
                ),
              ),
            ],

            // Connectivity / Inference Error Card
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Card(
                color: const Color(0xFFFFEBEE),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.red.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.error_outline, color: Color(0xFFC62828)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Diagnosis Incomplete',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFC62828)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _errorMessage!,
                              style: const TextStyle(fontSize: 13, color: Color(0xFFB71C1C)),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Tip: Ensure the photo is clear, well-lit, and the backend endpoint is configured in Settings.',
                              style: TextStyle(fontSize: 11, color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Comprehensive Advisory Report
            if (_result != null && _advisory != null) ...[
              const SizedBox(height: 16),
              _buildDiagnosisBanner(),
              const SizedBox(height: 12),
              _buildReliabilityNotice(),
              const SizedBox(height: 12),
              _buildContextualRiskCard(),
              const SizedBox(height: 14),

              // Action Toolbar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Clinical Agronomic Report',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1B2E1D)),
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      side: const BorderSide(color: Color(0xFF1B5E20)),
                    ),
                    onPressed: _copyAdvisorySummary,
                    icon: const Icon(Icons.copy, size: 15, color: Color(0xFF1B5E20)),
                    label: const Text('Copy Report', style: TextStyle(fontSize: 12, color: Color(0xFF1B5E20))),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Accordion Sections
              _buildOverviewCard(),
              _buildSymptomsCard(),
              _buildImmediatePrecautionsCard(),
              _buildTreatmentCard(),
              _buildFertilizerCard(),
              _buildPreventionCard(),
              _buildAssistanceCard(),
              _buildSourcesCard(),
            ],

            // Saved Persistent Diagnoses List
            if (_savedHistory.isNotEmpty) ...[
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Persistent On-Device History',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B2E1D)),
                  ),
                  Text(
                    '${_savedHistory.length} Saved',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ..._savedHistory.take(5).map((rec) => _buildHistoryItem(rec)),
            ],

            // Empty State Hint
            if (_image == null && !_isLoading && _result == null && _savedHistory.isEmpty) ...[
              const SizedBox(height: 40),
              Center(
                child: Column(
                  children: [
                    Icon(Icons.local_florist_outlined, size: 56, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    Text(
                      'Capture or upload a tomato leaf to begin diagnostic consultation',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDiagnosisBanner() {
    final double confPct = _result!.confidence > 1.0 ? _result!.confidence : (_result!.confidence * 100.0);
    final sevColor = _getSeverityColor(_advisory!.severityLevel);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isTelugu ? _advisory!.commonNameTe : _advisory!.commonName,
                        style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Color(0xFF1B2E1D)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _advisory!.scientificName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: sevColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: sevColor.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    _advisory!.severity,
                    style: TextStyle(color: sevColor, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.verified, size: 18, color: Color(0xFF1B5E20)),
                    const SizedBox(width: 6),
                    Text(
                      'Confidence: ${confPct.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: confPct >= 65 ? const Color(0xFF1B5E20) : const Color(0xFFE65100),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Pathogen: ${_advisory!.pathogenType}',
                    style: const TextStyle(fontSize: 11, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReliabilityNotice() {
    final double conf = _result!.confidence > 1.0 ? _result!.confidence / 100.0 : _result!.confidence;
    final bool isUncertain = conf < 0.60 || _result!.status == 'UNCERTAIN';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUncertain ? const Color(0xFFFFF8E1) : const Color(0xFFF1F8E9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUncertain ? const Color(0xFFFFB300) : const Color(0xFFAED581),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isUncertain ? Icons.warning_amber_rounded : Icons.info_outline,
            color: isUncertain ? const Color(0xFFE65100) : const Color(0xFF2E7D32),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isUncertain
                  ? 'Diagnosis Caution: Low statistical confidence (${(conf * 100).toStringAsFixed(1)}%). Visual symptoms may be in early stages or masked by lighting. Please examine multiple leaves, inspect leaf undersides, or take a brighter close-up.'
                  : 'Diagnostic Note: AI visual classification is a clinical decision aid. Always cross-verify visible symptoms and inspect whole-plant canopy before chemical application.',
              style: TextStyle(
                fontSize: 12,
                color: isUncertain ? const Color(0xFF795548) : const Color(0xFF33691E),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContextualRiskCard() {
    final riskMsg = evaluateContextualRisk(
      diseaseId: _advisory!.diseaseId,
      humidity: _weather?.humidity,
      temp: _weather?.temperature,
      precipitationMm: _weather?.precipitationMm,
    );

    final bool isHighAlert = riskMsg.contains('CRITICAL') || riskMsg.contains('HIGH');

    return Card(
      color: isHighAlert ? const Color(0xFFFFF3E0) : const Color(0xFFFAFAFA),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isHighAlert ? const Color(0xFFFFB74D) : Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isHighAlert ? Icons.thunderstorm_outlined : Icons.wb_sunny_outlined,
              color: isHighAlert ? const Color(0xFFE65100) : Colors.blueGrey,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Weather & Microclimate Risk Analysis',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isHighAlert ? const Color(0xFFE65100) : Colors.blueGrey.shade800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    riskMsg,
                    style: const TextStyle(fontSize: 12, color: Colors.black87, height: 1.35),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard() {
    return Card(
      child: ExpansionTile(
        initiallyExpanded: true,
        leading: const Icon(Icons.menu_book, color: Color(0xFF1B5E20)),
        title: const Text('1. Disease Overview & Pathology', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isTelugu ? _advisory!.explanationTe : _advisory!.explanation,
                  style: const TextStyle(fontSize: 13, height: 1.45),
                ),
                const SizedBox(height: 12),
                const Text('Pathogen Spread Mechanism:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 4),
                Text(_advisory!.spreadMechanism, style: const TextStyle(fontSize: 12.5, color: Colors.black87)),
                const SizedBox(height: 10),
                const Text('Favorable Risk Conditions:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                ..._advisory!.favorableConditions.map((c) => Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(color: Color(0xFF1B5E20), fontWeight: FontWeight.bold)),
                      Expanded(child: Text(c, style: const TextStyle(fontSize: 12.5))),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomsCard() {
    final list = _isTelugu ? _advisory!.symptomsTe : _advisory!.symptoms;
    return Card(
      child: ExpansionTile(
        initiallyExpanded: true,
        leading: const Icon(Icons.search, color: Color(0xFF1B5E20)),
        title: const Text('2. Visual Symptoms & Identification', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: list.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle_outline, color: Color(0xFF2E7D32), size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(s, style: const TextStyle(fontSize: 13, height: 1.35))),
                  ],
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImmediatePrecautionsCard() {
    final list = _isTelugu ? _advisory!.immediateActionsTe : _advisory!.immediateActions;
    return Card(
      color: const Color(0xFFFFFDE7),
      child: ExpansionTile(
        initiallyExpanded: true,
        leading: const Icon(Icons.bolt, color: Color(0xFFF57F17)),
        title: const Text('3. Immediate Precautions (Do Today)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFFF57F17))),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: list.map((a) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.warning, color: Color(0xFFF57F17), size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(a, style: const TextStyle(fontSize: 13, height: 1.35, fontWeight: FontWeight.w500))),
                  ],
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTreatmentCard() {
    return Card(
      child: ExpansionTile(
        initiallyExpanded: false,
        leading: const Icon(Icons.health_and_safety, color: Color(0xFF1B5E20)),
        title: const Text('4. Management & Treatment Options', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Cultural & Biological Controls (IPM First):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1B5E20))),
                const SizedBox(height: 6),
                ..._advisory!.culturalAndBiological.map((b) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('✓ ', style: TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold)),
                      Expanded(child: Text(b, style: const TextStyle(fontSize: 12.5))),
                    ],
                  ),
                )),

                if (_advisory!.chemicalOptions.isNotEmpty) ...[
                  const Divider(height: 24),
                  const Text('CIBRC-Approved Chemical Formulations:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFB71C1C))),
                  const SizedBox(height: 8),
                  ..._advisory!.chemicalOptions.map((c) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(c.activeIngredient, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: Colors.blueGrey.shade50, borderRadius: BorderRadius.circular(6)),
                              child: Text(c.category, style: const TextStyle(fontSize: 10, color: Colors.blueGrey)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('Dosage: ${c.dosage}', style: const TextStyle(fontSize: 12, color: Color(0xFF1B5E20), fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text('Instructions: ${c.usage}', style: const TextStyle(fontSize: 11.5, color: Colors.black87)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text('Pre-Harvest Interval (PHI): ${c.phiDays} days', style: const TextStyle(fontSize: 11, color: Colors.black54)),
                            const SizedBox(width: 12),
                            Text('Re-entry: ${c.reiHours} hrs', style: const TextStyle(fontSize: 11, color: Colors.black54)),
                          ],
                        ),
                      ],
                    ),
                  )),
                ],

                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      const Icon(Icons.shield, color: Colors.orange, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _advisory!.safetyEquipment,
                          style: const TextStyle(fontSize: 11.5, color: Color(0xFF795548)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFertilizerCard() {
    final text = _isTelugu ? _advisory!.fertilizerRecommendationTe : _advisory!.fertilizerRecommendation;
    return Card(
      child: ExpansionTile(
        initiallyExpanded: false,
        leading: const Icon(Icons.eco, color: Color(0xFF1B5E20)),
        title: const Text('5. Fertilizer & Nutrient Guidance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Relevance: ${_advisory!.fertilizerRelevance}',
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF1B5E20)),
                ),
                const SizedBox(height: 6),
                Text(text, style: const TextStyle(fontSize: 13, height: 1.4)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                  child: const Row(
                    children: [
                      Icon(Icons.science, color: Colors.blue, size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Notice: Fertilizer provides crop nutrition and reinforces systemic vigor. It does not replace curative disease treatments.',
                          style: TextStyle(fontSize: 11.5, color: Color(0xFF0D47A1)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreventionCard() {
    final list = _isTelugu ? _advisory!.preventionTe : _advisory!.prevention;
    return Card(
      child: ExpansionTile(
        initiallyExpanded: false,
        leading: const Icon(Icons.shield_outlined, color: Color(0xFF1B5E20)),
        title: const Text('6. Preventive Field Hygiene & Crop Rotation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: list.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(color: Color(0xFF1B5E20), fontWeight: FontWeight.bold)),
                    Expanded(child: Text(p, style: const TextStyle(fontSize: 12.5, height: 1.35))),
                  ],
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssistanceCard() {
    return Card(
      child: ExpansionTile(
        initiallyExpanded: false,
        leading: const Icon(Icons.contact_phone, color: Color(0xFF1B5E20)),
        title: const Text('7. When to Seek Professional Assistance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_advisory!.whenToSeekAssistance, style: const TextStyle(fontSize: 13, height: 1.4)),
                const SizedBox(height: 8),
                const Text(
                  'Recommended Contacts: Local Krishi Vigyan Kendra (KVK), State Department of Agriculture / Horticulture Extension Officer, or Kisan Call Center (KCC toll-free 1800-180-1551).',
                  style: TextStyle(fontSize: 11.5, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourcesCard() {
    return Card(
      child: ExpansionTile(
        initiallyExpanded: false,
        leading: const Icon(Icons.library_books, color: Color(0xFF1B5E20)),
        title: const Text('8. Authoritative Agronomic References', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _advisory!.sources.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('• $s', style: const TextStyle(fontSize: 11.5, color: Colors.black54)),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> rec) {
    final double conf = (rec['confidence'] as num?)?.toDouble() ?? 0.0;
    final double confPct = conf > 1.0 ? conf : conf * 100.0;
    final String pred = rec['prediction'] as String? ?? 'Unknown';
    final String common = rec['common_name'] as String? ?? pred.replaceAll('_', ' ');

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        dense: true,
        leading: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: pred == 'Tomato_Healthy' ? Colors.green.shade50 : Colors.orange.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(
            pred == 'Tomato_Healthy' ? Icons.check_circle : Icons.warning_amber,
            color: pred == 'Tomato_Healthy' ? Colors.green : Colors.orange.shade800,
            size: 20,
          ),
        ),
        title: Text(
          common,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        subtitle: Text(
          '${rec['timestamp']} • Confidence: ${confPct.toStringAsFixed(1)}%',
          style: const TextStyle(fontSize: 11.5),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
        onTap: () {
          final adv = getOfflineAdvisory(pred);
          setState(() {
            _advisory = adv;
            _result = DiseaseResult(
              status: rec['status'] as String? ?? 'SUCCESS',
              prediction: pred,
              confidence: conf,
              probabilities: [],
              classNames: [],
            );
          });
        },
      ),
    );
  }
}
