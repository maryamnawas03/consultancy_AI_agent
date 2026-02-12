# 🏗️ Construction Consulting AI Agent - Complete Setup Guide

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│  FRONTEND: Streamlit UI (Port 8501)                         │
│  - Beautiful ChatGPT-like interface                          │
│  - Case search and chat interface                            │
└──────────────────────┬──────────────────────────────────────┘
                       │ HTTP Requests
                       ↓
┌─────────────────────────────────────────────────────────────┐
│  BACKEND: FastAPI Server (Port 8000)                        │
│  - REST API endpoints                                       │
│  - Semantic search with embeddings                          │
│  - Gemini AI integration                                    │
│  - Hybrid keyword + semantic search                         │
└──────────────────────┬──────────────────────────────────────┘
                       │
        ┌──────────────┼──────────────┐
        ↓              ↓              ↓
    ┌────────┐  ┌──────────────┐  ┌─────────────┐
    │CSV Data│  │Embeddings    │  │Gemini API   │
    │(cases) │  │(cached)      │  │(AI answers) │
    └────────┘  └──────────────┘  └─────────────┘
```

---

## Dependencies

### Required Python Packages

| Package | Version | Purpose | Size |
|---------|---------|---------|------|
| **streamlit** | >=1.29.0 | Frontend UI framework | ~200MB |
| **fastapi** | >=0.104.0 | Backend API framework | ~50MB |
| **uvicorn** | >=0.24.0 | ASGI web server | ~20MB |
| **pandas** | >=1.5.0 | Data manipulation (CSV reading) | ~300MB |
| **requests** | >=2.28.0 | HTTP client library | ~10MB |
| **google-generativeai** | >=0.8.0 | Gemini AI API client | ~50MB |
| **sentence-transformers** | >=2.2.0 | **Semantic search embeddings** | ~500MB |
| **scikit-learn** | >=1.3.0 | **ML algorithms (similarity)** | ~300MB |
| **markdown** | >=3.4.0 | Markdown processing | ~5MB |

**Total:** ~1.4GB (first install)

### System Requirements

- **Python:** 3.8+ (tested on 3.9-3.11)
- **RAM:** 2GB minimum, 4GB recommended
- **Disk Space:** 2GB available (after cleanup)
- **Internet:** Required for:
  - Initial downloads
  - Gemini API calls
  - ML model downloads

---

## Installation Guide

### Step 1: Prerequisites Check

```bash
# Check Python version
python3 --version
# Should output: Python 3.8 or higher

# Check available disk space
df -h
# Should have at least 2GB free
```

### Step 2: Install Dependencies

```bash
# Navigate to your project
cd /path/to/consultancy_AI_agent

# Option A: Install with cache (faster if re-installing)
pip install -r requirements.txt

# Option B: Install without cache (saves disk space)
pip install --no-cache-dir -r requirements.txt

# Option C: Install one by one (best for debugging)
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

### Step 3: Verify Installation

```bash
# Check all packages installed
pip list

# Test core imports
python3 -c "
import streamlit
import fastapi
import pandas
import requests
import google.generativeai
from sentence_transformers import SentenceTransformer
from sklearn.metrics.pairwise import cosine_similarity
print('✅ All packages installed successfully!')
"
```

---

## Configuration

### Step 1: Set Up Gemini API Key

Get your free Gemini API key at: https://makersuite.google.com/app/apikey

```bash
# Option A: Environment variable (recommended)
export GOOGLE_API_KEY="your-api-key-here"

# Option B: Create .env file
echo "GOOGLE_API_KEY=your-api-key-here" > .env

# Option C: Hard-code in app (NOT recommended for production)
# Edit app/cloud_server.py and add:
# os.environ["GOOGLE_API_KEY"] = "your-key"
```

### Step 2: Verify Data File

```bash
# Check if cases.csv exists
ls -la data/cases.csv
# Should output file details

# Check CSV format
head -5 data/cases.csv
# Should have columns: case_id, title, problem, solution, tags
```

---

## Running the System

### Option A: Local Development (Recommended for Testing)

```bash
# Terminal 1: Start the backend API server
cd /path/to/consultancy_AI_agent
export GOOGLE_API_KEY="your-api-key"
python3 app/cloud_server.py
# Server runs on: http://localhost:8000
```

```bash
# Terminal 2: Start the frontend UI (in a NEW terminal)
cd /path/to/consultancy_AI_agent
streamlit run app/ui.py
# UI opens at: http://localhost:8501
```

### Option B: Production on EC2

```bash
# SSH into your EC2 instance
ssh -i /path/to/key.pem ec2-user@your-ec2-ip

# Navigate to project
cd /home/ec2-user/consultancy_AI_agent

# Set API key
export GOOGLE_API_KEY="your-api-key"

# Start backend in background
nohup python3 app/cloud_server.py > backend.log 2>&1 &

# Start frontend in background
nohup streamlit run app/ui.py --server.port 8501 > frontend.log 2>&1 &

# Verify both are running
netstat -tlnp | grep -E '8000|8501'
```

### Option C: Docker (If Available)

```bash
# Using docker-compose (if docker-compose.yml exists)
docker-compose up -d

# Check logs
docker-compose logs -f
```

---

## Testing the System

### Test 1: Health Check API

```bash
# Check if backend is running
curl http://localhost:8000/docs
# Should show Swagger API documentation
```

### Test 2: Semantic Search

