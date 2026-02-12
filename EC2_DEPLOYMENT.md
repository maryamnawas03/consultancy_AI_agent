# AWS EC2 Deployment Guide

## Quick Start - Running on EC2

### 1. Connect to Your EC2 Instance

```bash
# SSH into your EC2 instance
ssh -i /path/to/your-key.pem ec2-user@your-ec2-public-ip

# Or for Ubuntu instances:
ssh -i /path/to/your-key.pem ubuntu@your-ec2-public-ip
```

### 2. Upload Your Project to EC2

**Option A: Using SCP (from your local machine)**
```bash
# Navigate to your project directory locally
cd /Users/maryamnawas/Desktop

# Upload the entire project
scp -i /path/to/your-key.pem -r consultancy_AI_agent ec2-user@your-ec2-ip:~/
```

**Option B: Using Git (on EC2)**
```bash
# SSH into EC2, then:
git clone your-repository-url
cd consultancy_AI_agent
```

**Option C: Using rsync (recommended for updates)**
```bash
# From local machine
rsync -avz -e "ssh -i /path/to/your-key.pem" \
  --exclude 'venv' --exclude '__pycache__' --exclude '*.pyc' \
  consultancy_AI_agent/ ec2-user@your-ec2-ip:~/consultancy_AI_agent/
```

### 3. Initial EC2 Setup

```bash
# Update system packages
sudo yum update -y  # Amazon Linux
# OR
sudo apt update && sudo apt upgrade -y  # Ubuntu

# Install Python 3.8+ (if not already installed)
sudo yum install python3 python3-pip -y  # Amazon Linux
# OR
sudo apt install python3 python3-pip python3-venv -y  # Ubuntu

# Install system dependencies
sudo yum install gcc python3-devel -y  # Amazon Linux
# OR
sudo apt install build-essential python3-dev -y  # Ubuntu
```

### 4. Set Up the Application

```bash
# Navigate to project directory
cd ~/consultancy_AI_agent

# Create virtual environment
python3 -m venv venv

# Activate virtual environment
source venv/bin/activate

# Upgrade pip
pip install --upgrade pip

# Install dependencies
pip install -r requirements.txt
```

### 5. Configure Environment Variables

```bash
# Set your Gemini API key (REQUIRED)
export GEMINI_API_KEY="your-actual-api-key-here"

# Or set Google API key if using that name
export GOOGLE_API_KEY="your-actual-api-key-here"

# Make it permanent by adding to ~/.bashrc
echo 'export GEMINI_API_KEY="your-actual-api-key-here"' >> ~/.bashrc
source ~/.bashrc
```

### 6. Configure EC2 Security Group

**CRITICAL: Open required ports in AWS Console**

1. Go to AWS Console → EC2 → Security Groups
2. Select your instance's security group
3. Add Inbound Rules:
   - **Port 8000** (FastAPI Backend) - Custom TCP, Source: 0.0.0.0/0 or your IP
   - **Port 8501** (Streamlit Frontend) - Custom TCP, Source: 0.0.0.0/0 or your IP
   - **Port 22** (SSH) - Should already be open

### 7. Run the Application

**Option A: Simple foreground run (for testing)**

```bash
# Terminal 1: Start Backend
cd ~/consultancy_AI_agent
source venv/bin/activate
export GEMINI_API_KEY="your-key"
python -m uvicorn app.cloud_server:app --host 0.0.0.0 --port 8000

# Terminal 2: Start Frontend (new SSH session)
cd ~/consultancy_AI_agent
source venv/bin/activate
export GEMINI_API_KEY="your-key"
streamlit run app/ui.py --server.port 8501 --server.address 0.0.0.0
```

**Option B: Background with nohup (recommended)**

```bash
# Start both services in background
cd ~/consultancy_AI_agent
source venv/bin/activate

# Start backend
nohup python -m uvicorn app.cloud_server:app --host 0.0.0.0 --port 8000 > backend.log 2>&1 &

# Start frontend
nohup streamlit run app/ui.py --server.port 8501 --server.address 0.0.0.0 > frontend.log 2>&1 &

# Check if running
ps aux | grep -E "(uvicorn|streamlit)"

# View logs
tail -f backend.log
tail -f frontend.log
```

