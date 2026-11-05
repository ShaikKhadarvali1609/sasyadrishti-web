"""
SasyaDrishti — Verified Agricultural Advisory Knowledge Base
============================================================
Authoritative plant pathology and agronomic guidance for tomato disease classes.
Sources:
- ICAR - Indian Institute of Horticultural Research (IIHR), Bengaluru
- Tamil Nadu Agricultural University (TNAU) Agritech Portal (Crop Protection: Tomato)
- Directorate of Plant Protection, Quarantine & Storage (DPPQS) / CIBRC, Govt. of India
- FAO Plant Protection Guidance
"""

ADVISORY_KNOWLEDGE_BASE = {
    "Tomato_Early_Blight": {
        "disease_id": "Tomato_Early_Blight",
        "crop": "Tomato",
        "common_name": "Tomato Early Blight / Target Spot",
        "scientific_name": "Alternaria solani Sorauer",
        "pathogen_type": "Fungal",
        "severity": "Moderate to High",
        "severity_level": "MODERATE_HIGH",
        "explanation": "A destructive fungal foliar disease that attacks older lower leaves first. Characteristic dark brown spots develop with concentric rings resembling a target board, leading to defoliation, sunburn on fruit, and significant yield loss.",
        "symptoms": [
            "Small dark brown to black spots (1–2 cm) appearing initially on the oldest lower leaves.",
            "Prominent concentric rings within spots creating a 'target board' pattern, surrounded by yellow chlorotic halos.",
            "Coalescing lesions causing complete blighting, drying, and premature leaf drop.",
            "Sunken, dark, leathery collar rot lesions on stems near soil line.",
            "Dark, leathery sunken lesions on fruit at the stem attachment point."
        ],
        "causes": [
            "Soil-borne fungal pathogen Alternaria solani surviving on crop debris, solanaceous volunteer plants, and infected seeds.",
            "Over-wintered or over-summered mycelium in crop residues."
        ],
        "spread_mechanism": "Conidiospores dispersed by wind currents, rain splashing from infested soil onto lower foliage, and mechanical transfer via farm tools and workers in wet fields.",
        "favorable_conditions": [
            "Warm temperatures between 24°C and 29°C.",
            "High relative humidity (>80%) and prolonged leaf wetness (>6 hours) from rain, heavy dew, or overhead sprinkler irrigation.",
            "Stressed plants due to poor nutrition, heavy fruit load, or nematode damage."
        ],
        "immediate_actions": [
            "Prune and remove all infected lower leaves; burn or bury them deep away from the field. Do NOT compost infected foliage.",
            "Immediately halt overhead sprinkler irrigation; switch strictly to ground furrow or drip irrigation to keep canopy dry.",
            "Apply a clean straw or plastic mulch around the plant base (4–6 inch layer) to prevent soil splashing onto lower leaves."
        ],
        "treatment_options": {
            "cultural_and_biological": [
                "Foliar spray of Trichoderma harzianum or Pseudomonas fluorescens (5–10 g/L) as a bio-fungicide antagonist.",
                "Spray commercial Neem oil formulation (3–5 ml/L with 0.5 ml soap emulsifier) as a protective botanical spray."
            ],
            "chemical_cibrc_approved": [
                {
                    "trade_category": "Contact Protective Fungicide",
                    "active_ingredient": "Mancozeb 75% WP",
                    "dosage": "2.0 – 2.5 g per liter of water",
                    "usage_instructions": "Spray thoroughly at first appearance of spots; repeat at 7–10 day intervals during humid weather.",
                    "phi_days": 7,
                    "rei_hours": 24,
                    "cibrc_registered": True
                },
                {
                    "trade_category": "Contact Protective Fungicide",
                    "active_ingredient": "Chlorothalonil 75% WP",
                    "dosage": "2.0 g per liter of water",
                    "usage_instructions": "Ensure full canopy coverage including lower leaf surfaces. Do not apply during extreme heat.",
                    "phi_days": 7,
                    "rei_hours": 24,
                    "cibrc_registered": True
                },
                {
                    "trade_category": "Systemic Translaminar Fungicide",
                    "active_ingredient": "Difenoconazole 25% EC",
                    "dosage": "0.5 ml per liter of water",
                    "usage_instructions": "Use for curative action if lesions are actively expanding. Alternate with contact fungicides to prevent resistance.",
                    "phi_days": 7,
                    "rei_hours": 24,
                    "cibrc_registered": True
                }
            ],
            "safety_equipment": "Wear protective gloves, eye goggles, and a face mask during chemical mixing and application. Wash hands thoroughly afterwards."
        },
        "fertilizer_guidance": {
            "relevance": "Directly relevant. High nitrogen fertilizer softens leaf tissue and worsens early blight susceptibility, while potassium and calcium strengthen epidermal defenses.",
            "recommendation": "Avoid excessive Nitrogen (N). Apply balanced Potassium (K) (e.g. Potassium Sulfate or Nitrate) and Calcium (Ca) to reinforce cell walls. Always conduct a standard soil test before major fertilizer applications. Note: Fertilizer does not cure existing fungal spots; it only aids plant systemic defense."
        },
        "prevention": [
            "Practice a 3-year crop rotation with non-solanaceous crops (maize, pulses, millets).",
            "Maintain wide plant spacing (60 cm x 45 cm) and stake tomato vines to ensure good canopy airflow.",
            "Use certified disease-free seeds or hot water seed treatment (50°C for 25 minutes).",
            "Deep summer plowing to bury previous crop residues."
        ],
        "when_to_seek_assistance": "Seek immediate help from the nearest Krishi Vigyan Kendra (KVK) or Block Horticulture Officer if spots spread above mid-canopy or appear on developing green fruit.",
        "sources": [
            "TNAU Agritech Portal: Crop Protection — Tomato Diseases (Early Blight)",
            "ICAR-IIHR Tomato Disease Management Manual, Bengaluru",
            "CIBRC Approved Major Uses of Pesticides (Tomato)"
        ],
        "reviewed_at": "2026-04-15"
    },
    "Tomato_Healthy": {
        "disease_id": "Tomato_Healthy",
        "crop": "Tomato",
        "common_name": "Healthy Tomato Foliage",
        "scientific_name": "Solanum lycopersicum L.",
        "pathogen_type": "None (Healthy)",
        "severity": "Optimal",
        "severity_level": "OPTIMAL",
        "explanation": "The foliage is in healthy condition with vibrant green pigmentation, uniform leaf turgidity, clean venation, and no signs of fungal, bacterial, or viral pathogens.",
        "symptoms": [
            "Uniform green leaf color without chlorosis, spots, or marginal scorch.",
            "Intact leaf margins and normal trichome (foliar hair) density.",
            "Normal stem thickness and vigorous apical shoot growth.",
            "Normal flower cluster development and fruit set."
        ],
        "causes": [
            "Good agricultural management, balanced nutrition, and optimal field sanitation."
        ],
        "spread_mechanism": "Not applicable.",
        "favorable_conditions": [
            "Optimal temperature (20°C–28°C), good soil aeration, balanced irrigation, and adequate sunlight."
        ],
        "immediate_actions": [
            "Continue routine twice-weekly field scouting (inspect leaf undersides for early pest/disease entry).",
            "Maintain steady irrigation scheduling according to crop evapotranspiration (ETc)."
        ],
        "treatment_options": {
            "cultural_and_biological": [
                "Maintain weed-free bunds and field borders.",
                "Periodically spray fermented Jeevamrutha or Panchagavya (3%) to enhance foliar phyllosphere immunity."
            ],
            "chemical_cibrc_approved": [],
            "safety_equipment": "Standard personal protective equipment during routine agricultural work."
        },
        "fertilizer_guidance": {
            "relevance": "Nutrient maintenance for ongoing growth stages.",
            "recommendation": "Follow stage-specific fertigation: vegetative stage requires balanced NPK (19:19:19); flowering/fruit set requires higher Potassium (13:0:45) and foliar Boron (0.1%) to prevent blossom drop."
        },
        "prevention": [
            "Avoid overhead irrigation; use drip system.",
            "Maintain yellow and blue sticky traps (10/acre) for early whitefly and thrips detection.",
            "Ensure field perimeter is free from solanaceous weed hosts."
        ],
        "when_to_seek_assistance": "Consult extension services if uncharacteristic leaf curl, yellowing, or abnormal wilting appears.",
        "sources": [
            "ICAR Package of Practices for Tomato Cultivation",
            "FAO Good Agricultural Practices (GAP) for Vegetable Production"
        ],
        "reviewed_at": "2026-04-15"
    },
    "Tomato_leaf_late_blight": {
        "disease_id": "Tomato_leaf_late_blight",
        "crop": "Tomato",
        "common_name": "Tomato Late Blight / Mahali Disease",
        "scientific_name": "Phytophthora infestans (Mont.) de Bary",
        "pathogen_type": "Oomycete (Water Mold)",
        "severity": "Critical",
        "severity_level": "CRITICAL",
        "explanation": "The most destructive tomato disease worldwide. Triggered by cool, damp weather, it causes rapidly expanding water-soaked greasy brown lesions on leaves and white frosty mold on leaf undersides, capable of killing an entire field in 7–10 days.",
        "symptoms": [
            "Irregular, water-soaked, pale green lesions rapidly turning into large dark brown or purplish-black greasy blotches.",
            "Delicate white, frosty downy mold visible on the underside of affected leaves during humid mornings.",
            "Dark brown, greasy water-soaked lesions on stems, causing vine collapse.",
            "Firm, greasy, olive-brown to dark lesions on green and ripening fruit, making them unmarketable."
        ],
        "causes": [
            "Airborne and waterborne sporangia of Phytophthora infestans.",
            "Contaminated seed tubers, volunteer tomato/potato plants, or infected cull piles in nearby fields."
        ],
        "spread_mechanism": "Extremely rapid airborne sporangia carried for miles on wind currents, followed by motile zoospores that swim in free water droplets on leaf surfaces.",
        "favorable_conditions": [
            "Cool to moderate temperatures (12°C–22°C).",
            "High relative humidity (>90%) with continuous fog, drizzling rain, or heavy morning dew.",
            "Dense canopy shading preventing leaf surfaces from drying."
        ],
        "immediate_actions": [
            "Immediately stop all irrigation until soil surface dries out completely.",
            "Carefully uproot and bag severely blighted plants; bury deep (>2 feet) or burn outside the field. Do NOT leave culled plants in open pits.",
            "Sanitize sprayers, boots, and cutting tools with 10% bleach solution between field rows."
        ],
        "treatment_options": {
            "cultural_and_biological": [
                "Remove volunteer potato or tomato plants within a 500-meter radius.",
                "Ensure rapid drainage; create raised beds and clear drainage furrows."
            ],
            "chemical_cibrc_approved": [
                {
                    "trade_category": "Translaminar / Systemic Oomycide",
                    "active_ingredient": "Cymoxanil 8% + Mancozeb 64% WP",
                    "dosage": "2.0 – 2.5 g per liter of water",
                    "usage_instructions": "Apply at the earliest sign of infection or when weather warnings predict persistent rain. Repeat at 7-day intervals.",
                    "phi_days": 10,
                    "rei_hours": 24,
                    "cibrc_registered": True
                },
                {
                    "trade_category": "Systemic Fungicide",
                    "active_ingredient": "Metalaxyl 8% + Mancozeb 64% WP",
                    "dosage": "2.5 g per liter of water",
                    "usage_instructions": "Curative systemic action. Do not exceed 2 sprays per season to prevent pathogen resistance.",
                    "phi_days": 10,
                    "rei_hours": 24,
                    "cibrc_registered": True
                },
                {
                    "trade_category": "Locally Systemic Fungicide",
                    "active_ingredient": "Dimethomorph 50% WP",
                    "dosage": "1.0 g per liter of water",
                    "usage_instructions": "Apply in combination with contact fungicide for anti-sporulant action.",
                    "phi_days": 10,
                    "rei_hours": 24,
                    "cibrc_registered": True
                }
            ],
            "safety_equipment": "Mandatory chemical-resistant gloves, full-sleeve protective clothing, goggles, and vapor/particulate respirator mask."
        },
        "fertilizer_guidance": {
            "relevance": "Critical. Heavy nitrogen fertilization produces soft, succulent tissues that accelerate Phytophthora entry.",
            "recommendation": "Immediately suspend nitrogen applications during active late blight weather. Apply foliar Potassium Phosphite to trigger systemic acquired resistance (SAR). Test soil before post-infection recovery fertilization."
        },
        "prevention": [
            "Plant certified late-blight tolerant hybrids (e.g. Arka Rakshak, Arka Abhed).",
            "Maintain wide row spacing (75 cm) and prune lower leaves up to 20 cm from ground level.",
            "Never cultivate tomatoes directly adjacent to potato fields.",
            "Apply prophylactic Mancozeb (2.0 g/L) before anticipated cold, rainy weather fronts."
        ],
        "when_to_seek_assistance": "URGENT: Report immediately to KVK or District Agricultural Officer; late blight requires coordinated regional community alerts to prevent valley-wide devastation.",
        "sources": [
            "ICAR-IIHR Tomato Disease Factsheets: Late Blight Management",
            "TNAU Agritech Portal: Crop Protection — Tomato Late Blight",
            "CIBRC Registered Fungicides for Phytophthora in Solanaceous Crops"
        ],
        "reviewed_at": "2026-04-15"
    },
    "Tomato_leaf_yellow_curl_virus": {
        "disease_id": "Tomato_leaf_yellow_curl_virus",
        "crop": "Tomato",
        "common_name": "Tomato Leaf Curl Virus (TYLCV)",
        "scientific_name": "Tomato leaf curl New Delhi virus / Begomovirus",
        "pathogen_type": "Viral (Whitefly Vector)",
        "severity": "High to Critical",
        "severity_level": "CRITICAL",
        "explanation": "A devastating viral disease transmitted by the sweetpotato whitefly (Bemisia tabaci). Causes severe upward leaf curling, yellowing of leaf margins, severe plant stunting, and flower drop, resulting in nearly 100% crop loss if contracted in early stages.",
        "symptoms": [
            "Pronounced upward curling and cupping of young apical leaves.",
            "Yellowing (chlorosis) along leaf margins and between veins, with veins remaining dark green.",
            "Marked stunting of plants with drastically shortened internodes, giving a bushy appearance.",
            "Leathery, thick, brittle leaf texture.",
            "Premature flower abortion and severely reduced fruit set; fruits that form remain small and unmarketable."
        ],
        "causes": [
            "Begomovirus infection transmitted exclusively by the insect vector Bemisia tabaci (whitefly).",
            "Not transmitted by seeds, soil, water, or mechanical leaf contact."
        ],
        "spread_mechanism": "Whiteflies feeding on infected hosts and transmitting the virus to healthy plants within 15–30 minutes of feeding.",
        "favorable_conditions": [
            "Warm, dry, sunny weather (28°C–38°C) that promotes rapid whitefly reproduction.",
            "Nearby infected crops (cotton, tobacco, chili, okra, cucurbits) or perennial weed hosts (Parthenium, Datura).",
            "Prolonged dry spells with low relative humidity."
        ],
        "immediate_actions": [
            "Roguing: Carefully pull up and burn severely stunted viral-infected plants to eliminate inoculum reservoirs. Place in closed bags before removal to prevent whiteflies from escaping.",
            "Install yellow sticky traps (15–20 traps per acre) at canopy height to capture adult whiteflies and monitor populations.",
            "Plant barrier crops (3–4 rows of maize, sorghum, or pearl millet) around the tomato field border to block incoming whitefly swarms."
        ],
        "treatment_options": {
            "cultural_and_biological": [
                "IMPORTANT: There is no chemical cure for viral infections inside the plant. Management focuses on whitefly vector suppression.",
                "Spray Neem Seed Kernel Extract (NSKE 5%) or Azadirachtin 10,000 ppm (2.0 ml/L) as an anti-ovipositional repellent.",
                "Conserve natural predators: release green lacewing larvae (Chrysoperla zastrowi) at 10,000 larvae per acre."
            ],
            "chemical_cibrc_approved": [
                {
                    "trade_category": "Systemic Neonicotinoid Insecticide",
                    "active_ingredient": "Imidacloprid 17.8% SL",
                    "dosage": "0.3 ml per liter of water",
                    "usage_instructions": "Spray on underside of foliage where whiteflies congregate. Rotate with different chemical classes to prevent resistance.",
                    "phi_days": 5,
                    "rei_hours": 24,
                    "cibrc_registered": True
                },
                {
                    "trade_category": "Systemic Insecticide",
                    "active_ingredient": "Thiamethoxam 25% WG",
                    "dosage": "0.4 g per liter of water",
                    "usage_instructions": "Foliar spray during early morning hours when whiteflies are sluggish on lower leaf surfaces.",
                    "phi_days": 5,
                    "rei_hours": 24,
                    "cibrc_registered": True
                },
                {
                    "trade_category": "Insect Growth Regulator / Acaricide",
                    "active_ingredient": "Diafenthiuron 50% WP",
                    "dosage": "1.0 g per liter of water",
                    "usage_instructions": "Effective on resistant whitefly nymphs and adults. Apply in alternating rotation.",
                    "phi_days": 7,
                    "rei_hours": 24,
                    "cibrc_registered": True
                }
            ],
            "safety_equipment": "Wear chemical-resistant gloves, protective clothing, and respirator mask when handling insecticides."
        },
        "fertilizer_guidance": {
            "relevance": "Nutritional management helps mildly affected border plants withstand viral stress.",
            "recommendation": "Spray micronutrient mixture containing Zinc (0.5%), Boron (0.2%), and Iron (0.5%) along with 1% Urea to reduce chlorotic stress. Avoid high doses of nitrogen alone, which attracts sap-sucking whitefly populations."
        },
        "prevention": [
            "Grow TYLCV-resistant F1 tomato hybrids (e.g. Arka Rakshak, Arka Abhed, US-440).",
            "Raise tomato nursery seedlings under 40-mesh insect-proof nylon netting for 25–30 days prior to transplanting.",
            "Eradicate Parthenium and weed hosts around field bunds.",
            "Apply silver reflective plastic mulch to disorient incoming whiteflies."
        ],
        "when_to_seek_assistance": "Consult a KVK entomologist if whitefly counts exceed the economic threshold level (ETL: >5 whiteflies per leaflet).",
        "sources": [
            "ICAR-IIHR Guidelines: Management of Tomato Leaf Curl Virus",
            "TNAU Agritech Portal: Tomato Pests and Vectors (Whitefly & TYLCV)",
            "CIBRC Approved Major Uses of Insecticides for Bemisia tabaci on Tomato"
        ],
        "reviewed_at": "2026-04-15"
    },
    "Tomato_mold_leaf": {
        "disease_id": "Tomato_mold_leaf",
        "crop": "Tomato",
        "common_name": "Tomato Leaf Mold",
        "scientific_name": "Passalora fulva (Cooke) U. Braun / Cladosporium fulvum",
        "pathogen_type": "Fungal",
        "severity": "Moderate",
        "severity_level": "MODERATE",
        "explanation": "A foliar fungal disease that thrives in high-humidity conditions (polyhouses, shaded fields, dense canopies). Pale greenish-yellow blotches form on upper leaf surfaces, while a velvety olive-green to brown mold forms directly beneath on the leaf underside.",
        "symptoms": [
            "Pale green to yellowish indistinct patches on the upper surface of older leaves.",
            "Dense, velvety olive-green to purplish-brown fungal sporulation developing directly on the underside of corresponding leaf lesions.",
            "Leaves curl, turn brown, wither, and drop prematurely as the mold spreads.",
            "In severe attacks, blossom clusters wither and drop, although fruit infection is uncommon."
        ],
        "causes": [
            "Fungal pathogen Passalora fulva surviving as conidia or sclerotia in crop residues, greenhouse structures, and contaminated seeds."
        ],
        "spread_mechanism": "Conidiospores easily dislodged and carried by gentle air currents, greenhouse ventilation drafts, rain splash, and handling wet plants.",
        "favorable_conditions": [
            "High relative humidity (>85%), especially in protected cultivation (polyhouses/net-houses).",
            "Temperatures between 21°C and 26°C.",
            "Poor air circulation within dense, unpruned plant canopies."
        ],
        "immediate_actions": [
            "Increase canopy ventilation immediately: prune lower suckers and dense inner foliage.",
            "Open greenhouse/polyhouse side vents to lower ambient relative humidity below 80%.",
            "Avoid late evening irrigation; water early in the morning so foliage dries quickly in the sun."
        ],
        "treatment_options": {
            "cultural_and_biological": [
                "Remove and burn severely molded lower leaves.",
                "Ensure proper row-to-row orientation (north-south) to maximize daily sun penetration."
            ],
            "chemical_cibrc_approved": [
                {
                    "trade_category": "Protective Copper Fungicide",
                    "active_ingredient": "Copper Oxychloride 50% WP",
                    "dosage": "2.5 g per liter of water",
                    "usage_instructions": "Spray thoroughly ensuring chemical reaches the underside of all leaves.",
                    "phi_days": 7,
                    "rei_hours": 24,
                    "cibrc_registered": True
                },
                {
                    "trade_category": "Systemic Fungicide",
                    "active_ingredient": "Difenoconazole 25% EC",
                    "dosage": "0.5 ml per liter of water",
                    "usage_instructions": "Curative spray on expanding lesions. Target lower leaf surface where spores reside.",
                    "phi_days": 7,
                    "rei_hours": 24,
                    "cibrc_registered": True
                },
                {
                    "trade_category": "Strobilurin Fungicide",
                    "active_ingredient": "Kresoxim-methyl 44.3% SC",
                    "dosage": "1.0 ml per liter of water",
                    "usage_instructions": "Excellent preventative and anti-sporulant action. Do not apply continuously.",
                    "phi_days": 5,
                    "rei_hours": 24,
                    "cibrc_registered": True
                }
            ],
            "safety_equipment": "Standard personal protective gear (gloves, eye protection, face mask)."
        },
        "fertilizer_guidance": {
            "relevance": "Nutrient balance influences foliage density and leaf cuticle thickness.",
            "recommendation": "Avoid high doses of nitrogen which create dense, humid microclimates within the canopy. Maintain adequate Potassium levels. Soil testing recommended."
        },
        "prevention": [
            "Grow tomato varieties carrying Cf resistance genes (Cf-2, Cf-4, Cf-9).",
            "Maintain wide plant spacing (60 cm x 50 cm).",
            "Sterilize greenhouse frames, stakes, and strings with 5% formalin between crop cycles."
        ],
        "when_to_seek_assistance": "Consult horticulture specialists if leaf mold persists despite polyhouse humidity reduction.",
        "sources": [
            "TNAU Crop Protection Guide: Tomato Leaf Mold (Passalora fulva)",
            "University of Florida IFAS Extension: Tomato Leaf Mold Management",
            "CIBRC Approved List of Fungicides for Solanaceous Vegetables"
        ],
        "reviewed_at": "2026-04-15"
    },
    "Tomato_septora_leaf_spot": {
        "disease_id": "Tomato_septora_leaf_spot",
        "crop": "Tomato",
        "common_name": "Tomato Septoria Leaf Spot",
        "scientific_name": "Septoria lycopersici Speg.",
        "pathogen_type": "Fungal",
        "severity": "Moderate to High",
        "severity_level": "MODERATE_HIGH",
        "explanation": "A destructive foliar fungal disease causing hundreds of tiny circular spots with dark brown margins and ash-grey centers containing tiny black dots. Progresses from bottom leaves upwards, causing heavy leaf loss and exposing tomatoes to sunburn.",
        "symptoms": [
            "Numerous small, circular spots (2–4 mm across) appearing on the lowest leaves first.",
            "Characteristic spots with dark brown borders and pale ash-grey or tan centers.",
            "Tiny black specks (pycnidia - fungal fruiting bodies) visible in the center of older spots with a magnifying lens.",
            "Yellowing (chlorosis) of the leaf tissue surrounding the spots, followed by drying and complete leaf drop.",
            "Severe defoliation leaving the plant with only top leaves, exposing fruit to sunscald."
        ],
        "causes": [
            "Septoria lycopersici surviving on solanaceous crop residues, weed hosts (Solanum nigrum), and volunteer plants."
        ],
        "spread_mechanism": "Fungal spores exuded in gelatinous tendrils and splashed by rain drops, overhead irrigation, and transferred by field workers handling wet foliage.",
        "favorable_conditions": [
            "Moderate temperatures (20°C–25°C).",
            "Frequent rainfall, persistent dew, and extended leaf wetness (>8–10 hours).",
            "High relative humidity (>80%)."
        ],
        "immediate_actions": [
            "Never cultivate, prune, or harvest in tomato fields when leaves are wet with dew or rain.",
            "Gently prune off and burn the lowest 3–4 infected leaves touching or near the soil.",
            "Lay down thick straw or plastic mulch around the plant base to create a physical barrier against soil-to-leaf water splashing."
        ],
        "treatment_options": {
            "cultural_and_biological": [
                "Seedling root dip in bio-agent Pseudomonas fluorescens (10 g/L) before transplanting.",
                "Spray neem oil formulation (3 ml/L) as a preventive botanical wash."
            ],
            "chemical_cibrc_approved": [
                {
                    "trade_category": "Contact Dithiocarbamate Fungicide",
                    "active_ingredient": "Mancozeb 75% WP",
                    "dosage": "2.0 – 2.5 g per liter of water",
                    "usage_instructions": "Start sprays when first spots appear on lower leaves. Repeat every 7–10 days during rainy periods.",
                    "phi_days": 7,
                    "rei_hours": 24,
                    "cibrc_registered": True
                },
                {
                    "trade_category": "Contact Protective Fungicide",
                    "active_ingredient": "Zineb 75% WP",
                    "dosage": "2.0 g per liter of water",
                    "usage_instructions": "Broad-spectrum foliar protective spray with good leaf adhesion.",
                    "phi_days": 7,
                    "rei_hours": 24,
                    "cibrc_registered": True
                },
                {
                    "trade_category": "Systemic Triazole Fungicide",
                    "active_ingredient": "Tebuconazole 25.9% EC",
                    "dosage": "1.0 ml per liter of water",
                    "usage_instructions": "Apply for curative translaminar action if infection spreads to mid-canopy.",
                    "phi_days": 7,
                    "rei_hours": 24,
                    "cibrc_registered": True
                }
            ],
            "safety_equipment": "Wear chemical-resistant gloves, protective clothing, and face mask during application."
        },
        "fertilizer_guidance": {
            "relevance": "Directly impacts canopy density and plant recovery capacity.",
            "recommendation": "Maintain balanced NPK and adequate Calcium. Avoid excess nitrogen which encourages dense, slowly-drying foliage. Soil testing recommended before applying fertilizers."
        },
        "prevention": [
            "Practice a 3-year crop rotation without solanaceous crops (tomatoes, potatoes, eggplants).",
            "Perform deep summer plowing to bury previous crop debris.",
            "Eradicate nightshade and solanaceous weeds along borders.",
            "Stake and trellis tomato plants to elevate foliage above wet soil."
        ],
        "when_to_seek_assistance": "Seek help from KVK or Agricultural Extension if defoliation reaches the middle canopy before fruit harvest.",
        "sources": [
            "TNAU Agritech Portal: Crop Protection — Tomato Septoria Leaf Spot",
            "ICAR-IIHR Bengaluru: Vegetable Pathology Technical Bulletin",
            "CIBRC Approved Pesticides for Septoria on Solanaceous Crops"
        ],
        "reviewed_at": "2026-04-15"
    }
}

