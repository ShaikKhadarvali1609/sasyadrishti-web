// SasyaDrishti — Verified Offline Agricultural Knowledge Base
// Authoritative ICAR / TNAU / CIBRC / FAO Plant Pathology Data

class ChemicalTreatment {
  final String category;
  final String activeIngredient;
  final String dosage;
  final String usage;
  final int phiDays;
  final int reiHours;

  const ChemicalTreatment({
    required this.category,
    required this.activeIngredient,
    required this.dosage,
    required this.usage,
    required this.phiDays,
    required this.reiHours,
  });
}

class DiseaseAdvisory {
  final String diseaseId;
  final String crop;
  final String commonName;
  final String commonNameTe;
  final String scientificName;
  final String pathogenType;
  final String severity;
  final String severityLevel; // OPTIMAL, MODERATE, HIGH, CRITICAL
  final String explanation;
  final String explanationTe;
  final List<String> symptoms;
  final List<String> symptomsTe;
  final List<String> causes;
  final String spreadMechanism;
  final List<String> favorableConditions;
  final List<String> immediateActions;
  final List<String> immediateActionsTe;
  final List<String> culturalAndBiological;
  final List<ChemicalTreatment> chemicalOptions;
  final String safetyEquipment;
  final String fertilizerRelevance;
  final String fertilizerRecommendation;
  final String fertilizerRecommendationTe;
  final List<String> prevention;
  final List<String> preventionTe;
  final String whenToSeekAssistance;
  final List<String> sources;

  const DiseaseAdvisory({
    required this.diseaseId,
    required this.crop,
    required this.commonName,
    required this.commonNameTe,
    required this.scientificName,
    required this.pathogenType,
    required this.severity,
    required this.severityLevel,
    required this.explanation,
    required this.explanationTe,
    required this.symptoms,
    required this.symptomsTe,
    required this.causes,
    required this.spreadMechanism,
    required this.favorableConditions,
    required this.immediateActions,
    required this.immediateActionsTe,
    required this.culturalAndBiological,
    required this.chemicalOptions,
    required this.safetyEquipment,
    required this.fertilizerRelevance,
    required this.fertilizerRecommendation,
    required this.fertilizerRecommendationTe,
    required this.prevention,
    required this.preventionTe,
    required this.whenToSeekAssistance,
    required this.sources,
  });
}

