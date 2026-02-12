# 🚀 AWS EC2 Deployment Guide - Construction Consulting AI Agent

## ✅ You've Deployed to EC2 - Now Let's Run It!

---

## 📋 Prerequisites Check

Before starting, verify on your EC2:

```bash
# SSH into your EC2 instance
ssh -i /path/to/your-key.pem ec2-user@your-ec2-public-ip

# Check if project exists
ls -la /home/ec2-user/consultancy_AI_agent

# Check Python version
python3 --version
# Should be Python 3.8+
```

---

## 🔧 Step 1: Initial EC2 Setup (First Time Only)

### A. Update System Packages

```bash
# Update system
sudo yum update -y

# Install essential packages
sudo yum install -y python3-pip git
```

### B. Create Virtual Environment

```bash
# Navigate to project
cd /home/ec2-user/consultancy_AI_agent

# Create virtual environment
python3 -m venv venv

# Activate it
source venv/bin/activate

# Upgrade pip
pip install --upgrade pip
```

### C. Install Dependencies

```bash
# Install all packages (this will take 5-10 minutes)
pip install --no-cache-dir -r requirements.txt

# Verify installation
python3 -c "
from sentence_transformers import SentenceTransformer
from sklearn.metrics.pairwise import cosine_similarity
import pandas, requests, streamlit, fastapi
print('✅ All packages installed!')
"
```

---

## 🔑 Step 2: Set Up Gemini API Key

### Option A: Temporary (For Testing)

```bash
export GOOGLE_API_KEY="your-api-key-from-makersuite"
```

### Option B: Permanent (Recommended)

```bash
# Add to .bashrc for persistence
echo 'export GOOGLE_API_KEY="your-api-key-here"' >> ~/.bashrc
source ~/.bashrc

# Verify it's set
echo $GOOGLE_API_KEY
```

### Get Free API Key:
Visit: https://makersuite.google.com/app/apikey

---

## 🚀 Step 3: Run the Application

### Option A: Quick Test (Foreground)

**Terminal Session 1 - Backend:**
```bash
cd /home/ec2-user/consultancy_AI_agent
source venv/bin/activate
export GOOGLE_API_KEY="your-key"
python3 app/cloud_server.py
```

Expected output:
```
🔄 Loading semantic search model: all-MiniLM-L6-v2
✅ Model loaded: all-MiniLM-L6-v2
📦 Loading cached embeddings...
✅ Loaded 47 cached embeddings
INFO:     Uvicorn running on http://0.0.0.0:8000
```

**Terminal Session 2 - Frontend (Open NEW SSH connection):**
```bash
cd /home/ec2-user/consultancy_AI_agent
source venv/bin/activate
streamlit run app/ui.py --server.port 8501 --server.address 0.0.0.0
```

---

### Option B: Production (Background with Logs)

**1. Start Backend:**
```bash
cd /home/ec2-user/consultancy_AI_agent
source venv/bin/activate
export GOOGLE_API_KEY="your-key"

# Run in background
nohup python3 app/cloud_server.py > backend.log 2>&1 &

# Note the process ID
echo $! > backend.pid
```

**2. Start Frontend:**
```bash
cd /home/ec2-user/consultancy_AI_agent
source venv/bin/activate

# Run in background
nohup streamlit run app/ui.py --server.port 8501 --server.address 0.0.0.0 > frontend.log 2>&1 &

# Note the process ID
echo $! > frontend.pid
```

**3. Verify Running:**
```bash
# Check processes
ps aux | grep -E "cloud_server|streamlit"

# Should see both running
```

---

## 🌐 Step 4: Configure AWS Security Groups

### Required Inbound Rules:

| Type | Protocol | Port | Source | Description |
|------|----------|------|--------|-------------|
| SSH | TCP | 22 | Your IP | SSH access |
| Custom TCP | TCP | 8000 | 0.0.0.0/0 | Backend API |
| Custom TCP | TCP | 8501 | 0.0.0.0/0 | Frontend UI |

**How to Add:**
1. Go to EC2 Console
2. Select your instance
3. Click "Security" tab
4. Click on Security Group
5. Click "Edit inbound rules"
6. Add rules for ports 8000 and 8501

---

## 🔗 Step 5: Access Your Application