def get_advisory_for_disease(disease_name: str) -> dict:
    """Retrieve verified advisory profile by disease name, or return general solanaceous guidance."""
    return ADVISORY_KNOWLEDGE_BASE.get(disease_name, {
        "disease_id": disease_name,
        "crop": "Tomato",
        "common_name": disease_name.replace("_", " "),
        "scientific_name": "Unspecified / Solanum lycopersicum pathogen",
        "pathogen_type": "Unspecified",
        "severity": "Unknown",
        "severity_level": "UNKNOWN",
        "explanation": "No specific advisory profile found for this classification. Consult your local agricultural officer.",
        "symptoms": ["Unspecified leaf abnormalities."],
        "causes": ["Unspecified causal agent."],
        "spread_mechanism": "Variable.",
        "favorable_conditions": ["General solanaceous stress conditions."],
        "immediate_actions": ["Isolate affected plant", "Take clear closeup photo of top and underside of leaf"],
        "treatment_options": {"cultural_and_biological": [], "chemical_cibrc_approved": [], "safety_equipment": "Standard PPE."},
        "fertilizer_guidance": {"relevance": "General", "recommendation": "Maintain balanced NPK nutrition."},
        "prevention": ["Crop rotation", "Drip irrigation"],
        "when_to_seek_assistance": "Contact local KVK.",
        "sources": ["General Plant Pathology Guidelines"],
        "reviewed_at": "2026-04-15"
    })

