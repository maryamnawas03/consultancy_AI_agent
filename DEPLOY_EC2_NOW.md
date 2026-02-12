# Deploy Semantic Search on EC2 - Step by Step

## Current Status
✅ Disk space cleaned up: 4.7GB available (42% used)
✅ Code files uploaded to EC2
⏳ Dependencies need to be installed
⏳ Backend server needs to be started
⏳ Semantic search needs to be tested

## Step 1: Install Python Dependencies

```bash
# Navigate to your project directory
cd consultancy_AI_agent

# Install all dependencies including sentence-transformers
pip3 install -r requirements.txt

# This will install:
# - sentence-transformers (for semantic search)
# - scikit-learn (for similarity calculations)
# - fastapi, uvicorn (for the backend API)
# - pandas (for data handling)
# - all other required packages
```

**Note:** The first time you install sentence-transformers, it will download the embedding model (~500MB). This is a one-time download and will be cached.

## Step 2: Verify Installation

```bash
# Check if sentence-transformers is installed
python3 -c "from sentence_transformers import SentenceTransformer; print('✓ sentence-transformers installed')"

# Check if the model can be loaded
python3 -c "from sentence_transformers import SentenceTransformer; model = SentenceTransformer('all-MiniLM-L6-v2'); print('✓ Model loaded successfully')"

# Verify the cases.csv file exists
ls -lh data/cases.csv
```

## Step 3: Start the Backend Server

### Option A: Run in foreground (for testing)
```bash
cd ~/consultancy_AI_agent
python3 app/cloud_server.py
```

### Option B: Run in background (recommended for production)
```bash
cd ~/consultancy_AI_agent
nohup python3 app/cloud_server.py > server.log 2>&1 &

# Get the process ID
ps aux | grep cloud_server.py

# To view logs
tail -f server.log
```

### Option C: Run with uvicorn (alternative)
```bash
cd ~/consultancy_AI_agent
uvicorn app.cloud_server:app --host 0.0.0.0 --port 8000 --reload
```

## Step 4: Test the API Locally (from EC2)

```bash
# Test 1: Check if server is running
curl http://localhost:8000/

# Test 2: Simple semantic search
curl -X POST "http://localhost:8000/search" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "What permits are required for commercial construction?",
    "search_method": "semantic"
  }'

# Test 3: Check if semantic search is working (should see "search_method": "semantic")
curl -s -X POST "http://localhost:8000/search" \
  -H "Content-Type: application/json" \
  -d '{"query": "building permits", "search_method": "semantic"}' | grep -A 5 '"search_method"'
```

## Step 5: Test from Your Local Machine

Replace `YOUR_EC2_PUBLIC_IP` with your actual EC2 public IP address:

```bash
# Test from your local machine
curl -X POST "http://YOUR_EC2_PUBLIC_IP:8000/search" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "What permits are required for commercial construction?",
    "search_method": "semantic"
  }'
```

## Step 6: Verify Semantic Search is Working

Look for these indicators in the response:

✅ **"search_method": "semantic"** - Confirms semantic search was used
✅ **"best_score": 0.XX** (where XX > 0.3) - High similarity score
✅ **"total_results": > 0** - Results were found
✅ Response includes relevant case data

Example successful response:
```json
{
  "results": [...],
  "search_method": "semantic",
  "best_score": 0.7234,
  "total_results": 5,
  "fallback_used": false
}
```

## Troubleshooting

### If dependencies fail to install:
```bash
# Update pip first
pip3 install --upgrade pip

# Install with verbose output
pip3 install -r requirements.txt -v
```

### If port 8000 is already in use:
```bash
# Find and kill the process
sudo lsof -i :8000
sudo kill -9 <PID>

# Or use a different port
python3 app/cloud_server.py --port 8001
```

### If semantic search falls back to keyword search:
1. Check server logs for errors
2. Verify sentence-transformers is installed
3. Ensure the model downloaded successfully
4. Check if cases.csv is loaded

### View detailed logs:
```bash
# If running with nohup
tail -f server.log

# If running in terminal, check the console output
```

## Quick Commands Reference

```bash
# Install everything
pip3 install -r requirements.txt

# Start server (background)
cd ~/consultancy_AI_agent && nohup python3 app/cloud_server.py > server.log 2>&1 &

# Test semantic search
curl -X POST "http://localhost:8000/search" -H "Content-Type: application/json" -d '{"query": "building permits", "search_method": "semantic"}'

# View logs
tail -f server.log

# Stop server
pkill -f cloud_server.py
```

## Security Reminder

Make sure your EC2 Security Group allows:
- **Port 8000** (inbound TCP) from your IP address or 0.0.0.0/0
- **Port 22** (SSH) from your IP address

## Next Steps After Deployment

1. Test with various queries (see TEST_QUERIES.md)
2. Monitor server performance and logs
3. Set up automatic restart on reboot (optional)
4. Consider using systemd service for production (optional)

---

**Ready to deploy?** Start with Step 1 above! 🚀