**Option C: Using screen (persistent sessions)**

```bash
# Install screen if needed
sudo yum install screen -y  # Amazon Linux
# OR
sudo apt install screen -y  # Ubuntu

# Start backend in screen
screen -S backend
cd ~/consultancy_AI_agent
source venv/bin/activate
export GEMINI_API_KEY="your-key"
python -m uvicorn app.cloud_server:app --host 0.0.0.0 --port 8000
# Press Ctrl+A, then D to detach

# Start frontend in screen
screen -S frontend
cd ~/consultancy_AI_agent
source venv/bin/activate
export GEMINI_API_KEY="your-key"
streamlit run app/ui.py --server.port 8501 --server.address 0.0.0.0
# Press Ctrl+A, then D to detach

# List screens
screen -ls

# Reattach to a screen
screen -r backend
screen -r frontend
```

### 8. Access Your Application

- **Streamlit UI**: `http://your-ec2-public-ip:8501`
- **FastAPI Backend**: `http://your-ec2-public-ip:8000`
- **API Docs**: `http://your-ec2-public-ip:8000/docs`

### 9. Test the Deployment

```bash
# Test backend health
curl http://your-ec2-public-ip:8000/health

# Test search endpoint
curl -X POST http://your-ec2-public-ip:8000/search \
  -H "Content-Type: application/json" \
  -d '{"query": "concrete cracking", "top_k": 3}'

# Test chat endpoint
curl -X POST http://your-ec2-public-ip:8000/chat \
  -H "Content-Type: application/json" \
  -d '{"query": "How to fix HVAC airflow issues?"}'
```

---

## Production Setup (Systemd Services)

For production, use systemd to auto-start services on boot:

### Create Backend Service

```bash
sudo nano /etc/systemd/system/construction-backend.service
```

**Content:**
```ini
[Unit]
Description=Construction AI Backend (FastAPI)
After=network.target

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/home/ec2-user/consultancy_AI_agent
Environment="PATH=/home/ec2-user/consultancy_AI_agent/venv/bin"
Environment="GEMINI_API_KEY=your-actual-api-key-here"
ExecStart=/home/ec2-user/consultancy_AI_agent/venv/bin/python -m uvicorn app.cloud_server:app --host 0.0.0.0 --port 8000
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

### Create Frontend Service

```bash
sudo nano /etc/systemd/system/construction-frontend.service
```

**Content:**
```ini
[Unit]
Description=Construction AI Frontend (Streamlit)
After=network.target construction-backend.service

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/home/ec2-user/consultancy_AI_agent
Environment="PATH=/home/ec2-user/consultancy_AI_agent/venv/bin"
Environment="GEMINI_API_KEY=your-actual-api-key-here"
ExecStart=/home/ec2-user/consultancy_AI_agent/venv/bin/streamlit run app/ui.py --server.port 8501 --server.address 0.0.0.0
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

### Enable and Start Services

```bash
# Reload systemd
sudo systemctl daemon-reload

# Enable services (start on boot)
sudo systemctl enable construction-backend
sudo systemctl enable construction-frontend

# Start services
sudo systemctl start construction-backend
sudo systemctl start construction-frontend

# Check status
sudo systemctl status construction-backend
sudo systemctl status construction-frontend

# View logs
sudo journalctl -u construction-backend -f
sudo journalctl -u construction-frontend -f

# Restart services
sudo systemctl restart construction-backend
sudo systemctl restart construction-frontend

# Stop services
sudo systemctl stop construction-backend
sudo systemctl stop construction-frontend
```

---

## Troubleshooting

### Check if Services are Running

```bash
# Check processes
ps aux | grep -E "(uvicorn|streamlit)"

# Check ports
sudo netstat -tlnp | grep -E "(8000|8501)"
# OR
sudo ss -tlnp | grep -E "(8000|8501)"
```

### Kill Stuck Processes

