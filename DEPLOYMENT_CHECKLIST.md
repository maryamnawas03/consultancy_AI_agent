# ✅ PRE-DEPLOYMENT CHECKLIST

## Local Machine (Mac)

- [ ] Navigate to `/Users/maryamnawas/Desktop/consultancy_AI_agent`
- [ ] Verify `setup_ec2.sh` exists and is executable
- [ ] Verify `requirements.txt` has only 7 packages
- [ ] Verify `app/cloud_server.py` doesn't import semantic_search
- [ ] Have SSH key: `~/Downloads/construction-key.pem`

## AWS EC2 Instance

- [ ] Instance is running (status: running)
- [ ] Instance type: t2.micro or larger
- [ ] Available disk space: 512 MB+ free
- [ ] Public IP address noted: `16.16.193.209` ✓
- [ ] Security group allows:
  - [ ] Port 22 (SSH)
  - [ ] Port 8000 (FastAPI)
  - [ ] Port 8501 (Streamlit)

## Before Uploading

- [ ] No broken symlinks in project
- [ ] `data/cases.csv` exists and is readable
- [ ] All Python files have no syntax errors
- [ ] SSH key has correct permissions: `chmod 600 ~/Downloads/construction-key.pem`

---

# 🚀 DEPLOYMENT STEPS

## Step 1: Upload Project (Mac Terminal)

```bash
# Navigate to project
cd /Users/maryamnawas/Desktop/consultancy_AI_agent

# Upload everything to EC2
scp -i ~/Downloads/construction-key.pem -r . ec2-user@16.16.193.209:~/consultancy_AI_agent/

# Verify upload
scp -i ~/Downloads/construction-key.pem -r ~/consultancy_AI_agent/requirements.txt ec2-user@16.16.193.209:~/test.txt
# If successful, file copied to EC2
```

**Expected:** No errors, file transfer completes

## Step 2: SSH into EC2

```bash
ssh -i ~/Downloads/construction-key.pem ec2-user@16.16.193.209
```

**Expected:** You see EC2 prompt like `[ec2-user@ip-xxx ~]$`

## Step 3: Run Setup Script (On EC2)

```bash
cd ~/consultancy_AI_agent
chmod +x setup_ec2.sh
./setup_ec2.sh
```

**Expected:** Script runs for 2-3 minutes, shows:
- Python installation
- Virtual environment creation
- Package installation
- Service startup messages
- Final access URL

## Step 4: Verify Services (On EC2)

```bash
ps aux | grep -E "(uvicorn|streamlit)" | grep -v grep
```

**Expected:** 2 processes running:
```
ec2-user  ... python -m uvicorn app.cloud_server:app ...
ec2-user  ... streamlit run app/ui.py ...
```

## Step 5: Access in Browser

Open: `http://16.16.193.209:8501`

**Expected:** Streamlit app loads with:
- Title: "Construction Assistant"
- Search box: "Ask about a construction problem..."
- Ability to search and get responses

---

# 🧪 QUICK TESTS

## Test 1: Backend Health

```bash
curl http://localhost:8000/
```

**Expected Response:**
```json
{"status":"Construction Consulting API is running",...}
```

## Test 2: Search Query

```bash
curl -X POST http://localhost:8000/chat \
  -H "Content-Type: application/json" \
  -d '{"session_id":"test", "message":"concrete cracking", "top_k":3}'
```

**Expected:** JSON response with answer and sources

## Test 3: Frontend Load

Open browser: `http://16.16.193.209:8501`

**Expected:** Streamlit app loads and is interactive

## Test 4: Search in UI

1. Type: "cable tray overheating"
2. Click send
3. Should get AI-generated response

**Expected:** Response appears with sources

---

# ⚠️ TROUBLESHOOTING

## Issue: "Connection refused"

```bash
# Check if services are running
ps aux | grep -E "(uvicorn|streamlit)" | grep -v grep

# If not, manually start:
cd ~/consultancy_AI_agent
source venv/bin/activate
export GEMINI_API_KEY="AIzaSyBOL1MerZ-WZrukiFxhMGRe4UNBcGxdC6I"
nohup python -m uvicorn app.cloud_server:app --host 0.0.0.0 --port 8000 > backend.log 2>&1 &
nohup streamlit run app/ui.py --server.port 8501 --server.address 0.0.0.0 > frontend.log 2>&1 &
```

## Issue: "Cannot find module"

```bash
# Check logs
tail -20 backend.log
tail -20 frontend.log

# Verify venv is activated
which python  # Should show venv/bin/python

# Reinstall packages
source venv/bin/activate
pip install -r requirements.txt --force-reinstall
```

## Issue: "Port 8000/8501 already in use"

```bash
# Kill existing processes
pkill -f uvicorn
pkill -f streamlit

# Wait 2 seconds
sleep 2

# Start again
source venv/bin/activate
export GEMINI_API_KEY="AIzaSyBOL1MerZ-WZrukiFxhMGRe4UNBcGxdC6I"
nohup python -m uvicorn app.cloud_server:app --host 0.0.0.0 --port 8000 > backend.log 2>&1 &
nohup streamlit run app/ui.py --server.port 8501 --server.address 0.0.0.0 > frontend.log 2>&1 &
```

## Issue: "API key not found"

```bash
# Check if set
echo $GEMINI_API_KEY

# Set it
export GEMINI_API_KEY="AIzaSyBOL1MerZ-WZrukiFxhMGRe4UNBcGxdC6I"

# Make permanent
echo 'export GEMINI_API_KEY="AIzaSyBOL1MerZ-WZrukiFxhMGRe4UNBcGxdC6I"' >> ~/.bashrc

# Reload
source ~/.bashrc
```

---

# ✅ SUCCESS CRITERIA

You're done when:

- [ ] `setup_ec2.sh` completes without errors
- [ ] `ps aux` shows 2 running processes (uvicorn + streamlit)
- [ ] `http://16.16.193.209:8501` loads in browser
- [ ] Can type in search box and get results
- [ ] API at `http://16.16.193.209:8000/docs` shows Swagger UI
- [ ] `curl localhost:8000/` returns JSON status

---

# 📝 Notes

- Services run in background (nohup) and persist after disconnect
- To stop: `pkill -f uvicorn && pkill -f streamlit`
- To restart: Run the manual start commands above
- Logs are in `~/consultancy_AI_agent/backend.log` and `frontend.log`
- No need to worry about semantic_search - it's completely removed

---

**Ready to deploy?** Follow the steps above! 🚀
