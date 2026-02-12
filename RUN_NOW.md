# 🚀 HOW TO RUN & TEST - Summary

## ✅ Setup Complete!

Virtual environment is ready with all dependencies installed.

---

## 🎯 Quick Start (3 Steps)

### Step 1: Get Gemini API Key
```
Go to: https://makersuite.google.com/app/apikey
Click: Create API Key
Copy: Your key
```

### Step 2: Activate Environment & Set Key
```bash
cd /Users/maryamnawas/Desktop/consultancy_AI_agent
source venv/bin/activate
export GOOGLE_API_KEY="your-api-key"
```

### Step 3: Start System
```bash
# Option A: Easy way (interactive menu)
bash run.sh

# Option B: Manual - Terminal 1 (Backend)
python3 app/cloud_server.py

# Option B: Manual - Terminal 2 (Frontend)
streamlit run app/ui.py
```

---

## 🌐 Access the System

**Web Interface:** http://localhost:8501  
**API Docs:** http://localhost:8000/docs  

---

## 🧪 Test It

### Method 1: Web Interface (Easiest!)
1. Open http://localhost:8501
2. Type: "What are foundation issues?"
3. Click "Search Cases"
4. Click "Ask AI"
5. See Gemini AI response!

### Method 2: REST API (Terminal)

**Test Search:**
```bash
curl -X POST http://localhost:8000/search \
  -H "Content-Type: application/json" \
  -d '{"query": "foundation problems", "top_k": 3}'
```

**Test Chat with Gemini:**
```bash
curl -X POST http://localhost:8000/chat \
  -H "Content-Type: application/json" \
  -d '{
    "session_id": "test",
    "message": "What causes concrete cracks?",
    "search_method": "semantic"
  }'
```

**Response should include:**
- ✅ `"search_method": "semantic"`
- ✅ `"answer": "..."` (from Gemini AI)
- ✅ `"best_score": 0.75+`

### Method 3: Swagger UI (Interactive)
Open: http://localhost:8000/docs
- Click on endpoints
- Try them out
- See responses

---

## 📍 On EC2

### Deploy:
```bash
# SSH in
ssh -i key.pem ec2-user@your-ip

# Activate venv
source /home/ec2-user/consultancy_AI_agent/venv/bin/activate

# Set key
export GOOGLE_API_KEY="your-key"

# Run backend
nohup python3 app/cloud_server.py > backend.log 2>&1 &

# Run frontend (new SSH session)
nohup streamlit run app/ui.py --server.port 8501 > frontend.log 2>&1 &
```

### Access:
```
Frontend: http://your-ec2-ip:8501
API: http://your-ec2-ip:8000/docs
```

---

## ✅ What You're Getting

✅ **Semantic Search** - AI finds similar cases (not just keywords)  
✅ **Gemini AI** - Intelligent answers using Google's AI  
✅ **Beautiful UI** - ChatGPT-like interface  
✅ **REST API** - For integration  
✅ **Cached** - Fast after first run  
✅ **Works on EC2** - Production ready  

---

## 📚 Documentation

- `RUN_AND_TEST_GUIDE.md` - Complete guide with examples
- `START_HERE.md` - Step-by-step setup
- `COMPLETE_SUMMARY.md` - Dependencies & architecture

---

## 🎉 Start Now!

```bash
cd /Users/maryamnawas/Desktop/consultancy_AI_agent
source venv/bin/activate
export GOOGLE_API_KEY="your-api-key"
python3 app/cloud_server.py
```

Then in another terminal:
```bash
cd /Users/maryamnawas/Desktop/consultancy_AI_agent
source venv/bin/activate
streamlit run app/ui.py
```

Open: http://localhost:8501

**Ask questions and get AI-powered answers!** 🚀
