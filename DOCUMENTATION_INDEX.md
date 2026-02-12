# 📚 Complete Documentation Index

## 🎯 Start Here

### For Quick Setup (5 minutes)
👉 **Read**: `README_QUICK.md`
- One-page reference
- Installation
- Running the system
- Quick tests

### For Detailed Setup (15 minutes)
👉 **Read**: `QUICK_START_REFERENCE.md`
- All dependencies explained
- Architecture diagram
- Running options (local/EC2)
- Troubleshooting

### For Complete Guide (30 minutes)
👉 **Read**: `SETUP_AND_RUN_GUIDE.md`
- Full system architecture
- Detailed troubleshooting
- Performance metrics
- Verification checklist

---

## 📋 Dependencies Explained

### What You Need to Install

```
9 Python packages total (~1.4GB)
```

**Core Dependencies:**
- `streamlit` - Web interface
- `fastapi` - Backend API
- `uvicorn` - Web server
- `pandas` - Handle CSV data
- `requests` - HTTP calls

**AI & Search Dependencies:**
- `google-generativeai` - Gemini API for answers
- `sentence-transformers` - ML embeddings for semantic search ⭐
- `scikit-learn` - ML calculations for similarity ⭐
- `markdown` - Text formatting

**⭐ = Essential for semantic search to work**

### Installation

```bash
# Simple (recommended)
pip install -r requirements.txt

# Save disk (EC2)
pip install --no-cache-dir -r requirements.txt

# Step by step
pip install streamlit fastapi uvicorn pandas requests markdown
pip install google-generativeai sentence-transformers scikit-learn
```

**Time**: 5-10 minutes on first install  
**Space**: ~1.4GB total

---

## 🚀 Running the System (4 Steps)

### Step 1: Install Dependencies
```bash
pip install -r requirements.txt
```

### Step 2: Get Gemini API Key (Free)
```
Website: https://makersuite.google.com/app/apikey
Action: Copy your free API key
```

### Step 3: Set API Key
```bash
export GOOGLE_API_KEY="your-api-key-from-above"
```

### Step 4: Start Services

**Terminal 1 (Backend)**
```bash
cd /path/to/consultancy_AI_agent
python3 app/cloud_server.py
```

**Terminal 2 (Frontend)**
```bash
cd /path/to/consultancy_AI_agent
streamlit run app/ui.py
```

### Step 5: Open in Browser
```
http://localhost:8501
```

---

## ✅ Testing the System

### Test 1: Packages Installed?
```bash
python3 -c "
from sentence_transformers import SentenceTransformer
from sklearn.metrics.pairwise import cosine_similarity
import pandas, requests
print('✅ All packages OK!')
"
```

### Test 2: Backend Running?
```bash
curl http://localhost:8000/docs
# Should show API documentation
```

### Test 3: Search Working?
```bash
curl -X POST http://localhost:8000/search \
  -H "Content-Type: application/json" \
  -d '{"query": "foundation problems", "top_k": 3}'
```

Look for in response:
- ✅ `"search_method": "semantic"`
- ✅ `"best_score": 0.75+`

### Test 4: Web UI Working?
1. Open http://localhost:8501
2. Type: "What are foundation issues?"
3. Click search
4. See results

---

## 🏗️ System Architecture

```
┌──────────────────────────────────┐
│    STREAMLIT WEB UI (8501)       │
│  - ChatGPT-like interface        │
│  - Case search                   │
│  - AI chat                       │
└────────────┬──────────────────────┘
             │ HTTP requests
             ↓
┌──────────────────────────────────┐
│    FASTAPI BACKEND (8000)        │
│  - /search endpoint              │
│  - /chat endpoint                │
│  - /docs (Swagger)               │
└────────────┬──────────────────────┘
             │
    ┌────────┼────────┐
    ↓        ↓        ↓
 ┌─────┐  ┌──────┐  ┌────────┐
 │CSV  │  │ML    │  │Gemini  │
 │Data │  │Models│  │API     │
 └─────┘  └──────┘  └────────┘
```

---

## 📁 Project Files

### Core Application
- `app/cloud_server.py` - FastAPI backend
- `app/ui.py` - Streamlit frontend
- `app/semantic_search.py` - Embedding-based search
- `app/fallback_search.py` - Keyword backup search

### Data
- `data/cases.csv` - Construction cases database

### Configuration
- `requirements.txt` - Python dependencies
- `docker-compose.yml` - Docker deployment

### Documentation
- `README_QUICK.md` - One-page quick start ⭐
- `QUICK_START_REFERENCE.md` - Full reference guide
- `SETUP_AND_RUN_GUIDE.md` - Detailed documentation
- `SYSTEM_SUMMARY.md` - System overview
- `EC2_DISK_CLEANUP_GUIDE.md` - EC2 optimization

### Scripts
- `quick_start.sh` - Interactive setup wizard
- `ec2_*.sh` - EC2 cleanup scripts

