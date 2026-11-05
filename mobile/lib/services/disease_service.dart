import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import 'api_service.dart';

class DiseaseResult {
  final String status;
  final String prediction;
  final double confidence;
  final List<double> probabilities;
  final List<String> classNames;
  final String? message;

  DiseaseResult({
    required this.status,
    required this.prediction,
    required this.confidence,
    required this.probabilities,
    required this.classNames,
    this.message,
  });

  factory DiseaseResult.fromJson(Map<String, dynamic> json) {
    return DiseaseResult(
      status: json['status'] as String? ?? 'UNKNOWN',
      prediction: json['prediction'] as String? ?? 'Unknown',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      probabilities: json['probabilities'] != null
          ? (json['probabilities'] as List).map((e) => (e as num).toDouble()).toList()
          : [],
      classNames: json['class_names'] != null
          ? (json['class_names'] as List).map((e) => e as String).toList()
          : [],
      message: json['message'] as String?,
    );
  }
}

class DiseaseService {
  static Future<DiseaseResult> predictDisease(XFile image) async {
    final Uint8List bytes = await image.readAsBytes();
    final String base64Image = base64Encode(bytes);

    final Uri url = Uri.parse('$apiBaseUrl/api/v1/disease/predict');
    final Map<String, dynamic> payload = {
      'crop': 'tomato',
      'image_base64': base64Image,
    };

    final http.Response response;
    try {
      response = await http
          .post(url,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(payload))
          .timeout(const Duration(seconds: 15));
    } on http.ClientException catch (e) {
      throw Exception('Network error: ${e.message}');
    } on TimeoutException {
      throw Exception('Request timed out. Ensure the backend is running.');
    } catch (e) {
      throw Exception('Connection failed: $e');
    }

    if (response.statusCode != 200) {
      // Try to extract detail from error body
      String detail = 'Server error: ${response.statusCode}';
      try {
        final errBody = jsonDecode(response.body) as Map<String, dynamic>;
        if (errBody.containsKey('detail')) {
          detail = errBody['detail'].toString();
        }
      } catch (_) {}
      throw Exception(detail);
    }

    final Map<String, dynamic> json = jsonDecode(response.body) as Map<String, dynamic>;
    return DiseaseResult.fromJson(json);
  }
}
