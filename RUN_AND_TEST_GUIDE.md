# 🚀 Complete Guide: How to Run and Test on localhost & EC2

## ✅ Prerequisites Complete

All dependencies are installed in the virtual environment:
- ✅ streamlit
- ✅ fastapi
- ✅ uvicorn
- ✅ pandas
- ✅ requests
- ✅ google-generativeai (Gemini)
- ✅ sentence-transformers (semantic search)
- ✅ scikit-learn (ML)
- ✅ markdown

---

## 🔑 Step 1: Get Gemini API Key (FREE)

### Get your free API key:
```
Website: https://makersuite.google.com/app/apikey
Click: "Create API Key"
Copy: Your API key
```

**IMPORTANT:** Keep this key secret and don't share it!

---

## 🚀 Option 1: Run on Local Machine (macOS/Linux)

### Terminal 1: Start Backend API

```bash
# Navigate to project
cd /Users/maryamnawas/Desktop/consultancy_AI_agent

# Activate virtual environment
source venv/bin/activate

# Set API key
export GOOGLE_API_KEY="your-api-key-from-above"

# Start backend
python3 app/cloud_server.py
```

**Expected output:**
```
🔄 Loading semantic search model: all-MiniLM-L6-v2
✅ Model loaded: all-MiniLM-L6-v2
📦 Loading cached embeddings...
✅ Loaded 47 cached embeddings
INFO:     Uvicorn running on http://0.0.0.0:8000
INFO:     Application startup complete
```

✅ **Backend is now running on: http://localhost:8000**

---

### Terminal 2: Start Frontend UI (NEW TERMINAL)

```bash
# Navigate to project
cd /Users/maryamnawas/Desktop/consultancy_AI_agent

# Activate virtual environment
source venv/bin/activate

# Start frontend
streamlit run app/ui.py
```

**Expected output:**
```
You can now view your Streamlit app in your browser.

URL: http://localhost:8501

If this is your first time using Streamlit, watch our demo video...
```

✅ **Frontend is now running on: http://localhost:8501**

---

### Step 3: Open in Browser

```
http://localhost:8501
```

You'll see a ChatGPT-like interface. Type your questions!

---

## 📝 Testing on localhost

### Test 1: Using Web Interface (Easiest)

1. Open: http://localhost:8501
2. Type a question:
   - "What are common foundation issues?"
   - "Tell me about water damage in construction"
   - "How to fix concrete cracks?"
3. Click "Search Cases"
4. See matching cases appear
5. Click "Ask AI" to get Gemini AI answer

### Test 2: Using REST API (Terminal)

Open a NEW terminal and run these commands:

**Test Semantic Search:**
```bash
curl -X POST http://localhost:8000/search \
  -H "Content-Type: application/json" \
  -d '{
    "query": "foundation problems",
    "top_k": 3,
    "search_method": "semantic"
  }'
```

**Look for in response:**
- ✅ `"search_method": "semantic"`
- ✅ `"best_score": 0.75+` (confidence score)
- ✅ Cases in results

**Test Chat with Gemini:**
```bash
curl -X POST http://localhost:8000/chat \
  -H "Content-Type: application/json" \
  -d '{
    "session_id": "test-session",
    "message": "What are common foundation issues in construction?",
    "search_method": "semantic"
  }'
```

**Look for:**
- ✅ `"answer": "..."` (AI response from Gemini)
- ✅ `"sources": [...]` (matching case IDs)
- ✅ `"best_score": 0.75+`

### Test 3: Using Swagger UI

1. Open: http://localhost:8000/docs
2. You'll see interactive API documentation
3. Try endpoints by clicking "Try it out"
4. Enter parameters and click "Execute"

---

## 🖥️ Option 2: Run on EC2

### Prerequisites on EC2:
```bash
# SSH into EC2
ssh -i /path/to/key.pem ec2-user@your-ec2-ip

# Navigate to project
cd /home/ec2-user/consultancy_AI_agent

# Verify virtual environment created
test -d venv && echo "✅ venv exists" || echo "❌ Need to create venv"
```

### Setup on EC2 (if needed):
```bash
# Create virtual environment
python3 -m venv venv

# Activate it
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt
```

### Run Backend on EC2:
```bash
# Set API key
export GOOGLE_API_KEY="your-api-key"

# Option A: Run in foreground (for testing)
python3 app/cloud_server.py

# Option B: Run in background (for production)
nohup python3 app/cloud_server.py > backend.log 2>&1 &
```

### Run Frontend on EC2:
```bash
# In a new SSH session
source venv/bin/activate

# Option A: Run in foreground
streamlit run app/ui.py --server.port 8501

# Option B: Run in background
nohup streamlit run app/ui.py --server.port 8501 > frontend.log 2>&1 &
```

### Access EC2 from Your Computer:

**Replace these:**
- `your-ec2-ip` = Your EC2 public IP (from AWS console)
- `8501` = Frontend port
- `8000` = Backend API port