### Get Your EC2 Public IP:

```bash
# On EC2, get public IP
curl -s http://169.254.169.254/latest/meta-data/public-ipv4
```

### Access URLs:

Replace `YOUR-EC2-IP` with your actual IP:

- **Frontend UI:** http://YOUR-EC2-IP:8501
- **Backend API:** http://YOUR-EC2-IP:8000
- **API Docs:** http://YOUR-EC2-IP:8000/docs

**Example:**
```
http://54.123.45.67:8501  (Frontend)
http://54.123.45.67:8000/docs  (API)
```

---

## 🧪 Step 6: Test It's Working

### Test 1: From EC2 (localhost)

```bash
# Test backend
curl http://localhost:8000/docs

# Test search
curl -X POST http://localhost:8000/search \
  -H "Content-Type: application/json" \
  -d '{"query": "foundation problems", "top_k": 3}'
```

### Test 2: From Your Computer

```bash
# Replace with your EC2 IP
curl -X POST http://YOUR-EC2-IP:8000/search \
  -H "Content-Type: application/json" \
  -d '{"query": "foundation problems", "top_k": 3}'

# Expected: JSON response with semantic search results
```

### Test 3: Web Browser

Open in your browser:
```
http://YOUR-EC2-IP:8501
```

1. Type a question: "What are foundation issues?"
2. Click "Search Cases"
3. See results
4. Click "Ask AI"
5. Get Gemini AI response!

---

## 📊 Step 7: Monitor & Manage

### Check Logs:

```bash
# Backend logs
tail -50 /home/ec2-user/consultancy_AI_agent/backend.log

# Follow logs in real-time
tail -f /home/ec2-user/consultancy_AI_agent/backend.log

# Frontend logs
tail -50 /home/ec2-user/consultancy_AI_agent/frontend.log
```

### Check Status:

```bash
# See if processes are running
ps aux | grep -E "cloud_server|streamlit"

# Check ports
netstat -tlnp | grep -E "8000|8501"

# Or use lsof
lsof -i :8000
lsof -i :8501
```

### Stop Services:

```bash
# Stop backend
kill $(cat /home/ec2-user/consultancy_AI_agent/backend.pid)

# Stop frontend
kill $(cat /home/ec2-user/consultancy_AI_agent/frontend.pid)

# Or kill by name
pkill -f cloud_server.py
pkill -f streamlit
```

### Restart Services:

```bash
# Stop first
pkill -f cloud_server.py
pkill -f streamlit

# Start again
cd /home/ec2-user/consultancy_AI_agent
source venv/bin/activate
export GOOGLE_API_KEY="your-key"

nohup python3 app/cloud_server.py > backend.log 2>&1 &
nohup streamlit run app/ui.py --server.port 8501 --server.address 0.0.0.0 > frontend.log 2>&1 &
```

---

## 🔄 Step 8: Auto-Start on Reboot (Optional)

### Create Systemd Services:

**Backend Service:**
```bash
sudo tee /etc/systemd/system/consulting-backend.service > /dev/null <<EOF
[Unit]
Description=Construction Consulting Backend
After=network.target

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/home/ec2-user/consultancy_AI_agent
Environment="GOOGLE_API_KEY=your-api-key-here"
ExecStart=/home/ec2-user/consultancy_AI_agent/venv/bin/python3 app/cloud_server.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
```

**Frontend Service:**
```bash
sudo tee /etc/systemd/system/consulting-frontend.service > /dev/null <<EOF
[Unit]
Description=Construction Consulting Frontend
After=network.target consulting-backend.service

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/home/ec2-user/consultancy_AI_agent
ExecStart=/home/ec2-user/consultancy_AI_agent/venv/bin/streamlit run app/ui.py --server.port 8501 --server.address 0.0.0.0
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
```

**Enable and Start:**
```bash
# Reload systemd
sudo systemctl daemon-reload

# Enable services
sudo systemctl enable consulting-backend
sudo systemctl enable consulting-frontend

# Start services
sudo systemctl start consulting-backend
sudo systemctl start consulting-frontend

# Check status
sudo systemctl status consulting-backend
sudo systemctl status consulting-frontend
```

