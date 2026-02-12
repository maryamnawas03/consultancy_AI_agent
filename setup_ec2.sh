#!/bin/bash

# ULTIMATE EC2 SETUP SCRIPT - NO SEMANTIC SEARCH
# Minimal dependencies, maximum efficiency

set -e

cd ~/consultancy_AI_agent

echo "============================================"
echo "🚀 Construction AI Agent - EC2 Setup"
echo "============================================"
echo ""

# Step 1: Update system
echo "📦 Installing system dependencies..."
sudo yum update -y 2>/dev/null || sudo apt update -y 2>/dev/null
sudo yum install -y python3 python3-pip gcc 2>/dev/null || sudo apt install -y python3 python3-pip build-essential 2>/dev/null

# Step 2: Create venv
echo "🐍 Creating virtual environment..."
rm -rf venv 2>/dev/null || true
python3 -m venv venv

# Step 3: Activate and upgrade pip
source venv/bin/activate
pip install --upgrade pip setuptools wheel -q

# Step 4: Install dependencies
echo "📥 Installing Python packages..."
pip install -q -r requirements.txt

# Step 5: Set API keys
export GEMINI_API_KEY="AIzaSyBOL1MerZ-WZrukiFxhMGRe4UNBcGxdC6I"
export GOOGLE_API_KEY="AIzaSyBOL1MerZ-WZrukiFxhMGRe4UNBcGxdC6I"

if ! grep -q "GEMINI_API_KEY" ~/.bashrc; then
    echo 'export GEMINI_API_KEY="AIzaSyBOL1MerZ-WZrukiFxhMGRe4UNBcGxdC6I"' >> ~/.bashrc
    echo 'export GOOGLE_API_KEY="AIzaSyBOL1MerZ-WZrukiFxhMGRe4UNBcGxdC6I"' >> ~/.bashrc
fi

# Step 6: Kill existing processes
pkill -f uvicorn 2>/dev/null || true
pkill -f streamlit 2>/dev/null || true
sleep 2

# Step 7: Clear logs
> backend.log
> frontend.log

# Step 8: Start backend
echo "🚀 Starting backend..."
GEMINI_API_KEY="AIzaSyBOL1MerZ-WZrukiFxhMGRe4UNBcGxdC6I" \
nohup python -m uvicorn app.cloud_server:app --host 0.0.0.0 --port 8000 > backend.log 2>&1 &

sleep 5

# Step 9: Start frontend
echo "🚀 Starting frontend..."
GEMINI_API_KEY="AIzaSyBOL1MerZ-WZrukiFxhMGRe4UNBcGxdC6I" \
nohup streamlit run app/ui.py --server.port 8501 --server.address 0.0.0.0 > frontend.log 2>&1 &

sleep 5

# Step 10: Verify
echo ""
echo "✅ SERVICES STARTED"
echo "============================================"
ps aux | grep -E "(uvicorn|streamlit)" | grep -v grep
echo ""

PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || echo "YOUR_PUBLIC_IP")

echo "📍 Access at:"
echo "   http://$PUBLIC_IP:8501"
echo ""
echo "📊 View logs:"
echo "   tail -f backend.log"
echo "   tail -f frontend.log"
echo "============================================"