---

## 🎯 Common Tasks

### Task 1: Install Everything
```bash
pip install -r requirements.txt
```

### Task 2: Test Search Engine
```bash
python3 app/cloud_server.py &
sleep 3
curl -X POST http://localhost:8000/search \
  -H "Content-Type: application/json" \
  -d '{"query": "foundation damage", "top_k": 5}'
```

### Task 3: Run Full System
```bash
# Terminal 1
export GOOGLE_API_KEY="your-key"
python3 app/cloud_server.py

# Terminal 2
streamlit run app/ui.py
```

### Task 4: Deploy to EC2
```bash
# Install
pip install --no-cache-dir -r requirements.txt

# Run background
export GOOGLE_API_KEY="your-key"
nohup python3 app/cloud_server.py > backend.log 2>&1 &
nohup streamlit run app/ui.py --server.port 8501 > frontend.log 2>&1 &

# View at http://your-ec2-ip:8501
```

### Task 5: Clean EC2 Disk
```bash
# See documentation
bash ec2_analyze_and_cleanup.sh
```

---

## ⚡ Performance

| Operation | Duration | Notes |
|-----------|----------|-------|
| First startup | 30-60 seconds | Downloads ML model |
| Second startup | 5-10 seconds | Uses cache |
| Semantic search | 100-200ms | Very fast |
| Gemini API call | 2-5 seconds | Network dependent |
| Total (search + answer) | 3-7 seconds | End-to-end |

---

## 🔧 Troubleshooting

### Issue: "Module not found"
**Cause**: Package not installed  
**Fix**: `pip install -r requirements.txt`

### Issue: "GOOGLE_API_KEY not set"
**Cause**: Missing API key  
**Fix**: `export GOOGLE_API_KEY="your-key"`

### Issue: "Port 8000 already in use"
**Cause**: Backend running twice  
**Fix**: `lsof -i :8000` then `kill -9 <PID>`

### Issue: "No space left on device" (EC2)
**Cause**: Disk full  
**Fix**: Run cleanup scripts or increase EBS volume

### Issue: "Slow first search"
**Cause**: Downloading ML models  
**Fix**: Normal - be patient, it's cached after

### Issue: "No search results"
**Cause**: Data file missing  
**Fix**: Check `data/cases.csv` exists

### Issue: Frontend can't connect to backend
**Cause**: Backend not running  
**Fix**: Start backend first: `python3 app/cloud_server.py`

---

## 📞 Support Resources

### Documentation
- 📖 `README_QUICK.md` - Quick start
- 📖 `SETUP_AND_RUN_GUIDE.md` - Full guide
- 📖 `EC2_DISK_CLEANUP_GUIDE.md` - EC2 help

### Check Logs
```bash
# Backend logs
tail -50 backend.log

# Frontend logs  
tail -50 frontend.log

# System errors
journalctl -xe
```

### API Documentation
```
http://localhost:8000/docs
```
Swagger interactive documentation

---

## ✅ Verification Checklist

Before using the system:

- [ ] Python 3.8+ installed
- [ ] All 9 packages installed (`pip list`)
- [ ] 2GB+ disk space available
- [ ] Gemini API key obtained
- [ ] API key set in terminal
- [ ] `data/cases.csv` exists
- [ ] Backend starts without errors
- [ ] Frontend starts without errors
- [ ] Can access http://localhost:8501
- [ ] Search returns results

---

## 🎓 What You're Using

### Semantic Search (AI-Powered)
- Uses `sentence-transformers` to convert text to embeddings
- Compares embeddings using cosine similarity from `scikit-learn`
- Finds contextually similar cases (not just keyword matches)
- Example: "foundation problems" finds cases about "structural settlement"

### AI Answers
- Uses Gemini API to generate intelligent responses
- Combines search results with AI reasoning
- Provides context-aware answers

### Fallback Search
- Keyword-based search when semantic fails
- Doesn't require internet
- Fast but less intelligent

---

## 🚀 Next Steps

1. ✅ **Install**: `pip install -r requirements.txt`
2. ✅ **API Key**: https://makersuite.google.com/app/apikey
3. ✅ **Set Key**: `export GOOGLE_API_KEY="your-key"`
4. ✅ **Run Backend**: `python3 app/cloud_server.py`
5. ✅ **Run Frontend**: `streamlit run app/ui.py`
6. ✅ **Open**: http://localhost:8501
7. ✅ **Ask Questions!** 🎉

---

## 📞 Quick Help

**Forgot API key?** → https://makersuite.google.com/app/apikey  
**Need help?** → Check `SETUP_AND_RUN_GUIDE.md`  
**Disk full?** → Run `ec2_analyze_and_cleanup.sh`  
**API docs?** → Open http://localhost:8000/docs  

---

**Everything is ready. You can start now!** 🚀
