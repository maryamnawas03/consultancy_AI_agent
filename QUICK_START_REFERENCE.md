# 🚀 Quick Reference: Dependencies & Running the Agent

## TL;DR (Just tell me what to do!)

### 1. Install Dependencies (5 minutes)
```bash
cd /path/to/consultancy_AI_agent
pip install -r requirements.txt
```

### 2. Get Gemini API Key (2 minutes)
```bash
# Go to: https://makersuite.google.com/app/apikey
# Copy your free API key

# Set it in terminal:
export GOOGLE_API_KEY="your-key-from-above"
```

### 3. Start the System (2 options)

**Option A: Easy way (interactive setup)**
```bash
chmod +x quick_start.sh
./quick_start.sh
```

**Option B: Manual way**
```bash
# Terminal 1: Start Backend
cd /path/to/consultancy_AI_agent
export GOOGLE_API_KEY="your-key"
python3 app/cloud_server.py

# Terminal 2: Start Frontend (NEW TERMINAL)
cd /path/to/consultancy_AI_agent
streamlit run app/ui.py
```

### 4. Open in Browser
- **UI**: http://localhost:8501
- **API Docs**: http://localhost:8000/docs

### 5. Test It
Type a question like:
- "What are common foundation issues?"
- "Tell me about water damage cases"
- "How do you fix concrete cracks?"

---

## Dependencies Overview

```
Required Packages (9 total):
├── streamlit          → Beautiful web UI
├── fastapi            → Fast backend API
├── uvicorn            → Web server
├── pandas             → Handle CSV data
├── requests           → HTTP calls
├── google-generativeai → Gemini AI API
├── sentence-transformers → Semantic search (ML embeddings)
├── scikit-learn       → ML calculations (similarity)
└── markdown           → Text formatting
```

**Total Install Size**: ~1.4GB (first time)
**Installation Time**: 5-10 minutes

---

## Installation Methods

### Method 1: Simple (Recommended)
```bash
pip install -r requirements.txt
```

### Method 2: Save Disk Space (EC2)
```bash
pip install --no-cache-dir -r requirements.txt
```

### Method 3: Step-by-Step (Debugging)
```bash
pip install streamlit>=1.29.0
pip install fastapi>=0.104.0
pip install uvicorn>=0.24.0
pip install pandas>=1.5.0
pip install requests>=2.28.0
pip install google-generativeai>=0.8.0
pip install sentence-transformers>=2.2.0
pip install scikit-learn>=1.3.0
pip install markdown>=3.4.0
```

---

## Verify Installation

```bash
python3 -c "
from sentence_transformers import SentenceTransformer
from sklearn.metrics.pairwise import cosine_similarity
import pandas, requests, streamlit, fastapi
print('✅ All dependencies installed!')
"
```

---

## System Architecture

```
┌─────────────────────────┐
│   Streamlit UI (8501)   │
│  - Chat interface       │
│  - View results         │
└────────────┬────────────┘
             │ HTTP
             ↓
┌─────────────────────────┐
│  FastAPI Backend (8000) │
│  - Search endpoint      │
│  - Chat endpoint        │
│  - Gemini integration   │
└────────────┬────────────┘
             │
   ┌─────────┼─────────┐
   ↓         ↓         ↓
 CSV    Embeddings   Gemini
 Data    (Cache)     API
```

---

## Running the Agent

### Local Development (Laptop/Desktop)

**Start Backend** (Terminal 1):
```bash
cd /path/to/consultancy_AI_agent
export GOOGLE_API_KEY="your-key"
python3 app/cloud_server.py
```

Expected output:
```
🔄 Loading semantic search model: all-MiniLM-L6-v2
✅ Model loaded: all-MiniLM-L6-v2
INFO:     Uvicorn running on http://0.0.0.0:8000
```

**Start Frontend** (Terminal 2):
```bash
cd /path/to/consultancy_AI_agent
streamlit run app/ui.py
```

Expected output:
```
You can now view your Streamlit app in your browser.
URL: http://localhost:8501
```

