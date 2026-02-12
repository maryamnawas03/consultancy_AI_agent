# 🎯 START HERE - Complete Setup Guide

## Welcome! 👋

This is your **Construction Consulting AI Agent** - a complete system for searching construction cases and getting AI-powered answers.

---

## ⏱️ Time Estimate
- **Installation**: 5-10 minutes
- **Getting API key**: 2 minutes
- **First run**: 30-60 seconds (longer first time for ML model download)
- **Total**: ~20 minutes to be fully operational

---

## 🎯 What You Need to Do (4 Simple Steps)

### Step 1: Install Python Packages (5 minutes)

Run this command in your terminal:
```bash
cd /path/to/consultancy_AI_agent
pip install -r requirements.txt
```

**What gets installed:**
- 9 Python packages
- Total size: ~1.4GB
- Includes AI/ML libraries for semantic search

**For EC2 (save space):**
```bash
pip install --no-cache-dir -r requirements.txt
```

---

### Step 2: Get Gemini API Key (2 minutes)

1. Go to: https://makersuite.google.com/app/apikey
2. Click "Create API Key"
3. Copy your free API key
4. **Keep it secret!**

---

### Step 3: Set API Key (30 seconds)

In your terminal, set the environment variable:
```bash
export GOOGLE_API_KEY="your-api-key-from-above"
```

**Note:** You'll need to do this every time you open a new terminal, or add it to your `.bashrc` file.

---

### Step 4: Start the System (2 terminals)

**Terminal 1 - Start Backend:**
```bash
cd /path/to/consultancy_AI_agent
export GOOGLE_API_KEY="your-api-key"
python3 app/cloud_server.py
```

Wait for this message:
```
INFO:     Uvicorn running on http://0.0.0.0:8000
```

**Terminal 2 - Start Frontend (NEW TERMINAL):**
```bash
cd /path/to/consultancy_AI_agent
streamlit run app/ui.py
```

Wait for this message:
```
You can now view your Streamlit app in your browser.
URL: http://localhost:8501
```

---

## 🎉 You're Ready!

Open your browser and go to: **http://localhost:8501**

Now you can:
1. ✅ Type a question
2. ✅ Click "Search Cases"
3. ✅ See matching cases
4. ✅ Click "Ask AI" for intelligent answers

---

## 📋 Dependencies Overview

You're installing 9 essential packages:

| Package | Purpose | Size |
|---------|---------|------|
| **streamlit** | Web interface | 200MB |
| **fastapi** | Backend API | 50MB |
| **uvicorn** | Web server | 20MB |
| **pandas** | Data handling | 300MB |
| **requests** | HTTP library | 10MB |
| **google-generativeai** | Gemini API | 50MB |
| **sentence-transformers** | ⭐ **Semantic search embeddings** | 500MB |
| **scikit-learn** | ⭐ **ML calculations** | 300MB |
| **markdown** | Text formatting | 5MB |

**⭐ = Critical for semantic search** (AI-powered case matching)

---

## ✅ Quick Verification

After installation, verify everything works:

```bash
python3 -c "
from sentence_transformers import SentenceTransformer
from sklearn.metrics.pairwise import cosine_similarity
import pandas, requests
print('✅ All packages OK!')
"
```

---

## 🚀 Testing the System

### Test 1: Is Backend Running?
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
- ✅ `"search_method": "semantic"` (not "keyword")
- ✅ `"best_score": 0.75+` (high confidence match)

### Test 3: Try the Web Interface
1. Open http://localhost:8501
2. Type: "What are common construction issues?"
3. Click "Search Cases"
4. See matching cases appear
5. Click "Ask AI" to get an answer

---

## 📚 Documentation

Read these in order:

1. **FINAL_SUMMARY.txt** ← Start here for overview
2. **QUICK_START_REFERENCE.md** ← Complete reference
3. **SETUP_AND_RUN_GUIDE.md** ← Detailed guide with troubleshooting
4. **DOCUMENTATION_INDEX.md** ← Index of all docs

For EC2:
- **EC2_DISK_CLEANUP_GUIDE.md** ← Clean up disk space
- **DEPLOY_EC2_NOW.md** ← Deploy to EC2

---

## 🎯 System Architecture

