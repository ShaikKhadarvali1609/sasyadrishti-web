# SasyaDrishti

AI‑powered Smart Agriculture Decision Support System.

## Project Structure
```
SasyaDrishti/
├─ mobile/                # Flutter Android app
├─ backend/               # FastAPI server
│   ├─ venv/               # Python virtual env (not committed)
│   ├─ app/
│   │   └─ main.py
│   └─ requirements.txt
├─ ml/                     # Machine‑learning modules (future work)
├─ datasets/               # Demo datasets (licensed, labelled)
├─ research/               # Experiments, notebooks, results
├─ docs/
│   ├─ ARCHITECTURE.md
│   └─ DEVELOPMENT_ROADMAP.md
└─ scripts/                # Helper scripts
```

## Getting Started
### Mobile (Flutter)
```bash
cd mobile
flutter pub get
flutter run   # launches the Android app
```

### Backend (FastAPI)
```bash
cd backend
python -m venv venv
# Activate the venv (PowerShell)
& .\venv\Scripts\Activate.ps1
pip install -r requirements.txt
uvicorn app.main:app --reload
```
The API is reachable at `http://127.0.0.1:8000` and Swagger UI at `http://127.0.0.1:8000/docs`.

## Development Guidelines
- Keep secrets (API keys, DB passwords) out of source control – use `.env` files ignored by git.
- Offline functionality is a core requirement; all critical data is cached locally.
- Follow the folder conventions; avoid adding unrelated files.
- Do **not** download large datasets or train models until a later milestone.