```bash
# Find and kill backend
pkill -f uvicorn

# Find and kill frontend
pkill -f streamlit

# Or by PID
ps aux | grep uvicorn
kill -9 <PID>
```

### View Logs

```bash
# If using nohup
tail -f ~/consultancy_AI_agent/backend.log
tail -f ~/consultancy_AI_agent/frontend.log

# If using systemd
sudo journalctl -u construction-backend --since "10 minutes ago"
sudo journalctl -u construction-frontend --since "10 minutes ago"
```

### Common Issues

**1. Port already in use**
```bash
# Find what's using the port
sudo lsof -i :8000
sudo lsof -i :8501

# Kill the process
sudo kill -9 <PID>
```

**2. Permission denied**
```bash
# Make sure files are owned by your user
sudo chown -R ec2-user:ec2-user ~/consultancy_AI_agent
```

**3. Module not found**
```bash
# Reinstall dependencies
cd ~/consultancy_AI_agent
source venv/bin/activate
pip install -r requirements.txt --force-reinstall
```

**4. API key not set**
```bash
# Check environment variable
echo $GEMINI_API_KEY

# Set it temporarily
export GEMINI_API_KEY="your-key"

# Set it permanently
echo 'export GEMINI_API_KEY="your-key"' >> ~/.bashrc
source ~/.bashrc
```

**5. Can't access from browser**
- Verify EC2 security group has ports 8000 and 8501 open
- Check EC2 public IP is correct
- Ensure services are running: `ps aux | grep -E "(uvicorn|streamlit)"`
- Try from EC2 itself: `curl http://localhost:8000/health`

---

## Updating the Application

```bash
# SSH into EC2
ssh -i your-key.pem ec2-user@your-ec2-ip

# Navigate to project
cd ~/consultancy_AI_agent

# Pull updates (if using git)
git pull

# Or upload new files with rsync from local:
# rsync -avz -e "ssh -i /path/to/key.pem" \
#   consultancy_AI_agent/ ec2-user@ec2-ip:~/consultancy_AI_agent/

# Activate venv
source venv/bin/activate

# Update dependencies if requirements.txt changed
pip install -r requirements.txt --upgrade

# Restart services
sudo systemctl restart construction-backend
sudo systemctl restart construction-frontend

# Or if using nohup:
pkill -f uvicorn
pkill -f streamlit
nohup python -m uvicorn app.cloud_server:app --host 0.0.0.0 --port 8000 > backend.log 2>&1 &
nohup streamlit run app/ui.py --server.port 8501 --server.address 0.0.0.0 > frontend.log 2>&1 &
```

---

## Security Best Practices

1. **Use HTTPS**: Set up a reverse proxy (nginx) with SSL certificate
2. **Restrict IP access**: Limit security group rules to your IP ranges
3. **Use IAM roles**: Instead of hardcoding API keys
4. **Enable CloudWatch**: Monitor logs and metrics
5. **Regular updates**: Keep system packages and dependencies updated
6. **Firewall**: Configure EC2 firewall for additional security

---

## Cost Optimization

- Use **t2.micro** or **t3.micro** instances (free tier eligible)
- Stop instance when not in use
- Use **spot instances** for development
- Monitor data transfer costs

---

## Quick Reference Commands

```bash
# Start everything
cd ~/consultancy_AI_agent && source venv/bin/activate
nohup python -m uvicorn app.cloud_server:app --host 0.0.0.0 --port 8000 > backend.log 2>&1 &
nohup streamlit run app/ui.py --server.port 8501 --server.address 0.0.0.0 > frontend.log 2>&1 &

# Stop everything
pkill -f uvicorn && pkill -f streamlit

# Check status
ps aux | grep -E "(uvicorn|streamlit)"
curl http://localhost:8000/health

# View logs
tail -f backend.log
tail -f frontend.log
```

---

## Need Help?

- Check logs first: `tail -f backend.log` or `tail -f frontend.log`
- Verify API key is set: `echo $GEMINI_API_KEY`
- Test locally on EC2: `curl http://localhost:8000/health`
- Check security groups in AWS Console
- Ensure processes are running: `ps aux | grep -E "(uvicorn|streamlit)"`
