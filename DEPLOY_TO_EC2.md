# 🚀 READY TO DEPLOY TO AWS EC2

Your Construction Consulting AI Agent is ready for EC2 deployment!

## 📋 Pre-Flight Checklist

- [ ] AWS EC2 instance launched (t2.micro or larger recommended)
- [ ] SSH key pair downloaded
- [ ] Gemini API key ready
- [ ] Project files ready to upload

---

## 🎯 Choose Your Deployment Method

### Method 1: Quick Start (Recommended for First-Time)

**Step-by-step deployment with all checks:**

1. **Upload project to EC2:**
   ```bash
   # From your local machine
   cd /Users/maryamnawas/Desktop
   scp -i /path/to/your-key.pem -r consultancy_AI_agent ec2-user@your-ec2-ip:~/
   ```

2. **SSH into EC2:**
   ```bash
   ssh -i /path/to/your-key.pem ec2-user@your-ec2-ip
   ```

3. **Run the quick start script:**
   ```bash
   cd ~/consultancy_AI_agent
   chmod +x ec2_quick_start.sh
   ./ec2_quick_start.sh
   ```

4. **Configure Security Group (in AWS Console):**
   - Go to EC2 → Security Groups
   - Add Inbound Rules:
     - Port 8000 (TCP) - Source: 0.0.0.0/0
     - Port 8501 (TCP) - Source: 0.0.0.0/0

5. **Access your app:**
   - Streamlit: `http://your-ec2-ip:8501`
   - API: `http://your-ec2-ip:8000/docs`

---

### Method 2: Manual Deployment

**For advanced users or troubleshooting:**

See detailed guide: `EC2_DEPLOYMENT.md`

---

### Method 3: Production Setup (Systemd)

**For auto-start on boot and production reliability:**

See "Production Setup" section in: `EC2_DEPLOYMENT.md`

---

## 🔍 Quick Verification

Once deployed, test with these commands (on EC2):

```bash
# Test health endpoint
curl http://localhost:8000/health

# Test search
curl -X POST http://localhost:8000/search \
  -H "Content-Type: application/json" \
  -d '{"query": "concrete cracking", "top_k": 3}'

# Check running processes
ps aux | grep -E "(uvicorn|streamlit)"

# View logs
tail -f backend.log
tail -f frontend.log
```

---

## 📊 What Gets Deployed

### Backend (FastAPI on port 8000)
- `/health` - Health check
- `/search` - Semantic search with fallback
- `/chat` - AI chat with context
- `/docs` - Swagger API documentation

### Frontend (Streamlit on port 8501)
- Web UI for searching cases
- AI chat interface
- Case details and recommendations

### Data & Models
- `cases.csv` - Construction case database
- Sentence Transformers - Semantic search embeddings
- Google Gemini AI - Chat and recommendations

---

## 🎯 EC2 Instance Recommendations

### Development/Testing:
- **t2.micro** (1 vCPU, 1 GB RAM) - Free tier eligible
- **t3.micro** (2 vCPU, 1 GB RAM) - Better performance

### Production:
- **t3.small** (2 vCPU, 2 GB RAM) - Recommended
- **t3.medium** (2 vCPU, 4 GB RAM) - High traffic

### Operating System:
- Amazon Linux 2023 (recommended)
- Ubuntu 22.04 LTS (also supported)

---

## 🔐 Security Group Configuration

**Required Inbound Rules:**

| Type       | Protocol | Port | Source    | Description           |
|------------|----------|------|-----------|-----------------------|
| SSH        | TCP      | 22   | Your IP   | SSH access            |
| Custom TCP | TCP      | 8000 | 0.0.0.0/0 | FastAPI Backend       |
| Custom TCP | TCP      | 8501 | 0.0.0.0/0 | Streamlit Frontend    |

**Note:** For production, restrict sources to specific IP ranges instead of 0.0.0.0/0

---

## 📁 Files Included for EC2

- `EC2_DEPLOYMENT.md` - Comprehensive deployment guide
- `ec2_quick_start.sh` - Automated setup script
- `requirements.txt` - Python dependencies
- `app/cloud_server.py` - FastAPI backend
- `app/ui.py` - Streamlit frontend
- `app/semantic_search.py` - Search engine
- `data/cases.csv` - Case database

---

## 🐛 Troubleshooting

### Can't access from browser?
1. Check security group has ports 8000, 8501 open
2. Verify services running: `ps aux | grep -E "(uvicorn|streamlit)"`
3. Check logs: `tail -f backend.log frontend.log`
4. Test locally on EC2: `curl http://localhost:8000/health`

### Services not starting?
1. Check API key is set: `echo $GEMINI_API_KEY`
2. Verify venv activated: `which python` should show venv path
3. Check for errors: `cat backend.log` or `cat frontend.log`
4. Reinstall dependencies: `pip install -r requirements.txt --force-reinstall`

### Port already in use?
```bash
# Find what's using the port
sudo lsof -i :8000
sudo lsof -i :8501

# Kill the process
sudo kill -9 <PID>
```

---

## 💰 Cost Estimation

### t2.micro (Free Tier)
- **Cost:** $0 for first 750 hours/month (first 12 months)
- **After:** ~$8.50/month
- **Good for:** Development, testing, low traffic

### t3.small
- **Cost:** ~$15/month
- **Good for:** Production, moderate traffic

### Additional Costs:
- **Data Transfer:** First 1 GB/month free, then $0.09/GB
- **Storage:** 8 GB SSD: ~$0.80/month
- **API Calls:** Gemini API (check Google pricing)

---

## 📚 Additional Documentation

- `README.md` - Project overview
- `RUN_AND_TEST_GUIDE.md` - Local testing guide
- `DOCUMENTATION_INDEX.md` - Complete documentation index
- `AWS_EC2_DEPLOYMENT_GUIDE.md` - Alternative deployment guide

---

## 🎉 Next Steps After Deployment

1. **Test the application** - Try search and chat features
2. **Monitor logs** - Keep an eye on backend.log and frontend.log
3. **Set up systemd** - For production auto-start (see EC2_DEPLOYMENT.md)
4. **Add SSL/HTTPS** - Use nginx reverse proxy with Let's Encrypt
5. **Monitor costs** - Check AWS billing dashboard regularly
6. **Backup data** - Regularly backup your cases.csv

---

## 🆘 Need Help?

1. Check logs first: `tail -f backend.log frontend.log`
2. Review `EC2_DEPLOYMENT.md` for detailed troubleshooting
3. Test endpoints with curl commands (see EC2_DEPLOYMENT.md)
4. Verify security group configuration
5. Check API key is set correctly

---

## 🚀 You're Ready!

Everything is prepared for EC2 deployment. Just follow the steps above and you'll have your Construction Consulting AI Agent running in the cloud!

**Estimated setup time:** 15-20 minutes

Good luck! 🎯
