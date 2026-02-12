# 🚀 QUICK START - EC2 DEPLOYMENT

## Copy-Paste These Commands

### On Your Mac (First, get SSH key path right):
```bash
# Navigate to project
cd /Users/maryamnawas/Desktop/consultancy_AI_agent

# Upload project to EC2 (replace with your actual key path if different)
scp -i ~/Downloads/construction-key.pem -r . ec2-user@16.16.193.209:~/consultancy_AI_agent/
```

### On EC2 (SSH session):
```bash
# Connect to EC2
ssh -i ~/Downloads/construction-key.pem ec2-user@16.16.193.209

# Setup everything (one command!)
cd ~/consultancy_AI_agent && chmod +x setup_ec2.sh && ./setup_ec2.sh
```

### That's it!

After setup completes, open browser:
```
http://16.16.193.209:8501
```

---

## Verify It's Working

```bash
# Check processes
ps aux | grep -E "(uvicorn|streamlit)" | grep -v grep

# View backend logs
tail -f ~/consultancy_AI_agent/backend.log

# View frontend logs
tail -f ~/consultancy_AI_agent/frontend.log

# Test API
curl http://localhost:8000/

# Should return: {"status":"Construction Consulting API is running",...}
```

---

## Troubleshooting

### If venv fails:
```bash
cd ~/consultancy_AI_agent
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### If services don't start:
```bash
# Check backend logs
tail -50 backend.log

# Check frontend logs
tail -50 frontend.log

# Make sure API key is set
echo $GEMINI_API_KEY

# If empty, set it:
export GEMINI_API_KEY="AIzaSyBOL1MerZ-WZrukiFxhMGRe4UNBcGxdC6I"
```

### If ports are in use:
```bash
# Kill everything
pkill -f uvicorn
pkill -f streamlit

# Start again
cd ~/consultancy_AI_agent
source venv/bin/activate
export GEMINI_API_KEY="AIzaSyBOL1MerZ-WZrukiFxhMGRe4UNBcGxdC6I"
nohup python -m uvicorn app.cloud_server:app --host 0.0.0.0 --port 8000 > backend.log 2>&1 &
nohup streamlit run app/ui.py --server.port 8501 --server.address 0.0.0.0 > frontend.log 2>&1 &
```

---

## What You Get

✅ **Streamlit Frontend** - Beautiful web UI (port 8501)
✅ **FastAPI Backend** - REST API (port 8000)
✅ **Keyword Search** - Fast case matching
✅ **Gemini AI** - Smart response generation
✅ **No Dependencies Issues** - Everything lightweight!

---

## Dependencies Installed

```
streamlit>=1.29.0
fastapi>=0.104.0
uvicorn>=0.24.0
pandas>=1.5.0
requests>=2.28.0
markdown>=3.4.0
google-generativeai>=0.8.0
```

**Total Size:** ~150-200 MB (fits easily in t2.micro!)

---

## API Endpoints

After backend starts, visit:
- **Swagger Docs:** http://16.16.193.209:8000/docs
- **Health Check:** http://16.16.193.209:8000/
- **Chat Endpoint:** POST http://16.16.193.209:8000/chat

---

You're ready! Follow the Mac and EC2 commands above and you'll be live in minutes! 🎉