const Map<String, DiseaseAdvisory> offlineAdvisoryData = {
  'Tomato_Early_Blight': DiseaseAdvisory(
    diseaseId: 'Tomato_Early_Blight',
    crop: 'Tomato',
    commonName: 'Tomato Early Blight / Target Spot',
    commonNameTe: 'టమాటో ముందస్తు ఆకుమచ్చ తెగులు (Early Blight)',
    scientificName: 'Alternaria solani Sorauer',
    pathogenType: 'Fungal',
    severity: 'Moderate to High',
    severityLevel: 'HIGH',
    explanation:
        'A common fungal disease attacking older lower leaves first. Produces characteristic dark brown spots with concentric target-board rings, leading to defoliation, sunburn on fruit, and significant yield loss.',
    explanationTe:
        'ఇది ఒక సాధారణ శిలీంద్ర తెగులు. మొదట మొక్క కింది భాగంలోని ముదిరిన ఆకులపై నల్లటి వలయాల మచ్చలు ఏర్పడి, ఆకులు ఎండి రాలిపోతాయి. దీనివల్ల కాయలపై ఎండ దెబ్బ తగిలి దిగుబడి తగ్గుతుంది.',
    symptoms: [
      'Small dark brown to black spots (1–2 cm) appearing on the oldest lower leaves.',
      'Concentric target-board rings inside lesions surrounded by a yellow halo.',
      'Leaves turn completely yellow, wither, and drop prematurely.',
      'Dark, sunken, leathery collar rot on stems near the soil surface.',
      'Dark sunken leathery spots on green and ripe tomato fruit near the calyx.',
    ],
    symptomsTe: [
      'కింది ముదిరిన ఆకులపై 1-2 సెం.మీ చిన్న నల్లటి లేదా గోధుమ రంగు మచ్చలు.',
      'మచ్చల లోపల వలయాల వంటి గుర్తులు మరియు చుట్టూ పసుపు రంగు వలయం.',
      'ఆకులు పసుపు రంగులోకి మారి ఎండి రాలిపోవడం.',
      'కాండం మొదట్లో నేల దగ్గర నల్లటి కుళ్లు మచ్చలు.',
    ],
    causes: [
      'Soil-borne fungus Alternaria solani surviving on crop debris and volunteer solanaceous weeds.',
      'Over-seasoned mycelium in unplowed crop residues.',
    ],
    spreadMechanism:
        'Wind-blown fungal spores and rain/sprinkler water splash from soil to lower leaves.',
    favorableConditions: [
      'Warm temperatures (24°C–29°C).',
      'High relative humidity (>80%) and prolonged leaf wetness (>6 hours).',
      'Overhead sprinkler irrigation or heavy dews.',
    ],
    immediateActions: [
      'Prune and collect all infected lower leaves; burn or bury them deep away from the field. Never compost infected leaves.',
      'Stop overhead sprinkler irrigation immediately; water strictly via ground furrow or drip irrigation.',
      'Apply clean straw or plastic mulch around the plant base to prevent soil splash during watering.',
    ],
    immediateActionsTe: [
      'తెగులు సోకిన కింది ఆకులను తుంచి పొలానికి దూరంగా కాల్చివేయండి లేదా పాతిపెట్టండి. కంపోస్ట్‌లో వేయవద్దు.',
      'పైనుంచి నీరు చల్లే స్ప్రింక్లర్లను వెంటనే ఆపి, డ్రిప్ ద్వారా మాత్రమే నీరు అందించండి.',
      'మొక్క మొదట్లో గడ్డి లేదా మల్చింగ్ షీట్ వేసి నేల నుంచి నీటి తుంపర్లు ఆకులపై పడకుండా చూడండి.',
    ],
    culturalAndBiological: [
      'Spray Trichoderma harzianum or Pseudomonas fluorescens (5–10 g/L) at root zone and foliage.',
      'Apply commercial Neem oil formulation (3–5 ml/L) as a protective botanical wash.',
    ],
    chemicalOptions: [
      ChemicalTreatment(
        category: 'Contact Protective Fungicide',
        activeIngredient: 'Mancozeb 75% WP',
        dosage: '2.0 – 2.5 g per liter of water',
        usage: 'Spray thoroughly at first appearance of spots; repeat at 7–10 day intervals during humid weather.',
        phiDays: 7,
        reiHours: 24,
      ),
      ChemicalTreatment(
        category: 'Contact Protective Fungicide',
        activeIngredient: 'Chlorothalonil 75% WP',
        dosage: '2.0 g per liter of water',
        usage: 'Ensure full coverage including underside of leaves. Do not apply during extreme heat.',
        phiDays: 7,
        reiHours: 24,
      ),
      ChemicalTreatment(
        category: 'Systemic Translaminar Fungicide',
        activeIngredient: 'Difenoconazole 25% EC',
        dosage: '0.5 ml per liter of water',
        usage: 'Curative spray for actively spreading spots. Alternate with contact fungicides.',
        phiDays: 7,
        reiHours: 24,
      ),
    ],
    safetyEquipment:
        'Wear chemical-resistant gloves, protective clothing, eye goggles, and a face mask during chemical mixing and spraying.',
    fertilizerRelevance:
        'Directly relevant. High nitrogen produces soft foliage that encourages fungal entry, whereas potassium and calcium reinforce cell walls.',
    fertilizerRecommendation:
        'Avoid excess Nitrogen (N). Apply balanced Potassium (K) (e.g. Potassium Sulfate or Nitrate) and Calcium (Ca) to thicken epidermal cell walls. Perform a standard soil test before major fertilizer applications. Note: Fertilizer does not cure existing fungal spots; it aids plant defense.',
    fertilizerRecommendationTe:
        'యూరియా (నత్రజని) అధికంగా వేయవద్దు. పొటాష్ మరియు కాల్షియం ఎరువులను సమతుల్యంగా వేసి మొక్క రోగనిరోధక శక్తిని పెంచండి. మట్టి పరీక్ష చేయించి తగిన మోతాదులో మాత్రమే ఎరువులు వాడండి.',
    prevention: [
      'Practice a 3-year crop rotation with non-solanaceous crops (maize, pulses, cereals).',
      'Maintain wide plant spacing (60 cm x 45 cm) and stake tomato vines to ensure good airflow.',
      'Use certified disease-free seeds or hot water seed treatment (50°C for 25 minutes).',
      'Deep summer plowing to bury previous crop residues.',
    ],
    preventionTe: [
      'టమాటా తర్వాత మొక్కజొన్న, పప్పుధాన్యాల పంటలతో 3 సంవత్సరాల పంట మార్పిడి చేయండి.',
      'మొక్కల మధ్య సరైన దూరం (60 సెం.మీ x 45 సెం.మీ) ఉంచి గాలి వెలుతురు ధారాళంగా వచ్చేలా చేయండి.',
      'ధ్రువీకరించిన నాణ్యమైన విత్తనాలను మాత్రమే వాడండి.',
    ],
    whenToSeekAssistance:
        'Contact the nearest Krishi Vigyan Kendra (KVK) or Block Horticulture Officer if spots spread above mid-canopy or appear on developing green fruit.',
    sources: [
      'TNAU Agritech Portal: Crop Protection — Tomato Early Blight',
      'ICAR-IIHR Tomato Disease Management Manual, Bengaluru',
      'CIBRC Approved Major Uses of Pesticides (Tomato)',
    ],
  ),

  'Tomato_Healthy': DiseaseAdvisory(
    diseaseId: 'Tomato_Healthy',
    crop: 'Tomato',
    commonName: 'Healthy Tomato Plant',
    commonNameTe: 'ఆరోగ్యకరమైన టమాటా మొక్క (Healthy)',
    scientificName: 'Solanum lycopersicum L.',
    pathogenType: 'None (Healthy)',
    severity: 'Optimal Condition',
    severityLevel: 'OPTIMAL',
    explanation:
        'The foliage is in healthy condition with vibrant green color, uniform turgidity, clean venation, and no signs of fungal, bacterial, or viral pathogens.',
    explanationTe:
        'మొక్క ఆకులు ఆరోగ్యంగా ఉన్నాయి. ఎలాంటి తెగుళ్లు లేదా పురుగుల లక్షణాలు లేవు. సమతుల్య నీటి మరియు ఎరువుల యాజమాన్యం కొనసాగించండి.',
    symptoms: [
      'Uniform deep-green leaves without yellowing, necrotic spots, or cupping.',
      'Intact leaf margins and normal foliar hair (trichome) density.',
      'Vigorous apical growth and strong flower/fruit clusters.',
    ],
    symptomsTe: [
      'ఆకులన్నీ పచ్చగా ఎలాంటి మచ్చలు లేకుండా ఉన్నాయి.',
      'పూత మరియు పిందెలు సహజంగా ఎదుగుతున్నాయి.',
    ],
    causes: ['Balanced crop nutrition, regular scouting, and optimal field sanitation.'],
    spreadMechanism: 'Not applicable.',
    favorableConditions: ['Optimal temperature (20°C–28°C), good soil aeration, balanced drip irrigation.'],
    immediateActions: [
      'Continue routine twice-weekly field scouting (inspect leaf undersides for early whitefly or spore arrival).',
      'Maintain steady irrigation scheduling according to crop evapotranspiration (ETc).',
    ],
    immediateActionsTe: [
      'వారానికి రెండుసార్లు తోటను పరిశీలిస్తూ ఆకుల అడుగుభాగాన్ని గమనించండి.',
      'వాతావరణానికి తగినట్లుగా క్రమం తప్పకుండా డ్రిప్ ద్వారా నీటిని అందించండి.',
    ],
    culturalAndBiological: [
      'Maintain weed-free bunds and field borders.',
      'Periodically spray organic Jeevamrutha or Panchagavya (3%) to enhance foliar phyllosphere immunity.',
    ],
    chemicalOptions: [],
    safetyEquipment: 'Standard personal protective equipment during routine field operations.',
    fertilizerRelevance: 'Nutrient maintenance for ongoing growth stages.',
    fertilizerRecommendation:
        'Follow stage-specific fertigation: vegetative stage requires balanced NPK (19:19:19); flowering/fruit set requires higher Potassium (13:0:45) and foliar Boron (0.1%) to prevent blossom drop.',
    fertilizerRecommendationTe:
        'పూత దశలో బోరాన్ మరియు పొటాష్ ఎరువులను అందించడం ద్వారా పిందె రాలకుండా కాపాడుకోవచ్చు.',
    prevention: [
      'Avoid overhead irrigation; use drip system.',
      'Maintain yellow sticky traps (10/acre) for early whitefly and thrips detection.',
    ],
    preventionTe: ['పసుపు జిగురు అట్టలను ఎకరానికి 10 చొప్పున అమర్చి తెల్లదోమలను గమనించండి.'],
    whenToSeekAssistance: 'Consult extension services if uncharacteristic leaf curl, yellowing, or abnormal wilting appears.',
    sources: [
      'ICAR Package of Practices for Tomato Cultivation',
      'FAO Good Agricultural Practices (GAP)',
    ],
  ),

  'Tomato_leaf_late_blight': DiseaseAdvisory(
    diseaseId: 'Tomato_leaf_late_blight',
    crop: 'Tomato',
    commonName: 'Tomato Late Blight / Mahali Disease',
    commonNameTe: 'టమాటో లేట్ బ్లైట్ / మాడు తెగులు (Late Blight)',
    scientificName: 'Phytophthora infestans (Mont.) de Bary',
    pathogenType: 'Oomycete (Water Mold)',
    severity: 'Critical — High Epidemic Threat',
    severityLevel: 'CRITICAL',
    explanation:
        'The most destructive tomato disease worldwide. Triggered by cool, damp weather, it causes rapidly expanding water-soaked greasy brown lesions on leaves and frosty white downy mold on leaf undersides, capable of killing an entire field in 7–10 days.',
    explanationTe:
        'ఇది అత్యంత ప్రమాదకరమైన శిలీంద్ర తెగులు. చల్లని, మంచు మరియు వర్షపు వాతావరణంలో ఆకులపై నూనె పూసినట్లు నీటి మచ్చలు ఏర్పడి, అడుగుభాగంలో తెల్లటి బూజు వస్తుంది. కొద్ది రోజుల్లోనే తోట మొత్తం కాలిపోయినట్లు మాడుతుంది.',
    symptoms: [
      'Irregular, water-soaked, pale green lesions rapidly expanding into large greasy dark brown blotches.',
      'Delicate white frosty downy mold on the underside of affected leaves during humid mornings.',
      'Greasy, dark brown water-soaked lesions wrapping around stems, causing vine collapse.',
      'Firm, greasy, olive-brown blotches on green fruit rendering them unmarketable.',
    ],
    symptomsTe: [
      'ఆకులపై నీరు పట్టినట్లు పాలిపోయిన మచ్చలు ఏర్పడి వేగంగా ముదురు గోధుమ రంగులోకి మారడం.',
      'తేమతో కూడిన ఉదయపు వేళల్లో ఆకుల అడుగున తెల్లటి దూది వంటి బూజు కనిపించడం.',
      'కాండం కుళ్ళిపోయి మొక్క నేలకొరగడం.',
      'పచ్చి కాయలపై ముదురు ఆలివ్ రంగు గట్టి మచ్చలు ఏర్పడటం.',
    ],
    causes: [
      'Airborne sporangia and swimming zoospores of Phytophthora infestans.',
      'Infected volunteer tomato/potato plants and infected cull piles in nearby areas.',
    ],
    spreadMechanism:
        'Extremely rapid wind-borne sporangia carried for miles, followed by motile zoospores swimming in free moisture films on leaves.',
    favorableConditions: [
      'Cool to moderate temperatures (12°C–22°C).',
      'High relative humidity (>90%) with continuous fog, drizzling rain, or heavy morning dew.',
      'Dense foliage shading that prevents leaves from drying.',
    ],
    immediateActions: [
      'Immediately stop all irrigation until the soil surface dries completely.',
      'Carefully uproot and bag severely blighted plants; bury deep (>2 feet) or burn outside the field. Do NOT leave culled plants in open pits.',
      'Sanitize sprayers, boots, and cutting tools with 10% bleach solution between field rows.',
    ],
    immediateActionsTe: [
      'తోటకు నీరు పెట్టడం వెంటనే ఆపివేయండి.',
      'తీవ్రంగా తెగులు సోకిన మొక్కలను తవ్వి సంచిలో వేసి పొలానికి దూరంగా లోతుగా పాతిపెట్టండి లేదా కాల్చండి.',
      'మనుషులు మరియు పరికరాల ద్వారా తెగులు ఇతర మొక్కలకు వ్యాపించకుండా జాగ్రత్త వహించండి.',
    ],
    culturalAndBiological: [
      'Remove volunteer potato or tomato plants within a 500-meter radius.',
      'Ensure rapid drainage; create raised beds and clear drainage furrows.',
    ],
    chemicalOptions: [
      ChemicalTreatment(
        category: 'Translaminar / Contact Oomycide',
        activeIngredient: 'Cymoxanil 8% + Mancozeb 64% WP',
        dosage: '2.0 – 2.5 g per liter of water',
        usage: 'Apply at the earliest sign of infection or when weather warnings predict persistent rain. Repeat at 7-day intervals.',
        phiDays: 10,
        reiHours: 24,
      ),
      ChemicalTreatment(
        category: 'Systemic Fungicide',
        activeIngredient: 'Metalaxyl 8% + Mancozeb 64% WP',
        dosage: '2.5 g per liter of water',
        usage: 'Curative systemic action. Do not exceed 2 sprays per season to prevent pathogen resistance.',
        phiDays: 10,
        reiHours: 24,
      ),
      ChemicalTreatment(
        category: 'Locally Systemic Fungicide',
        activeIngredient: 'Dimethomorph 50% WP',
        dosage: '1.0 g per liter of water',
        usage: 'Apply in combination with contact protective fungicide for anti-sporulant action.',
        phiDays: 10,
        reiHours: 24,
      ),
    ],
    safetyEquipment:
        'Mandatory chemical-resistant gloves, full-sleeve protective clothing, goggles, and vapor/particulate respirator mask.',
    fertilizerRelevance:
        'Critical. Heavy nitrogen fertilization produces soft, succulent tissues that accelerate Phytophthora entry.',
    fertilizerRecommendation:
        'Immediately suspend nitrogen applications during active late blight weather. Apply foliar Potassium Phosphite to trigger systemic acquired resistance (SAR). Test soil before post-infection recovery fertilization.',
    fertilizerRecommendationTe:
        'యూరియా లేదా నత్రజని ఎరువులను తక్షణమే నిలిపివేయండి. అధిక నత్రజని తెగులును మరింత ఉధృతం చేస్తుంది.',
    prevention: [
      'Plant certified late-blight tolerant hybrids (e.g. Arka Rakshak, Arka Abhed).',
      'Maintain wide row spacing (75 cm) and prune lower leaves up to 20 cm from ground level.',
      'Never cultivate tomatoes directly adjacent to potato fields.',
      'Apply prophylactic Mancozeb (2.0 g/L) before anticipated cold, rainy weather fronts.',
    ],
    preventionTe: [
      'తెగులును తట్టుకునే రకాలైన అర్క రక్షక్, అర్క అభేద్ వంటి వంగడాలను ఎంచుకోండి.',
      'బంగాళాదుంప పొలాలకు దగ్గరగా టమాటా సాగు చేయవద్దు.',
    ],
    whenToSeekAssistance:
        'URGENT: Report immediately to KVK or District Agricultural Officer; late blight requires coordinated regional alerts to prevent community crop loss.',
    sources: [
      'ICAR-IIHR Tomato Disease Factsheets: Late Blight Management',
      'TNAU Agritech Portal: Crop Protection — Tomato Late Blight',
      'CIBRC Registered Fungicides for Phytophthora in Solanaceous Crops',
    ],
  ),

  'Tomato_leaf_yellow_curl_virus': DiseaseAdvisory(
    diseaseId: 'Tomato_leaf_yellow_curl_virus',
    crop: 'Tomato',
    commonName: 'Tomato Leaf Curl Virus (TYLCV)',
    commonNameTe: 'టమాటో ఆకు ముడుత తెగులు (Leaf Curl Virus)',
    scientificName: 'Tomato leaf curl New Delhi virus / Begomovirus',
    pathogenType: 'Viral (Whitefly Vector)',
    severity: 'High to Critical',
    severityLevel: 'CRITICAL',
    explanation:
        'A devastating viral disease transmitted by the sweetpotato whitefly (Bemisia tabaci). Causes severe upward leaf curling, yellowing of leaf margins, severe plant stunting, and flower drop, resulting in nearly 100% crop loss if contracted in early stages.',
    explanationTe:
        'ఇది తెల్లదోమ ద్వారా వ్యాపించే వైరస్ తెగులు. ఆకులు పైకి ముడుచుకుని, అంచులు పసుపు రంగులోకి మారి మొక్క ఎదుగుదల ఆగిపోతుంది. పూత రాలిపోయి తీవ్రమైన పంట నష్టం జరుగుతుంది.',
    symptoms: [
      'Pronounced upward curling and cupping of young apical leaves.',
      'Yellowing (chlorosis) along leaf margins and between veins, with veins remaining dark green.',
      'Marked stunting of plants with drastically shortened internodes, giving a bushy appearance.',
      'Leathery, thick, brittle leaf texture.',
      'Premature flower abortion and severely reduced fruit set.',
    ],
    symptomsTe: [
      'కొమ్మ చివరన ఉన్న లేత ఆకులు పైకి దోనెలా ముడుచుకుపోవడం.',
      'ఆకుల అంచులు పసుపు రంగులోకి మారడం, ఈనెలు ఆకుపచ్చగా ఉండటం.',
      'కణుపుల మధ్య దూరం తగ్గి మొక్క గిడసబారి గుబురుగా మారడం.',
      'పూత రాలిపోయి కాయలు కాయకపోవడం.',
    ],
    causes: [
      'Begomovirus infection transmitted exclusively by the insect vector Bemisia tabaci (whitefly).',
      'Not transmitted by seeds, soil, water, or mechanical leaf contact.',
    ],
    spreadMechanism:
        'Whiteflies feeding on infected hosts and transmitting the virus to healthy plants within 15–30 minutes of feeding.',
    favorableConditions: [
      'Warm, dry, sunny weather (28°C–38°C) promoting rapid whitefly reproduction.',
      'Nearby infected crops (cotton, tobacco, chili, okra, cucurbits) or weed hosts (Parthenium, Datura).',
      'Prolonged dry spells with low relative humidity.',
    ],
    immediateActions: [
      'Roguing: Carefully pull up and burn severely stunted viral-infected plants. Place in closed bags before removal so whiteflies cannot escape.',
      'Install yellow sticky traps (15–20 traps per acre) at canopy height to capture adult whiteflies and monitor populations.',
      'Plant barrier crops (3–4 rows of maize, sorghum, or pearl millet) around the tomato field border to block incoming whitefly swarms.',
    ],
    immediateActionsTe: [
      'తీవ్రంగా ముడుచుకుపోయిన మొక్కలను పీకి ప్లాస్టిక్ సంచిలో వేసి తోటకు దూరంగా తీసుకెళ్లి నాశనం చేయండి.',
      'ఎకరానికి 15-20 పసుపు జిగురు అట్టలను పైరు ఎత్తులో అమర్చి తెల్లదోమలను బంధించండి.',
      'పొలం చుట్టూ 3-4 వరుసల జొన్న లేదా మొక్కజొన్నను సరిహద్దు రక్షణ పంటగా వేయండి.',
    ],
    culturalAndBiological: [
      'IMPORTANT: There is no chemical cure for viral infections inside the plant. Management focuses on whitefly vector suppression.',
      'Spray Neem Seed Kernel Extract (NSKE 5%) or Azadirachtin 10,000 ppm (2.0 ml/L) as an anti-ovipositional repellent.',
      'Release green lacewing larvae (Chrysoperla zastrowi) at 10,000 larvae per acre.',
    ],
    chemicalOptions: [
      ChemicalTreatment(
        category: 'Systemic Neonicotinoid Insecticide',
        activeIngredient: 'Imidacloprid 17.8% SL',
        dosage: '0.3 ml per liter of water',
        usage: 'Spray on underside of foliage where whiteflies congregate. Rotate with different chemical classes.',
        phiDays: 5,
        reiHours: 24,
      ),
      ChemicalTreatment(
        category: 'Systemic Insecticide',
        activeIngredient: 'Thiamethoxam 25% WG',
        dosage: '0.4 g per liter of water',
        usage: 'Foliar spray during early morning hours when whiteflies are sluggish on lower leaf surfaces.',
        phiDays: 5,
        reiHours: 24,
      ),
      ChemicalTreatment(
        category: 'Insect Growth Regulator / Acaricide',
        activeIngredient: 'Diafenthiuron 50% WP',
        dosage: '1.0 g per liter of water',
        usage: 'Effective on resistant whitefly nymphs and adults. Apply in alternating rotation.',
        phiDays: 7,
        reiHours: 24,
      ),
    ],
    safetyEquipment:
        'Wear chemical-resistant gloves, protective clothing, and respirator mask when handling insecticides.',
    fertilizerRelevance:
        'Nutritional management helps mildly affected border plants withstand viral stress.',
    fertilizerRecommendation:
        'Spray micronutrient mixture containing Zinc (0.5%), Boron (0.2%), and Iron (0.5%) along with 1% Urea to reduce chlorotic stress. Avoid high doses of nitrogen alone, which attracts sap-sucking whitefly populations.',
    fertilizerRecommendationTe:
        'జింక్, బోరాన్, ఇనుము వంటి సూక్ష్మపోషకాల మిశ్రమాన్ని పిచికారీ చేసి మొక్కకు బలాన్ని ఇవ్వండి. నత్రజని ఎరువులను అధికంగా వాడకండి.',
    prevention: [
      'Grow TYLCV-resistant F1 tomato hybrids (e.g. Arka Rakshak, Arka Abhed, US-440).',
      'Raise tomato nursery seedlings under 40-mesh insect-proof nylon netting for 25–30 days prior to transplanting.',
      'Eradicate Parthenium and weed hosts around field bunds.',
    ],
    preventionTe: [
      'నర్సరీ దశలో 40 మెష్ దోమతెర కింద నారు పెంచడం ద్వారా ప్రారంభంలోనే తెల్లదోమ ఆశించకుండా కాపాడవచ్చు.',
      'తెగులు తట్టుకునే అర్క రక్షక్ వంటి హైబ్రిడ్ రకాలను ఎంచుకోండి.',
    ],
    whenToSeekAssistance:
        'Consult a KVK entomologist if whitefly counts exceed the economic threshold level (ETL: >5 whiteflies per leaflet).',
    sources: [
      'ICAR-IIHR Guidelines: Management of Tomato Leaf Curl Virus',
      'TNAU Agritech Portal: Tomato Pests and Vectors (Whitefly & TYLCV)',
      'CIBRC Approved Major Uses of Insecticides for Bemisia tabaci on Tomato',
    ],
  ),

  'Tomato_mold_leaf': DiseaseAdvisory(
    diseaseId: 'Tomato_mold_leaf',
    crop: 'Tomato',
    commonName: 'Tomato Leaf Mold',
    commonNameTe: 'టమాటో బూజు ఆకుమచ్చ తెగులు (Leaf Mold)',
    scientificName: 'Passalora fulva (Cooke) U. Braun / Cladosporium fulvum',
    pathogenType: 'Fungal',
    severity: 'Moderate',
    severityLevel: 'MODERATE',
    explanation:
        'A foliar fungal disease that thrives in high-humidity conditions (polyhouses, shaded fields, dense canopies). Pale greenish-yellow blotches form on upper leaf surfaces, while a velvety olive-green to brown mold forms directly beneath on the leaf underside.',
    explanationTe:
        'ఎక్కువ తేమ ఉన్న వాతావరణంలో ఈ శిలీంద్ర తెగులు వస్తుంది. ఆకుల పైభాగంలో పసుపు రంగు మచ్చలు, వాటి అడుగున వెల్వెట్ వంటి ఆలివ్-గోధుమ రంగు బూజు కనిపిస్తుంది. ఆకులు ఎండి రాలిపోతాయి.',
    symptoms: [
      'Pale green to yellowish indistinct patches on the upper surface of older leaves.',
      'Dense, velvety olive-green to purplish-brown fungal sporulation directly on the lower leaf surface.',
      'Leaves curl, turn brown, wither, and drop prematurely.',
      'In severe attacks, blossom clusters wither and drop.',
    ],
    symptomsTe: [
      'ఆకుల పైభాగంలో పసుపుపచ్చని మచ్చలు.',
      'ఆకుల అడుగున ఆలివ్-గోధుమ రంగు బూజు పొర.',
      'ఆకులు ముడుచుకుని రాలిపోవడం, పూత ఎండిపోవడం.',
    ],
    causes: [
      'Fungal pathogen Passalora fulva surviving as conidia or sclerotia in crop residues and greenhouse structures.',
    ],
    spreadMechanism:
        'Conidiospores carried by gentle air currents, greenhouse drafts, rain splash, and handling wet plants.',
    favorableConditions: [
      'High relative humidity (>85%), especially in protected polyhouses or dense shaded canopies.',
      'Temperatures between 21°C and 26°C.',
      'Poor air circulation within dense unpruned tomato foliage.',
    ],
    immediateActions: [
      'Increase canopy ventilation immediately: prune lower suckers and dense inner foliage.',
      'Open polyhouse side vents to lower ambient relative humidity below 80%.',
      'Avoid late evening irrigation; water early in the morning so leaves dry quickly.',
    ],
    immediateActionsTe: [
      'గాలి వెలుతురు ధారాళంగా వచ్చేలా కింది వైపున ఉన్న అనవసర కొమ్మలను కత్తిరించండి.',
      'పాలీహౌస్ లేదా షేడ్‌నెట్ సైడ్ కర్టెన్లు తెరిచి తేమ శాతాన్ని తగ్గించండి.',
      'సాయంత్రం వేళల్లో నీరు పెట్టవద్దు; ఉదయమే నీరందించండి.',
    ],
    culturalAndBiological: [
      'Remove and burn severely molded lower leaves.',
      'Ensure proper north-south row orientation for maximum sun penetration.',
    ],
    chemicalOptions: [
      ChemicalTreatment(
        category: 'Protective Copper Fungicide',
        activeIngredient: 'Copper Oxychloride 50% WP',
        dosage: '2.5 g per liter of water',
        usage: 'Spray thoroughly ensuring chemical reaches the underside of all leaves.',
        phiDays: 7,
        reiHours: 24,
      ),
      ChemicalTreatment(
        category: 'Systemic Fungicide',
        activeIngredient: 'Difenoconazole 25% EC',
        dosage: '0.5 ml per liter of water',
        usage: 'Curative spray on expanding lesions. Target lower leaf surface where spores reside.',
        phiDays: 7,
        reiHours: 24,
      ),
      ChemicalTreatment(
        category: 'Strobilurin Fungicide',
        activeIngredient: 'Kresoxim-methyl 44.3% SC',
        dosage: '1.0 ml per liter of water',
        usage: 'Excellent preventative and anti-sporulant action. Do not apply continuously.',
        phiDays: 5,
        reiHours: 24,
      ),
    ],
    safetyEquipment: 'Standard personal protective gear (gloves, eye protection, face mask).',
    fertilizerRelevance: 'Nutrient balance influences foliage density and leaf cuticle thickness.',
    fertilizerRecommendation:
        'Avoid high doses of nitrogen which create dense, humid microclimates within the canopy. Maintain adequate Potassium levels. Soil testing recommended.',
    fertilizerRecommendationTe:
        'అధిక నత్రజని వాడకం వల్ల చెట్లు గుబురుగా పెరిగి తేమ పెరుగుతుంది, కాబట్టి సమతుల్య పొటాష్ ఎరువులు వాడండి.',
    prevention: [
      'Grow tomato varieties carrying Cf resistance genes (Cf-2, Cf-4, Cf-9).',
      'Maintain wide plant spacing (60 cm x 50 cm).',
      'Sterilize greenhouse frames, stakes, and strings with 5% formalin between crop cycles.',
    ],
    preventionTe: ['మొక్కల మధ్య సరైన దూరం పాటించి గాలి ప్రసరణ బాగుండేలా చూడండి.'],
    whenToSeekAssistance: 'Consult horticulture specialists if leaf mold persists despite polyhouse humidity reduction.',
    sources: [
      'TNAU Crop Protection Guide: Tomato Leaf Mold',
      'University of Florida IFAS Extension: Tomato Leaf Mold Management',
      'CIBRC Approved List of Fungicides for Solanaceous Vegetables',
    ],
  ),

  'Tomato_septora_leaf_spot': DiseaseAdvisory(
    diseaseId: 'Tomato_septora_leaf_spot',
    crop: 'Tomato',
    commonName: 'Tomato Septoria Leaf Spot',
    commonNameTe: 'టమాటో సెప్టోరియా ఆకుమచ్చ తెగులు (Septoria Leaf Spot)',
    scientificName: 'Septoria lycopersici Speg.',
    pathogenType: 'Fungal',
    severity: 'Moderate to High',
    severityLevel: 'HIGH',
    explanation:
        'A destructive foliar fungal disease causing hundreds of tiny circular spots with dark brown margins and ash-grey centers containing tiny black dots. Progresses from bottom leaves upwards, causing heavy leaf loss and exposing tomatoes to sunburn.',
    explanationTe:
        'ఆకులపై వందలాది చిన్న గుండ్రని మచ్చలు ఏర్పడే శిలీంద్ర తెగులు. మచ్చల అంచు ముదురు గోధుమ రంగులో, మధ్య భాగం బూడిద రంగులో ఉండి చిన్న నల్లటి చుక్కలు కనిపిస్తాయి. ఆకులు రాలిపోయి కాయలపై ఎండ దెబ్బ తగులుతుంది.',
    symptoms: [
      'Numerous small, circular spots (2–4 mm across) appearing on the lowest leaves first.',
      'Characteristic spots with dark brown borders and pale ash-grey or tan centers.',
      'Tiny black specks (pycnidia fruiting bodies) visible in the center of older spots with a magnifying lens.',
      'Yellowing of leaf tissue surrounding spots, followed by drying and complete defoliation.',
      'Defoliation exposing fruit clusters to sunscald.',
    ],
    symptomsTe: [
      'మొదట కింది ఆకులపై 2-4 మి.మీ చిన్న గుండ్రని మచ్చలు.',
      'మచ్చల అంచులు నల్లగా, మధ్యలో బూడిద రంగు చుక్కలు ఉండటం.',
      'ఆకులు పసుపు రంగులోకి మారి రాలిపోవడం.',
      'మొక్కలపై ఆకులు లేక కాయలు ఎండకు దెబ్బతినడం.',
    ],
    causes: [
      'Septoria lycopersici surviving on solanaceous crop residues, weed hosts (Solanum nigrum), and volunteer plants.',
    ],
    spreadMechanism:
        'Fungal spores exuded in gelatinous tendrils and splashed by raindrops, overhead irrigation, and field workers handling wet foliage.',
    favorableConditions: [
      'Moderate temperatures (20°C–25°C).',
      'Frequent rainfall, persistent dew, and extended leaf wetness (>8–10 hours).',
      'High relative humidity (>80%).',
    ],
    immediateActions: [
      'Never cultivate, prune, or harvest in tomato fields when leaves are wet with dew or rain.',
      'Gently prune off and burn the lowest 3–4 infected leaves touching or near the soil.',
      'Lay down thick straw or plastic mulch around the plant base to create a physical barrier against soil-to-leaf water splashing.',
    ],
    immediateActionsTe: [
      'ఆకులు తడిగా ఉన్నప్పుడు తోటలో ఎలాంటి పనులు చేయవద్దు.',
      'నేల తాకుతున్న కింది 3-4 తెగులు సోకిన ఆకులను తుంచి కాల్చివేయండి.',
      'మొక్క మొదట్లో గడ్డితో మల్చింగ్ చేసి నేల నుంచి నీటి తుంపర్లు ఆకులపై పడకుండా చూడండి.',
    ],
    culturalAndBiological: [
      'Seedling root dip in bio-agent Pseudomonas fluorescens (10 g/L) before transplanting.',
      'Spray neem oil formulation (3 ml/L) as a preventive botanical wash.',
    ],
    chemicalOptions: [
      ChemicalTreatment(
        category: 'Contact Dithiocarbamate Fungicide',
        activeIngredient: 'Mancozeb 75% WP',
        dosage: '2.0 – 2.5 g per liter of water',
        usage: 'Start sprays when first spots appear on lower leaves. Repeat every 7–10 days during rainy periods.',
        phiDays: 7,
        reiHours: 24,
      ),
      ChemicalTreatment(
        category: 'Contact Protective Fungicide',
        activeIngredient: 'Zineb 75% WP',
        dosage: '2.0 g per liter of water',
        usage: 'Broad-spectrum foliar protective spray with good leaf adhesion.',
        phiDays: 7,
        reiHours: 24,
      ),
      ChemicalTreatment(
        category: 'Systemic Triazole Fungicide',
        activeIngredient: 'Tebuconazole 25.9% EC',
        dosage: '1.0 ml per liter of water',
        usage: 'Apply for curative translaminar action if infection spreads to mid-canopy.',
        phiDays: 7,
        reiHours: 24,
      ),
    ],
    safetyEquipment: 'Wear chemical-resistant gloves, protective clothing, and face mask during application.',
    fertilizerRelevance: 'Directly impacts canopy density and plant recovery capacity.',
    fertilizerRecommendation:
        'Maintain balanced NPK and adequate Calcium. Avoid excess nitrogen which encourages dense, slowly-drying foliage. Soil testing recommended before applying fertilizers.',
    fertilizerRecommendationTe:
        'నత్రజని మోతాదు మించకుండా చూసి, పొటాష్ మరియు కాల్షియం ఎరువులను సరిపడా వేయండి.',
    prevention: [
      'Practice a 3-year crop rotation without solanaceous crops (tomatoes, potatoes, eggplants).',
      'Perform deep summer plowing to bury previous crop debris.',
      'Eradicate nightshade and solanaceous weeds along borders.',
      'Stake and trellis tomato plants to elevate foliage above wet soil.',
    ],
    preventionTe: [
      'టమాటా తర్వాత ఇతర పంటలతో పంట మార్పిడి చేయండి.',
      'వేసవిలో లోతు దుక్కులు చేసి తెగులు శేషాలను నశింపజేయండి.',
    ],
    whenToSeekAssistance:
        'Seek help from KVK or Agricultural Extension if defoliation reaches the middle canopy before fruit harvest.',
    sources: [
      'TNAU Agritech Portal: Crop Protection — Tomato Septoria Leaf Spot',
      'ICAR-IIHR Bengaluru: Vegetable Pathology Technical Bulletin',
      'CIBRC Approved Pesticides for Septoria on Solanaceous Crops',
    ],
  ),
};

