# 📦 Complete Summary: Dependencies & How to Run

## 🎯 TL;DR (Too Long; Didn't Read)

```bash
# 1. Install
pip install -r requirements.txt

# 2. Get key at https://makersuite.google.com/app/apikey

# 3. Set key
export GOOGLE_API_KEY="your-key"

# 4. Terminal 1
python3 app/cloud_server.py

# 5. Terminal 2
streamlit run app/ui.py

# 6. Open http://localhost:8501
```

---

## 📋 DEPENDENCIES (What You're Installing)

### The 9 Packages

```
1. streamlit (v1.29+)          - Web UI framework (200MB)
2. fastapi (v0.104+)           - REST API (50MB)
3. uvicorn (v0.24+)            - Web server (20MB)
4. pandas (v1.5+)              - CSV data handling (300MB)
5. requests (v2.28+)           - HTTP client (10MB)
6. google-generativeai (v0.8+) - Gemini AI API (50MB)
7. sentence-transformers (v2.2+) - AI EMBEDDINGS ⭐ (500MB)
8. scikit-learn (v1.3+)        - ML ALGORITHMS ⭐ (300MB)
9. markdown (v3.4+)            - Markdown processing (5MB)

Total: ~1.4GB
Time: 5-10 minutes
```

### What Each Does

| Package | Purpose | Why Needed |
|---------|---------|-----------|
| **streamlit** | Creates beautiful web interface | UI framework |
| **fastapi** | Creates REST API backend | Backend server |
| **uvicorn** | Runs FastAPI server | Web server |
| **pandas** | Reads cases.csv file | Data handling |
| **requests** | Makes HTTP requests | Client library |
| **google-generativeai** | Calls Gemini AI API | AI answers |
| **sentence-transformers** | Creates embeddings from text | **AI-powered search** ⭐ |
| **scikit-learn** | Calculates similarity scores | **ML matching** ⭐ |
| **markdown** | Formats markdown text | Text processing |

---

## 🚀 HOW TO INSTALL

### Option 1: Simple (Recommended)
```bash
pip install -r requirements.txt
```

### Option 2: Save Disk Space (EC2)
```bash
pip install --no-cache-dir -r requirements.txt
```

### Option 3: Step by Step (Debugging)
```bash
pip install streamlit
pip install fastapi
pip install uvicorn
pip install pandas
pip install requests
pip install markdown
pip install google-generativeai
pip install scikit-learn
pip install sentence-transformers
```

---

## ✅ VERIFY INSTALLATION

```bash
python3 -c "
import streamlit
import fastapi
import pandas
import requests
import markdown
import google.generativeai
from sentence_transformers import SentenceTransformer
from sklearn.metrics.pairwise import cosine_similarity
print('✅ All packages installed!')
"
```

---

## 🔧 CONFIGURATION

### 1. Get Gemini API Key

**Step 1:** Go to https://makersuite.google.com/app/apikey  
**Step 2:** Click "Create API Key"  
**Step 3:** Copy the key  
**Step 4:** Keep it secret!

### 2. Set Environment Variable

```bash
export GOOGLE_API_KEY="your-api-key-from-above"
```

**To make it permanent, add to ~/.bashrc:**
```bash
echo 'export GOOGLE_API_KEY="your-api-key"' >> ~/.bashrc
source ~/.bashrc
```

### 3. Verify Data File

```bash
ls -la data/cases.csv
# Should show the file exists
```

---

## 🎯 HOW TO RUN THE SYSTEM

### Architecture

```
User asks question
        ↓
    Streamlit UI (Port 8501)
        ↓
    FastAPI Backend (Port 8000)
        ├── Semantic Search (AI embeddings)
        ├── Fallback Keyword Search
        └── Gemini API for answers
        ↓
    Results + AI Answer
```

### Start Backend (Terminal 1)

```bash
cd /path/to/consultancy_AI_agent
export GOOGLE_API_KEY="your-key"
python3 app/cloud_server.py
```

**Expected Output:**
```
🔄 Loading semantic search model: all-MiniLM-L6-v2
✅ Model loaded: all-MiniLM-L6-v2
📦 Loading cached embeddings from data/embeddings_all-MiniLM-L6-v2.pkl
✅ Loaded 47 cached embeddings
INFO:     Uvicorn running on http://0.0.0.0:8000
```

### Start Frontend (Terminal 2 - NEW TERMINAL)

```bash
cd /path/to/consultancy_AI_agent
streamlit run app/ui.py
```

**Expected Output:**
```
You can now view your Streamlit app in your browser.
URL: http://localhost:8501
```

### Access the System

**Web Interface:**
- Open: http://localhost:8501

**API Docs:**
- Open: http://localhost:8000/docs (Swagger)

---

## 🧪 TESTING THE SYSTEM

### Test 1: Check Backend is Running
```bash
curl http://localhost:8000/docs
# Should return HTML with API documentation
```

### Test 2: Test Semantic Search
```bash
curl -X POST http://localhost:8000/search \
  -H "Content-Type: application/json" \
  -d '{
    "query": "foundation problems",
    "top_k": 3
  }'
```

**Look for in response:**
- ✅ `"search_method": "semantic"` (not "keyword")
- ✅ `"best_score": 0.75+` (high confidence)
- ✅ Case results with high similarity

### Test 3: Test Chat with AI
```bash
curl -X POST http://localhost:8000/chat \
  -H "Content-Type: application/json" \
  -d '{
    "session_id": "test",
    "message": "What are foundation issues?"
  }'
```

