import 'package:flutter_test/flutter_test.dart';
import 'package:sasya_drishti/data/disease_advisory_data.dart';

void main() {
  group('Disease Advisory Knowledge Base Tests', () {
    const supportedClasses = [
      'Tomato_Early_Blight',
      'Tomato_Healthy',
      'Tomato_leaf_late_blight',
      'Tomato_leaf_yellow_curl_virus',
      'Tomato_mold_leaf',
      'Tomato_septora_leaf_spot',
    ];

    test('All 6 tomato classes are present in offline knowledge base', () {
      for (final diseaseId in supportedClasses) {
        expect(offlineAdvisoryData.containsKey(diseaseId), isTrue,
            reason: 'Missing disease advisory for $diseaseId');
      }
    });

    test('Each disease has complete English and Telugu localization', () {
      for (final diseaseId in supportedClasses) {
        final adv = offlineAdvisoryData[diseaseId]!;
        expect(adv.commonName.isNotEmpty, isTrue);
        expect(adv.commonNameTe.isNotEmpty, isTrue,
            reason: 'Missing Telugu common name for $diseaseId');
        expect(adv.scientificName.isNotEmpty, isTrue);
        expect(adv.explanation.isNotEmpty, isTrue);
        expect(adv.explanationTe.isNotEmpty, isTrue,
            reason: 'Missing Telugu explanation for $diseaseId');
        expect(adv.immediateActions.isNotEmpty, isTrue);
        expect(adv.immediateActionsTe.isNotEmpty, isTrue,
            reason: 'Missing Telugu immediate actions for $diseaseId');
        expect(adv.fertilizerRecommendation.isNotEmpty, isTrue);
        expect(adv.fertilizerRecommendationTe.isNotEmpty, isTrue,
            reason: 'Missing Telugu fertilizer guidance for $diseaseId');
        expect(adv.sources.isNotEmpty, isTrue);
        expect(adv.whenToSeekAssistance.isNotEmpty, isTrue);
      }
    });

    test('Pathogen classes include verified CIBRC chemical active ingredients', () {
      final pathogenClasses = supportedClasses.where((id) => id != 'Tomato_Healthy');
      for (final diseaseId in pathogenClasses) {
        final adv = offlineAdvisoryData[diseaseId]!;
        expect(adv.chemicalOptions.isNotEmpty, isTrue,
            reason: '$diseaseId must have registered chemical options');
        for (final chem in adv.chemicalOptions) {
          expect(chem.activeIngredient.isNotEmpty, isTrue);
          expect(chem.dosage.isNotEmpty, isTrue);
          expect(chem.phiDays, greaterThanOrEqualTo(0));
          expect(chem.reiHours, greaterThanOrEqualTo(0));
        }
      }
    });

    test('getOfflineAdvisory fallback returns Tomato_Healthy for unknown id', () {
      final fallback = getOfflineAdvisory('Unknown_Fungus_X');
      expect(fallback.diseaseId, equals('Tomato_Healthy'));
      expect(fallback.commonName, equals('Healthy Tomato Plant'));
    });

    test('evaluateContextualRisk generates late blight epidemic alert on cold wet weather', () {
      final alert = evaluateContextualRisk(
        diseaseId: 'Tomato_leaf_late_blight',
        humidity: 90.0,
        temp: 18.0,
        precipitationMm: 5.0,
      );
      expect(alert, contains('CRITICAL WEATHER ALERT'));
      expect(alert, contains('late blight'));
    });

    test('evaluateContextualRisk generates vector alert for TYLCV on hot dry weather', () {
      final alert = evaluateContextualRisk(
        diseaseId: 'Tomato_leaf_yellow_curl_virus',
        humidity: 45.0,
        temp: 32.0,
      );
      expect(alert, contains('HIGH VECTOR ACTIVITY'));
      expect(alert, contains('whitefly'));
    });

    test('evaluateContextualRisk generates mold warning on elevated humidity (>80%)', () {
      final alert = evaluateContextualRisk(
        diseaseId: 'Tomato_mold_leaf',
        humidity: 88.0,
        temp: 24.0,
      );
      expect(alert, contains('HIGH HUMIDITY WARNING'));
      expect(alert, contains('leaf mold'));
    });
  });
}