```
┌─────────────────────────────┐
│  Streamlit UI (8501)        │
│  ChatGPT-like interface     │
└──────────────┬──────────────┘
               │
    ┌──────────┴──────────┐
    ↓                     ↓
┌────────────┐    ┌─────────────┐
│ Your Brain │    │ Semantic    │
│ asks Q     │    │ Search (AI) │
└────────────┘    └──────┬──────┘
                         │
                  ┌──────┴──────┐
                  ↓             ↓
             ┌────────┐   ┌──────────┐
             │CSV Data│   │Embeddings│
             │(cases) │   │(cached)  │
             └────────┘   └──────────┘
```

---

## ⚡ Performance

- **First startup**: 30-60 seconds (downloads ML model)
- **After that**: 5-10 seconds
- **Search**: 100-200ms
- **AI answer**: 2-5 seconds
- **Total**: 3-7 seconds per question

---

## 🆘 Common Issues

### Issue: "ModuleNotFoundError"
```bash
# Solution: Install packages
pip install -r requirements.txt
```

### Issue: "GOOGLE_API_KEY not set"
```bash
# Solution: Set API key
export GOOGLE_API_KEY="your-key"
```

### Issue: "Address already in use" (Port 8000)
```bash
# Kill the existing process
lsof -i :8000
kill -9 <PID>
```

### Issue: "No space left on device" (EC2)
Run cleanup scripts:
```bash
bash ec2_analyze_and_cleanup.sh
```

### Issue: "Slow first search"
**This is normal!** The ML model is downloading (~400MB). 
Just wait - it's only slow the first time, then cached.

### Issue: "Frontend can't connect to backend"
Make sure Terminal 1 (backend) started successfully with:
```
INFO:     Uvicorn running on http://0.0.0.0:8000
```

---

## 💡 Pro Tips

1. **Set API key permanently** (don't repeat each time):
   ```bash
   echo 'export GOOGLE_API_KEY="your-key"' >> ~/.bashrc
   source ~/.bashrc
   ```

2. **Use background processes** (EC2):
   ```bash
   nohup python3 app/cloud_server.py > backend.log 2>&1 &
   nohup streamlit run app/ui.py --server.port 8501 > frontend.log 2>&1 &
   ```

3. **Monitor logs** (EC2):
   ```bash
   tail -f backend.log
   tail -f frontend.log
   ```

4. **Check if services are running**:
   ```bash
   ps aux | grep -E "cloud_server|streamlit"
   ```

---

## 🚀 Next Steps

- [ ] Install packages: `pip install -r requirements.txt`
- [ ] Get API key: https://makersuite.google.com/app/apikey
- [ ] Set key: `export GOOGLE_API_KEY="..."`
- [ ] Start backend: `python3 app/cloud_server.py`
- [ ] Start frontend: `streamlit run app/ui.py`
- [ ] Open: http://localhost:8501
- [ ] Ask questions! 🎉

---

## 📁 File Structure

```
consultancy_AI_agent/
├── app/                           # Application code
│   ├── cloud_server.py           # FastAPI backend
│   ├── ui.py                     # Streamlit UI
│   ├── semantic_search.py        # AI search engine
│   └── fallback_search.py        # Keyword backup
├── data/                          # Data files
│   └── cases.csv                 # Case database
├── requirements.txt              # Python packages
├── quick_start.sh               # Auto-setup script
├── ec2_*.sh                     # EC2 scripts
└── *.md                         # Documentation
```

---

## 🎓 How It Works

1. **You ask a question** via the web interface
2. **Semantic search converts** your question to AI embeddings
3. **System finds similar cases** using embeddings (not just keywords!)
4. **Gemini AI generates** an intelligent answer
5. **You see results** with matching cases and AI response

### Why Semantic Search?
- Finds "foundation settlement" for query "house sinking"
- Understands meaning, not just keywords
- Much smarter than traditional search
- Lightning fast (cached embeddings)

---

## 🤝 Need Help?

1. Check **FINAL_SUMMARY.txt** for overview
2. Read **SETUP_AND_RUN_GUIDE.md** for troubleshooting
3. Check logs if something fails
4. EC2 issues? See **EC2_DISK_CLEANUP_GUIDE.md**

---

## ✨ You're All Set!

Everything you need is here. The system is ready to use.

**Start with Step 1 above and you'll be running in 20 minutes.** 🚀

Questions? See the documentation index or check logs!

---

**Good luck! Enjoy your Construction Consulting AI Agent!** 🏗️