**Look for:**
- ✅ `"answer": "..."` (AI response)
- ✅ `"sources": [...]` (case references)
- ✅ `"best_score": 0.75+`

### Test 4: Use Web Interface
1. Open http://localhost:8501
2. Type a question: "Tell me about water damage"
3. Click "Search Cases"
4. See results appear
5. Click "Ask AI"
6. Get AI-powered answer

---

## ⚡ PERFORMANCE EXPECTATIONS

| Stage | Time | Note |
|-------|------|------|
| First backend startup | 30-60s | Downloads 400MB ML model |
| First frontend startup | 10-15s | Loads UI |
| Second startup | 5-10s | Uses cached models |
| Semantic search | 100-200ms | Lightning fast |
| Gemini API call | 2-5s | Network dependent |
| Total per query | 3-7s | End-to-end |

---

## 🆘 TROUBLESHOOTING

### Issue: "ModuleNotFoundError: No module named 'X'"
```bash
# Solution: Install missing package
pip install -r requirements.txt
```

### Issue: "GOOGLE_API_KEY not set"
```bash
# Solution: Set the environment variable
export GOOGLE_API_KEY="your-api-key"
```

### Issue: "Address already in use" for port 8000
```bash
# Find what's using port 8000
lsof -i :8000

# Kill it (replace PID with actual PID)
kill -9 <PID>

# Then restart the backend
python3 app/cloud_server.py
```

### Issue: "No space left on device" (EC2)
```bash
# Run cleanup script
bash ec2_analyze_and_cleanup.sh
```

### Issue: First search is very slow
**This is normal!** The ML model is downloading (~400MB).
Wait 5-10 minutes for first search, then it's cached and fast.

### Issue: "Frontend can't connect to backend"
**Make sure:**
1. Terminal 1 shows: `INFO:     Uvicorn running on http://0.0.0.0:8000`
2. Backend is fully started (wait 10-15 seconds)
3. Try refreshing browser

### Issue: No search results
**Check:**
1. Data file exists: `ls -la data/cases.csv`
2. CSV has correct columns: `head data/cases.csv`
3. Backend logs for errors

---

## 📁 PROJECT FILES

### Core Application
```
app/
├── cloud_server.py          ← FastAPI backend
├── ui.py                    ← Streamlit frontend
├── semantic_search.py       ← AI search engine
└── fallback_search.py       ← Keyword backup
```

### Data
```
data/
└── cases.csv               ← Construction cases
```

### Configuration
```
requirements.txt            ← Dependencies list
docker-compose.yml          ← Docker config
```

### Scripts
```
quick_start.sh              ← Interactive setup
ec2_*.sh                    ← EC2 scripts
```

### Documentation
```
START_HERE.md               ← 👈 BEGIN HERE
FINAL_SUMMARY.txt           ← Quick overview
QUICK_START_REFERENCE.md    ← Complete reference
SETUP_AND_RUN_GUIDE.md      ← Detailed guide
DOCUMENTATION_INDEX.md      ← Index of all docs
EC2_DISK_CLEANUP_GUIDE.md   ← EC2 help
```

---

## 🌟 KEY FEATURES

✅ **Semantic Search**
- AI-powered similarity matching
- Finds contextually similar cases
- Not just keyword matching

✅ **Hybrid Search**
- Combines semantic + keyword approaches
- Best of both worlds

✅ **Fast**
- Embeddings cached for speed
- Search in 100-200ms

✅ **Beautiful UI**
- ChatGPT-like interface
- Easy to use

✅ **AI Integration**
- Uses Gemini API
- Intelligent answers

✅ **REST API**
- FastAPI backend
- Swagger documentation

✅ **Scalable**
- Ready for EC2
- Docker support

---

## 🎯 QUICK START CHECKLIST

- [ ] Run: `pip install -r requirements.txt`
- [ ] Get key: https://makersuite.google.com/app/apikey
- [ ] Set key: `export GOOGLE_API_KEY="your-key"`
- [ ] Terminal 1: `python3 app/cloud_server.py`
- [ ] Terminal 2: `streamlit run app/ui.py`
- [ ] Open: http://localhost:8501
- [ ] Ask questions! 🎉

---

## 📞 DOCUMENTATION MAP

**Start with:**
1. `START_HERE.md` - Step-by-step guide
2. `FINAL_SUMMARY.txt` - Quick overview

**Then read:**
3. `QUICK_START_REFERENCE.md` - Complete reference
4. `SETUP_AND_RUN_GUIDE.md` - Troubleshooting

**For EC2:**
5. `EC2_DISK_CLEANUP_GUIDE.md` - Disk management

---

## 🚀 NEXT STEPS

1. ✅ Read `START_HERE.md`
2. ✅ Install packages
3. ✅ Get API key
4. ✅ Start backend + frontend
5. ✅ Open browser
6. ✅ Ask questions!

---

## 💡 TIPS

1. **Set API key permanently:**
   ```bash
   echo 'export GOOGLE_API_KEY="your-key"' >> ~/.bashrc
   ```

2. **Run in background (EC2):**
   ```bash
   nohup python3 app/cloud_server.py > backend.log 2>&1 &
   nohup streamlit run app/ui.py --server.port 8501 > frontend.log 2>&1 &
   ```

3. **Monitor logs:**
   ```bash
   tail -f backend.log
   tail -f frontend.log
   ```

4. **Check if running:**
   ```bash
   ps aux | grep -E "cloud_server|streamlit"
   ```

---

**Everything is ready! Start with `START_HERE.md` and you'll be up and running in 20 minutes.** 🚀