DiseaseAdvisory getOfflineAdvisory(String diseaseId) {
  return offlineAdvisoryData[diseaseId] ??
      offlineAdvisoryData['Tomato_Healthy']!;
}

/// Evaluates real-time agronomic environmental risk based on diagnosed disease and ambient weather.
String evaluateContextualRisk({
  required String diseaseId,
  double? humidity,
  double? temp,
  double? precipitationMm,
}) {
  final h = humidity ?? 60.0;
  final t = temp ?? 25.0;
  final rain = precipitationMm ?? 0.0;

  if (diseaseId == 'Tomato_leaf_late_blight') {
    if (h > 85.0 && t <= 22.0) {
      return 'CRITICAL WEATHER ALERT: Cold wet conditions ($t°C, $h% RH) create maximum epidemic risk for rapid late blight sporulation and canopy collapse. Act within 24 hours.';
    } else if (h > 75.0) {
      return 'HIGH WEATHER RISK: Elevated humidity ($h% RH) supports Phytophthora spore movement. Strictly avoid sprinkler watering.';
    }
  } else if (diseaseId == 'Tomato_Early_Blight' || diseaseId == 'Tomato_septora_leaf_spot') {
    if (h > 80.0 || rain > 1.0) {
      return 'HIGH SPORE SPLASH RISK: Humidity is $h% with moisture/rain. Conidia splash aggressively from lower canopy. Ensure plants are mulched and lower leaves pruned.';
    }
  } else if (diseaseId == 'Tomato_mold_leaf') {
    if (h > 80.0) {
      return 'HIGH HUMIDITY WARNING: Ambient humidity ($h% RH) exceeds leaf mold threshold (>80%). Immediately increase row ventilation and prune suckers.';
    }
  } else if (diseaseId == 'Tomato_leaf_yellow_curl_virus') {
    if (t >= 28.0 && h < 60.0) {
      return 'HIGH VECTOR ACTIVITY: Warm dry weather ($t°C, $h% RH) accelerates whitefly breeding. Inspect yellow sticky traps daily.';
    }
  }
  return 'ENVIRONMENTAL STATUS: Conditions are currently moderate ($t°C, ${h.toInt()}% RH). Maintain standard scouting protocols.';
}