**Manage Services:**
```bash
# Stop
sudo systemctl stop consulting-backend
sudo systemctl stop consulting-frontend

# Start
sudo systemctl start consulting-backend
sudo systemctl start consulting-frontend

# Restart
sudo systemctl restart consulting-backend
sudo systemctl restart consulting-frontend

# View logs
sudo journalctl -u consulting-backend -f
sudo journalctl -u consulting-frontend -f
```

---

## 🔒 Step 9: Security Best Practices

### 1. Use Environment Variables:

```bash
# Create .env file (never commit to git!)
cat > /home/ec2-user/consultancy_AI_agent/.env << EOF
GOOGLE_API_KEY=your-actual-key
EOF

# Secure it
chmod 600 /home/ec2-user/consultancy_AI_agent/.env
```

### 2. Restrict Security Groups:

- Only open port 22 to your IP
- Consider using Application Load Balancer
- Use HTTPS in production

### 3. Keep System Updated:

```bash
# Regular updates
sudo yum update -y

# Update Python packages
cd /home/ec2-user/consultancy_AI_agent
source venv/bin/activate
pip install --upgrade -r requirements.txt
```

---

## 🆘 Troubleshooting

### Issue: "ModuleNotFoundError"

```bash
# Make sure venv is activated
source /home/ec2-user/consultancy_AI_agent/venv/bin/activate

# Reinstall packages
pip install --no-cache-dir -r requirements.txt
```

### Issue: "Port already in use"

```bash
# Find process using port
lsof -i :8000  # or :8501

# Kill it
kill -9 <PID>
```

### Issue: "Cannot connect from browser"

```bash
# Check security groups in AWS console
# Make sure ports 8000 and 8501 are open

# Check if services are running
ps aux | grep -E "cloud_server|streamlit"

# Check firewall (if any)
sudo iptables -L
```

### Issue: "GOOGLE_API_KEY not set"

```bash
# Set it
export GOOGLE_API_KEY="your-key"

# Or add to .bashrc
echo 'export GOOGLE_API_KEY="your-key"' >> ~/.bashrc
source ~/.bashrc
```

### Issue: "No space left on device"

```bash
# Run cleanup
cd /home/ec2-user/consultancy_AI_agent
bash ec2_analyze_and_cleanup.sh
```

### Issue: "Semantic search not working"

```bash
# Check if model downloaded
ls -lh ~/.cache/torch/sentence_transformers/

# Check logs
tail -100 backend.log | grep -E "semantic|embedding"

# Reinstall
pip install --force-reinstall sentence-transformers
```

---

## 📝 Quick Reference Commands

### Start Everything:
```bash
cd /home/ec2-user/consultancy_AI_agent
source venv/bin/activate
export GOOGLE_API_KEY="your-key"
nohup python3 app/cloud_server.py > backend.log 2>&1 &
nohup streamlit run app/ui.py --server.port 8501 --server.address 0.0.0.0 > frontend.log 2>&1 &
```

### Stop Everything:
```bash
pkill -f cloud_server.py
pkill -f streamlit
```

### Check Status:
```bash
ps aux | grep -E "cloud_server|streamlit"
tail -20 backend.log
tail -20 frontend.log
```

### Access URLs:
```
Frontend: http://YOUR-EC2-IP:8501
API: http://YOUR-EC2-IP:8000
Docs: http://YOUR-EC2-IP:8000/docs
```

---

## ✅ Deployment Checklist

- [ ] EC2 instance running
- [ ] SSH access working
- [ ] Python 3.8+ installed
- [ ] Virtual environment created
- [ ] All packages installed
- [ ] Gemini API key obtained
- [ ] API key set in environment
- [ ] Security groups configured (ports 8000, 8501)
- [ ] Backend started and running
- [ ] Frontend started and running
- [ ] Can access from browser
- [ ] Test search working
- [ ] Test Gemini AI working
- [ ] Logs are being written
- [ ] (Optional) Systemd services configured

---

## 🎉 You're Live on EC2!

Your Construction Consulting AI Agent is now running on AWS EC2 and accessible from anywhere!

**Access it at:** `http://YOUR-EC2-IP:8501`

**Next Steps:**
1. Share the URL with users
2. Monitor logs regularly
3. Set up monitoring (CloudWatch)
4. Consider adding SSL/HTTPS
5. Set up backups

**Questions?** Check the documentation or logs!
