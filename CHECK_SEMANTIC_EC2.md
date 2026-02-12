# 🔍 Checking Semantic Search on EC2

## Method 1: Quick Check via SSH

```bash
# SSH into EC2
ssh -i ~/Downloads/construction-key.pem ec2-user@16.16.193.209

# Check if sentence-transformers is installed
python3 -c "import sentence_transformers; print('✅ Semantic search installed!')"

# Check version
python3 -c "from sentence_transformers import __version__; print(f'Version: {__version__}')"

# Check if scikit-learn is installed
python3 -c "import sklearn; print('✅ scikit-learn installed!')"
```

**Expected Output:**
```
✅ Semantic search installed!
Version: 5.2.2
✅ scikit-learn installed!
```

**If Not Installed:**
```
ModuleNotFoundError: No module named 'sentence_transformers'
```

---

## Method 2: Check via API Health Endpoint

```bash
# Test the health endpoint
curl http://16.16.193.209:8000/

# Expected response:
# {
#   "status": "Construction Consulting API is running",
#   "cases_loaded": 50
# }
```

If the server loads 50 cases, it means embeddings are working!

---

## Method 3: Test Semantic Search via API

```bash
# Test with a semantic query
curl -X POST http://16.16.193.209:8000/chat \
  -H "Content-Type: application/json" \
  -d '{
    "session_id": "test",
    "message": "circuit keeps disconnecting",
    "search_method": "semantic"
  }'
```

**If semantic search is working:**
- Returns high-quality matches (e.g., "MCB tripping" for "disconnecting")
- Response has `"search_method": "semantic"` in JSON

**If NOT working:**
- Falls back to keyword search
- Logs show: "⚠️ Semantic search not available"

---

## Method 4: Check Server Logs

```bash
# If server running with PM2
pm2 logs construction-api

# If running with nohup
tail -f server.log

# Or check process output
ps aux | grep python
```

**Look for these log messages:**

✅ **Semantic Search Working:**
```
✅ Loaded 50 cases from ../data/cases.csv
🔄 Initializing semantic search engine...
✅ Model loaded: all-MiniLM-L6-v2
📦 Loading cached embeddings...
✅ Loaded 50 cached embeddings
✅ Semantic search engine ready
```

❌ **Semantic Search NOT Working:**
```
⚠️ Semantic search not available, falling back to simple search
❌ Error loading cases or initializing search: No module named 'sentence_transformers'
```

---

## Method 5: Check Installed Packages

```bash
# List all installed packages
pip list | grep -E "(sentence|transformers|scikit)"

# Expected output:
# scikit-learn           1.6.1
# sentence-transformers  5.2.2
# transformers           5.1.0
```

---

## Method 6: Check Embeddings Cache File

```bash
# Check if embeddings are cached
ls -lh data/embeddings_*.pkl

# Expected output:
# -rw-r--r-- 1 ec2-user ec2-user 1.5M Feb 9 12:34 embeddings_all-MiniLM-L6-v2.pkl
```

If this file exists (~1-2MB), embeddings are generated and cached!

---

## Complete Verification Script

Save this as `check_semantic.sh` on EC2:

```bash
#!/bin/bash

echo "🔍 Checking Semantic Search Installation..."
echo ""

# Check 1: Python packages
echo "1️⃣ Checking Python packages..."
python3 -c "import sentence_transformers; print('✅ sentence-transformers installed')" 2>/dev/null || echo "❌ sentence-transformers NOT installed"
python3 -c "import sklearn; print('✅ scikit-learn installed')" 2>/dev/null || echo "❌ scikit-learn NOT installed"
python3 -c "import torch; print('✅ torch installed')" 2>/dev/null || echo "❌ torch NOT installed"
echo ""

# Check 2: Model cache
echo "2️⃣ Checking model cache..."
if [ -d "$HOME/.cache/huggingface/hub" ]; then
    echo "✅ HuggingFace cache exists"
    du -sh $HOME/.cache/huggingface/hub 2>/dev/null | head -1
else
    echo "❌ No model cache found"
fi
echo ""

# Check 3: Embeddings cache
echo "3️⃣ Checking embeddings cache..."
if ls data/embeddings_*.pkl 1> /dev/null 2>&1; then
    echo "✅ Embeddings cache found:"
    ls -lh data/embeddings_*.pkl
else
    echo "❌ No embeddings cache found"
fi
echo ""

# Check 4: API server
echo "4️⃣ Checking API server..."
if curl -s http://localhost:8000/ > /dev/null 2>&1; then
    echo "✅ API server is running"
    curl -s http://localhost:8000/ | python3 -m json.tool
else
    echo "❌ API server not responding"
fi
echo ""

# Check 5: Test semantic search
echo "5️⃣ Testing semantic search endpoint..."
curl -s -X POST http://localhost:8000/chat \
  -H "Content-Type: application/json" \
  -d '{"session_id":"test","message":"test","search_method":"semantic"}' \
  | python3 -c "import sys, json; data=json.load(sys.stdin); print(f'Search method: {data.get(\"search_method\", \"N/A\")}')"

echo ""
echo "✨ Check complete!"
```

**Run it:**
```bash
chmod +x check_semantic.sh
./check_semantic.sh
```

---

## Quick Install if Missing

If semantic search is NOT installed:

```bash
# Install from requirements.txt
pip install -r requirements.txt

# Or install individually
pip install sentence-transformers scikit-learn

# Restart server
pkill -f cloud_server.py
cd app && python cloud_server.py
```

---

## Summary of Checks

| Check | Command | Expected Result |
|-------|---------|-----------------|
| **Package installed** | `python3 -c "import sentence_transformers"` | No error |
| **API running** | `curl http://localhost:8000/` | JSON response |
| **Embeddings cached** | `ls data/embeddings_*.pkl` | File exists (~1-2MB) |
| **Server logs** | `tail -f server.log` | "✅ Semantic search engine ready" |
| **Semantic query** | `curl POST /chat with search_method=semantic` | High-quality results |

---

## Troubleshooting

### If Package Not Installed:
```bash
pip install sentence-transformers scikit-learn
```

### If Model Not Downloaded:
```bash
# Pre-download the model
python3 -c "from sentence_transformers import SentenceTransformer; SentenceTransformer('all-MiniLM-L6-v2')"
```

### If Embeddings Not Generated:
```bash
# Delete old cache and restart server
rm data/embeddings_*.pkl
cd app && python cloud_server.py
# Wait 10-20 seconds for embeddings to generate
```

### If Server Not Starting:
```bash
# Check Python version (need 3.8+)
python3 --version

# Check for errors
cd app
python cloud_server.py
# Read error messages
```

---

## After Verification

Once you confirm semantic search is working, test with real queries (see next section)! 🚀