```bash
# Test semantic search endpoint
curl -X POST http://localhost:8000/search \
  -H "Content-Type: application/json" \
  -d '{
    "query": "foundation problems",
    "top_k": 3
  }'

# Expected response:
# {
#   "results": [...],
#   "search_method": "semantic",
#   "best_score": 0.75
# }
```

### Test 3: Chat with AI

```bash
# Test chat endpoint
curl -X POST http://localhost:8000/chat \
  -H "Content-Type: application/json" \
  -d '{
    "session_id": "test-session",
    "message": "What are common foundation issues?",
    "search_method": "semantic"
  }'

# Expected response:
# {
#   "answer": "Based on the cases...",
#   "sources": ["case-123", "case-456"],
#   "best_score": 0.82,
#   "method": "semantic"
# }
```

### Test 4: Web Interface

**Frontend (Streamlit):**
- Open: http://localhost:8501
- Type a question in the chat box
- Click "Search Cases" or "Ask AI"
- See results and AI response

---

## Troubleshooting

### Issue: "Module not found" error

```bash
# Solution: Verify all packages installed
pip list | grep -E "streamlit|fastapi|pandas|sentence-transformers"

# Re-install if needed
pip install --no-cache-dir -r requirements.txt
```

### Issue: "No module named 'semantic_search'"

```bash
# Make sure you're in the correct directory
cd /path/to/consultancy_AI_agent
python3 app/cloud_server.py

# Or add app directory to Python path
export PYTHONPATH="${PYTHONPATH}:/path/to/consultancy_AI_agent/app"
```

### Issue: "GOOGLE_API_KEY not set"

```bash
# Set the API key before running
export GOOGLE_API_KEY="your-actual-key"

# Verify it's set
echo $GOOGLE_API_KEY
```

### Issue: Disk space errors during installation

```bash
# Use --no-cache-dir option
pip install --no-cache-dir -r requirements.txt

# Or install one package at a time
pip install --no-cache-dir streamlit

# Clean pip cache
pip cache purge
```

### Issue: Sentence-transformers downloading models slowly

```bash
# First run will download ~400MB model
# This is normal - be patient!
# Progress will show in logs

# Check if model is downloading
ls -lh ~/.cache/torch/sentence_transformers/
```

### Issue: Backend or frontend won't start

```bash
# Check if ports are in use
lsof -i :8000  # Backend port
lsof -i :8501  # Frontend port

# Kill existing process if needed
kill -9 <PID>

# Try different ports
python3 app/cloud_server.py --port 9000
streamlit run app/ui.py --server.port 9501
```

---

## Verifying Everything Works

### Complete Verification Checklist

```bash
#!/bin/bash
echo "🔍 Verification Checklist"
echo "=========================="
echo ""

# 1. Python version
echo "1️⃣ Python version:"
python3 --version
echo ""

# 2. Required packages
echo "2️⃣ Checking packages:"
python3 -c "
import streamlit; print('✅ streamlit')
import fastapi; print('✅ fastapi')
import pandas; print('✅ pandas')
from sentence_transformers import SentenceTransformer; print('✅ sentence-transformers')
from sklearn.metrics.pairwise import cosine_similarity; print('✅ scikit-learn')
print('All packages OK!')
"
echo ""

# 3. Data file
echo "3️⃣ Data file:"
if [ -f "data/cases.csv" ]; then
    echo "✅ cases.csv found"
    echo "   Rows: $(tail -1 data/cases.csv | wc -l)"
else
    echo "❌ cases.csv NOT found"
fi
echo ""

# 4. API Key
echo "4️⃣ API Key:"
if [ -z "$GOOGLE_API_KEY" ]; then
    echo "⚠️  GOOGLE_API_KEY not set"
else
    echo "✅ GOOGLE_API_KEY set (${#GOOGLE_API_KEY} chars)"
fi
echo ""

# 5. Try to load semantic search
echo "5️⃣ Testing semantic search:"
python3 -c "
import sys
sys.path.insert(0, 'app')
from semantic_search import SemanticSearchEngine
print('✅ Semantic search module loads successfully')
"
echo ""

echo "✅ All checks complete!"
```

Save this as `verify_setup.sh` and run:
```bash
chmod +x verify_setup.sh
./verify_setup.sh
```

---

## Expected Startup Output

### Backend (FastAPI)

```
INFO:     Uvicorn running on http://0.0.0.0:8000 (Press CTRL+C to quit)
🔄 Loading semantic search model: all-MiniLM-L6-v2
✅ Model loaded: all-MiniLM-L6-v2
📦 Loading cached embeddings from data/embeddings_all-MiniLM-L6-v2.pkl
✅ Loaded 47 cached embeddings
INFO:     Application startup complete
```

### Frontend (Streamlit)

```
You can now view your Streamlit app in your browser.
URL: http://localhost:8501
```

---

## Performance Metrics

| Operation | Time | Notes |
|-----------|------|-------|
| First startup | 30-60s | Downloads embedding model |
| Subsequent startup | 5-10s | Uses cached model |
| Semantic search | 100-200ms | Per query |
| Gemini API call | 2-5s | Depends on internet |
| Total chat response | 3-7s | Search + AI generation |

---

## Next Steps

1. ✅ Install all dependencies
2. ✅ Set up Gemini API key
3. ✅ Run backend and frontend
4. ✅ Test with sample queries
5. ✅ Deploy to EC2 (if needed)

---

## Need Help?

Check the logs:
```bash
# Backend logs
tail -50 backend.log

# Frontend logs
tail -50 frontend.log

# System logs
journalctl -xe
```
