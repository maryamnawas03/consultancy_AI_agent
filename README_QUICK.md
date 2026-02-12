# 🚀 QUICK REFERENCE CARD

## Installation (5 minutes)

```bash
pip install -r requirements.txt
```

✅ Installs all 9 required packages
✅ Ready to use
✅ ~1.4GB total

---

## API Key Setup (2 minutes)

```
1. Visit: https://makersuite.google.com/app/apikey
2. Copy your free API key
3. Run: export GOOGLE_API_KEY="paste-key-here"
```

---

## Start the System

### Terminal 1 (Backend)
```bash
cd /path/to/consultancy_AI_agent
export GOOGLE_API_KEY="your-key"
python3 app/cloud_server.py
```
✅ Runs on http://localhost:8000

### Terminal 2 (Frontend)
```bash
cd /path/to/consultancy_AI_agent
streamlit run app/ui.py
```
✅ Opens at http://localhost:8501

---

## Use It

Open: **http://localhost:8501**

Type questions like:
- "What are common foundation problems?"
- "Tell me about water damage cases"
- "How to fix concrete cracks?"

---

## Dependencies (What Gets Installed)

| Package | Purpose | Required |
|---------|---------|----------|
| streamlit | Web UI | ✅ Yes |
| fastapi | Backend | ✅ Yes |
| uvicorn | Server | ✅ Yes |
| pandas | CSV handling | ✅ Yes |
| requests | HTTP | ✅ Yes |
| google-generativeai | Gemini AI | ✅ Yes |
| sentence-transformers | **Embeddings** | ✅ Yes |
| scikit-learn | **ML** | ✅ Yes |
| markdown | Text formatting | ✅ Yes |

---

## Test It

### Test 1: API Running?
```bash
curl http://localhost:8000/docs
```

### Test 2: Search Works?
```bash
curl -X POST http://localhost:8000/search \
  -H "Content-Type: application/json" \
  -d '{"query": "foundation problems", "top_k": 3}'
```

### Test 3: UI Works?
Open http://localhost:8501 and ask a question

---

## Performance

- ⚡ First startup: 30-60 seconds
- ⚡ Second startup: 5-10 seconds
- ⚡ Search: 100-200ms
- ⚡ AI response: 2-5 seconds

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| "Module not found" | `pip install -r requirements.txt` |
| "API key not set" | `export GOOGLE_API_KEY="your-key"` |
| "Port in use" | Kill process: `lsof -i :8000` |
| "No disk space" | Run cleanup scripts |
| "Slow first run" | Normal! ML model downloading |

---

## For EC2

```bash
# Install
pip install --no-cache-dir -r requirements.txt

# Run background
export GOOGLE_API_KEY="your-key"
nohup python3 app/cloud_server.py > backend.log 2>&1 &
nohup streamlit run app/ui.py --server.port 8501 > frontend.log 2>&1 &

# Access: http://your-ec2-ip:8501
```

---

## Documentation Files

- 📖 **QUICK_START_REFERENCE.md** - This guide
- 📖 **SETUP_AND_RUN_GUIDE.md** - Detailed docs
- 📖 **SYSTEM_SUMMARY.md** - Overview
- 📖 **EC2_DISK_CLEANUP_GUIDE.md** - Optimize disk

---

## System Ports

- 🌐 **Frontend**: http://localhost:8501
- 🔌 **Backend API**: http://localhost:8000
- 📚 **API Docs**: http://localhost:8000/docs

---

**That's it! You're ready to go.** 🎉

Questions? Check the documentation files!
