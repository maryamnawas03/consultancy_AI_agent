# 🚀 EC2 DEPLOYMENT - SIMPLIFIED (NO SEMANTIC SEARCH)

## What Changed

✅ Removed sentence-transformers (huge library)
✅ Removed scikit-learn (ML library)  
✅ Removed numpy (complex dependencies)
✅ Now using ONLY keyword search - much faster and lighter

**New dependencies:** streamlit, fastapi, uvicorn, pandas, requests, markdown, google-generativeai

---

## EC2 Setup - 3 Steps

### Step 1: Upload to EC2

**From your Mac:**
```bash
cd /Users/maryamnawas/Desktop
scp -i ~/Downloads/construction-key.pem -r consultancy_AI_agent ec2-user@16.16.193.209:~/
```

### Step 2: SSH into EC2

```bash
ssh -i ~/Downloads/construction-key.pem ec2-user@16.16.193.209
```

### Step 3: Run Setup Script

**On EC2:**
```bash
cd ~/consultancy_AI_agent
chmod +x setup_ec2.sh
./setup_ec2.sh
```

That's it! The script will:
- Install Python dependencies
- Create virtual environment
- Set API keys
- Start both backend and frontend services

---

## Access Your App

Once setup completes, open in browser:
**`http://16.16.193.209:8501`**

---

## Quick Commands

```bash
# View backend logs
tail -f backend.log

# View frontend logs
tail -f frontend.log

# Check if services running
ps aux | grep -E "(uvicorn|streamlit)" | grep -v grep

# Stop services
pkill -f uvicorn && pkill -f streamlit

# Restart services
source venv/bin/activate
export GEMINI_API_KEY="AIzaSyBOL1MerZ-WZrukiFxhMGRe4UNBcGxdC6I"
nohup python -m uvicorn app.cloud_server:app --host 0.0.0.0 --port 8000 > backend.log 2>&1 &
nohup streamlit run app/ui.py --server.port 8501 --server.address 0.0.0.0 > frontend.log 2>&1 &
```

---

## How It Works Now

1. **Keyword Search** - Simple text matching (very fast, minimal space)
2. **Gemini AI** - Generates intelligent responses from matched cases
3. **No Models** - No sentence-transformers or scikit-learn needed
4. **Minimal Space** - Much smaller EC2 storage footprint

---

## If Setup Fails

Check the logs:
```bash
tail -50 backend.log
tail -50 frontend.log
```

Most common issues:
- Missing venv: Create it manually `python3 -m venv venv`
- Missing pip packages: `source venv/bin/activate && pip install -r requirements.txt`
- API key not set: `export GEMINI_API_KEY="AIzaSyBOL1MerZ-WZrukiFxhMGRe4UNBcGxdC6I"`

---

## What's Different from Original

| Aspect | Before | Now |
|--------|--------|-----|
| Search Type | Semantic + Keyword | Keyword Only |
| Models Needed | Yes (sentence-transformers) | No |
| Space Required | ~1+ GB | ~200 MB |
| Dependencies | 10+ packages | 7 packages |
| Speed | Slower (embeddings) | Very fast |
| Quality | Very good | Good |

---

You're all set! Run the setup script and enjoy! 🎉