---

### Production on EC2

**Connect to EC2:**
```bash
ssh -i /path/to/key.pem ec2-user@your-ec2-ip
cd /home/ec2-user/consultancy_AI_agent
export GOOGLE_API_KEY="your-key"
```

**Start in Background:**
```bash
# Backend
nohup python3 app/cloud_server.py > backend.log 2>&1 &

# Frontend
nohup streamlit run app/ui.py --server.port 8501 > frontend.log 2>&1 &

# Verify running
ps aux | grep -E "cloud_server|streamlit"
```

**Access from anywhere:**
- Replace `localhost` with your EC2 public IP
- Example: `http://54.123.45.67:8501`

---

## Testing the System

### Test 1: Check Backend is Running
```bash
curl http://localhost:8000/docs
# Should show Swagger API documentation
```

### Test 2: Test Semantic Search
```bash
curl -X POST http://localhost:8000/search \
  -H "Content-Type: application/json" \
  -d '{"query": "foundation problems", "top_k": 3}'
```

Look for:
- `"search_method": "semantic"` ✅
- `"best_score": 0.75+` ✅

### Test 3: Test Chat
```bash
curl -X POST http://localhost:8000/chat \
  -H "Content-Type: application/json" \
  -d '{
    "session_id": "test",
    "message": "What are foundation issues?"
  }'
```

### Test 4: Web Interface
Open: http://localhost:8501
1. Type a question
2. Click "Search Cases" 
3. See results below
4. Click "Ask AI" to get answer

---

## Common Issues & Fixes

| Issue | Cause | Fix |
|-------|-------|-----|
| "Module not found" | Missing packages | `pip install -r requirements.txt` |
| "No space left" | Disk full | Run cleanup scripts |
| "API key not set" | Missing Gemini key | `export GOOGLE_API_KEY="your-key"` |
| Port 8000 in use | Backend running twice | `lsof -i :8000` then kill |
| Slow first search | Downloading ML model | Normal (~5min), then cached |
| No results | Data file missing | Check `data/cases.csv` exists |
| UI won't connect | Backend not running | Check backend logs |

---

## What Each File Does

### Core Files
| File | Purpose |
|------|---------|
| `app/cloud_server.py` | FastAPI backend (REST API) |
| `app/ui.py` | Streamlit frontend (web UI) |
| `app/semantic_search.py` | Embedding-based search engine |
| `app/fallback_search.py` | Keyword fallback search |
| `data/cases.csv` | Construction case database |
| `requirements.txt` | Python dependencies |

### Helper Scripts
| Script | Purpose |
|--------|---------|
| `quick_start.sh` | Interactive setup wizard |
| `ec2_*.sh` | EC2 disk cleanup scripts |
| `EC2_DISK_CLEANUP_GUIDE.md` | Disk space management |
| `SETUP_AND_RUN_GUIDE.md` | Detailed documentation |

---

## Performance Expectations

| Operation | Time | Notes |
|-----------|------|-------|
| First startup | 30-60s | Downloads 400MB ML model |
| Second+ startup | 5-10s | Uses cached model |
| Search query | 100-200ms | Very fast |
| AI response | 2-5s | Network dependent |
| Total (search + AI) | 3-7s | End-to-end |

---

## Next Steps

1. ✅ Run: `pip install -r requirements.txt`
2. ✅ Get API key: https://makersuite.google.com/app/apikey
3. ✅ Set it: `export GOOGLE_API_KEY="your-key"`
4. ✅ Start: `python3 app/cloud_server.py` (terminal 1)
5. ✅ Start: `streamlit run app/ui.py` (terminal 2)
6. ✅ Open: http://localhost:8501
7. ✅ Ask questions!

---

## For EC2 Deployment

See: `DEPLOY_EC2_NOW.md` or `EC2_DISK_CLEANUP_GUIDE.md`

---

**Questions?** Check `SETUP_AND_RUN_GUIDE.md` for detailed troubleshooting!
