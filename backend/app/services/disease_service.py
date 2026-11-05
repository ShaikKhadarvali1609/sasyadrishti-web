import os
import base64
import io
import logging
import threading
from typing import List, Optional

import torch
import torch.nn as nn
from torchvision import transforms, models
from PIL import Image, UnidentifiedImageError

logger = logging.getLogger("sasyadrishti.ml")

# Prevent decompression bombs
Image.MAX_IMAGE_PIXELS = 10_000_000  # Max 10 megapixels
MAX_IMAGE_BYTES = 8 * 1024 * 1024     # Max 8 MB decoded byte size
MAX_DIMENSION = 4096                  # Max width or height

# Bounded concurrency for CPU-based inference: allows 2 parallel inferences to protect container CPU
_INFERENCE_SEMAPHORE = threading.Semaphore(2)

_MODEL = None
_CLASS_NAMES = None
_CONFIDENCE_THRESHOLD = float(os.getenv("CONFIDENCE_THRESHOLD", "0.6"))

_BASE_DIR = os.path.dirname(os.path.abspath(__file__))
_CANDIDATE_PATHS = [
    os.path.normpath(os.path.join(_BASE_DIR, "..", "..", "models", "tomato_model.pth")),
    os.path.normpath(os.path.join(_BASE_DIR, "..", "..", "..", "backend", "models", "tomato_model.pth")),
    os.path.normpath(os.path.join(_BASE_DIR, "..", "..", "..", "models", "tomato_model.pth")),
    os.path.abspath("backend/models/tomato_model.pth"),
    os.path.abspath("models/tomato_model.pth"),
]

_MODEL_PATH = None
for p in _CANDIDATE_PATHS:
    if os.path.exists(p):
        _MODEL_PATH = p
        break

if _MODEL_PATH is None:
    _MODEL_PATH = _CANDIDATE_PATHS[0]

def _load_model() -> bool:
    global _MODEL, _CLASS_NAMES
    if not os.path.exists(_MODEL_PATH):
        logger.warning(f"Tomato model checkpoint not found at: {_MODEL_PATH}")
        return False
    try:
        model = models.mobilenet_v3_small(weights=None)
        num_features = model.classifier[3].in_features
        model.classifier[3] = nn.Linear(num_features, 6)
        checkpoint = torch.load(_MODEL_PATH, map_location=torch.device('cpu'))
        model.load_state_dict(checkpoint['model_state_dict'])
        _CLASS_NAMES = checkpoint.get('class_names')
        model.eval()
        _MODEL = model
        logger.info(f"Loaded MobileNetV3-Small checkpoint from {_MODEL_PATH} ({len(_CLASS_NAMES or [])} classes).")
        return True
    except Exception as e:
        logger.error(f"Error loading model from {_MODEL_PATH}: {e}")
        return False

# Initialize on import
_loaded = _load_model()

def is_model_ready() -> bool:
    """Return True if the MobileNetV3-Small model is loaded and ready for inference."""
    return _loaded and _MODEL is not None

# Preprocessing transforms (ImageNet standard matching training)
_preprocess = transforms.Compose([
    transforms.Resize((224, 224)),
    transforms.ToTensor(),
    transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]),
])

def predict(crop: str, image_base64: str) -> dict:
    if not is_model_ready():
        return {"status": "MODEL_NOT_READY", "message": "Model file missing or failed to load."}
    if crop.lower() != "tomato":
        return {"status": "INVALID_CROP", "message": f"Unsupported crop '{crop}'. Only 'tomato' is supported."}
    
    # 1. Payload size guard
    if len(image_base64) > 12 * 1024 * 1024:  # ~9 MB base64 limit
        return {"status": "INVALID_IMAGE", "message": "Image payload exceeds maximum allowed size (8 MB)."}

    try:
        img_bytes = base64.b64decode(image_base64)
    except Exception:
        return {"status": "INVALID_IMAGE", "message": "Invalid base64 encoding."}

    if len(img_bytes) > MAX_IMAGE_BYTES:
        return {"status": "INVALID_IMAGE", "message": "Decoded image size exceeds 8 MB."}

    # 2. Image format and dimensions validation
    try:
        img = Image.open(io.BytesIO(img_bytes))
        img.verify()  # Verify integrity without fully decoding
        img = Image.open(io.BytesIO(img_bytes))  # Re-open after verify
    except (UnidentifiedImageError, Exception) as e:
        logger.warning(f"Invalid image uploaded: {e}")
        return {"status": "INVALID_IMAGE", "message": "Corrupted or unsupported image file format."}

    if img.format not in {"JPEG", "JPG", "PNG", "WEBP"}:
        return {"status": "INVALID_IMAGE", "message": f"Unsupported image format '{img.format}'. Expected JPEG, PNG, or WEBP."}

    width, height = img.size
    if width > MAX_DIMENSION or height > MAX_DIMENSION:
        return {"status": "INVALID_IMAGE", "message": f"Image dimensions ({width}x{height}) exceed maximum allowed limit of {MAX_DIMENSION}px."}

    img_rgb = img.convert('RGB')

    # 3. Controlled CPU inference with bounded concurrency
    acquired = _INFERENCE_SEMAPHORE.acquire(timeout=10.0)
    if not acquired:
        return {"status": "ERROR", "message": "Inference server is currently at maximum capacity. Please retry shortly."}

    try:
        input_tensor = _preprocess(img_rgb).unsqueeze(0)
        with torch.inference_mode():
            logits = _MODEL(input_tensor)
            probs = torch.nn.functional.softmax(logits, dim=1)[0]
        confidence, pred_idx = torch.max(probs, dim=0)
        confidence_val = confidence.item()
        pred_idx_val = pred_idx.item()
        class_name = _CLASS_NAMES[pred_idx_val] if _CLASS_NAMES else str(pred_idx_val)

        result = {
            "status": "SUCCESS",
            "prediction": class_name,
            "confidence": confidence_val,
            "probabilities": probs.tolist(),
            "class_names": _CLASS_NAMES,
        }
        if confidence_val < _CONFIDENCE_THRESHOLD:
            result["status"] = "UNCERTAIN"
            result["message"] = f"Low confidence ({confidence_val:.2f})"
        return result
    except Exception as e:
        logger.error(f"Inference execution failed: {e}")
        return {"status": "ERROR", "message": "Inference execution error."}
    finally:
        _INFERENCE_SEMAPHORE.release()