**In your browser:**
```
Frontend: http://your-ec2-ip:8501
API: http://your-ec2-ip:8000
API Docs: http://your-ec2-ip:8000/docs
```

**Test with curl from local machine:**
```bash
# Test search
curl -X POST http://your-ec2-ip:8000/search \
  -H "Content-Type: application/json" \
  -d '{"query": "foundation problems", "top_k": 3}'

# Test chat
curl -X POST http://your-ec2-ip:8000/chat \
  -H "Content-Type: application/json" \
  -d '{
    "session_id": "test",
    "message": "What are foundation issues?"
  }'
```

---

## 🧪 Quick Test Script

Save this as `test.sh`:

```bash
#!/bin/bash

echo "Testing Construction Consulting AI Agent"
echo "=========================================="
echo ""

echo "1. Testing semantic search..."
curl -X POST http://localhost:8000/search \
  -H "Content-Type: application/json" \
  -d '{"query": "foundation problems", "top_k": 3}' \
  | python3 -m json.tool

echo ""
echo "2. Testing chat with Gemini..."
curl -X POST http://localhost:8000/chat \
  -H "Content-Type: application/json" \
  -d '{
    "session_id": "test",
    "message": "What causes foundation cracks?",
    "search_method": "semantic"
  }' \
  | python3 -m json.tool

echo ""
echo "✅ Tests complete!"
```

Run it:
```bash
chmod +x test.sh
./test.sh
```

---

## 📊 Expected Response Examples

### Search Response:
```json
{
  "results": [
    {
      "case_id": "C001",
      "title": "Foundation Settlement",
      "problem": "House foundation settling unevenly...",
      "solution": "Installed helical piers...",
      "score": 0.87,
      "method": "semantic"
    }
  ],
  "search_method": "semantic",
  "best_score": 0.87
}
```

### Chat Response:
```json
{
  "answer": "Foundation problems are common in construction...\n\n1. Common causes:\n- Settlement\n- Poor drainage\n- Soil issues\n\n2. Solutions:\n- Helical piers\n- Proper drainage\n...",
  "sources": ["C001", "C002"],
  "best_score": 0.87,
  "method": "semantic"
}
```

---

## 🔧 Troubleshooting

### Issue: "Port 8000 already in use"
```bash
# Find and kill process
lsof -i :8000
kill -9 <PID>

# Or use different port
python3 app/cloud_server.py --port 9000
```

### Issue: "GOOGLE_API_KEY not set"
```bash
# Set it
export GOOGLE_API_KEY="your-key"

# Verify
echo $GOOGLE_API_KEY
```

### Issue: "ModuleNotFoundError"
```bash
# Make sure virtual environment is activated
source venv/bin/activate

# Check Python
which python3
# Should be: /Users/maryamnawas/Desktop/consultancy_AI_agent/venv/bin/python3
```

### Issue: "First search is slow"
**This is NORMAL!** ML model downloading (~5 minutes)
- First time: Downloads 400MB model
- After that: Cached and fast (100-200ms)

### Issue: "No response from Gemini"
```bash
# Check API key is set
echo $GOOGLE_API_KEY

# Make sure it's a valid key from makersuite.google.com
```

---

## 📋 Quick Reference

### Local Machine (macOS):
```bash
# Terminal 1
cd /Users/maryamnawas/Desktop/consultancy_AI_agent
source venv/bin/activate
export GOOGLE_API_KEY="your-key"
python3 app/cloud_server.py

# Terminal 2
cd /Users/maryamnawas/Desktop/consultancy_AI_agent
source venv/bin/activate
streamlit run app/ui.py

# Open browser
http://localhost:8501
```

### EC2:
```bash
# SSH in
ssh -i key.pem ec2-user@ip

# Navigate
cd /home/ec2-user/consultancy_AI_agent

# Set key
export GOOGLE_API_KEY="your-key"

# Run backend
nohup python3 app/cloud_server.py > backend.log 2>&1 &

# Run frontend
nohup streamlit run app/ui.py --server.port 8501 > frontend.log 2>&1 &

# Open browser
http://your-ec2-ip:8501
```

---

## ✅ Verification Checklist

- [ ] Virtual environment created
- [ ] All packages installed
- [ ] API key obtained from makersuite.google.com
- [ ] API key set in terminal
- [ ] Backend started and running on :8000
- [ ] Frontend started and running on :8501
- [ ] Can access http://localhost:8501 (or EC2 IP)
- [ ] Can type a question
- [ ] Get results from semantic search
- [ ] Get AI answer from Gemini

---

## 🎉 You're Ready!

Everything is set up. Follow the steps above and you'll have:
- ✅ Beautiful web interface
- ✅ Semantic search (AI-powered)
- ✅ Gemini AI answers
- ✅ Working on localhost AND EC2

**Start now!** 🚀
