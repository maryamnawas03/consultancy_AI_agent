#!/bin/bash
# Lightweight Installation Script for EC2
# Minimizes disk usage during installation

echo "🚀 Starting lightweight installation..."
echo "================================"

# Check available space
AVAILABLE=$(df / | tail -1 | awk '{print $4}')
echo "📊 Available space: $(df -h / | tail -1 | awk '{print $4}')"

if [ "$AVAILABLE" -lt 2000000 ]; then
    echo "⚠️  WARNING: Less than 2GB available. Installation may fail."
    echo "Run the cleanup script first: bash ec2_cleanup.sh"
    exit 1
fi

echo ""
echo "📦 Step 1: Installing dependencies with minimal cache..."

# Install packages one by one to avoid memory issues
# Using --no-cache-dir to prevent caching downloaded packages

pip install --no-cache-dir --upgrade pip

echo "Installing core packages..."
pip install --no-cache-dir streamlit>=1.29.0
pip install --no-cache-dir fastapi>=0.104.0
pip install --no-cache-dir uvicorn>=0.24.0
pip install --no-cache-dir pandas>=1.5.0
pip install --no-cache-dir requests>=2.28.0
pip install --no-cache-dir markdown>=3.4.0
pip install --no-cache-dir google-generativeai>=0.8.0

echo ""
echo "Installing ML packages (this may take a few minutes)..."
pip install --no-cache-dir scikit-learn>=1.3.0
pip install --no-cache-dir sentence-transformers>=2.2.0

echo ""
echo "✅ Installation complete!"
echo "================================"

# Verify installations
echo "🔍 Verifying installations..."
python3 -c "import streamlit; print('✓ Streamlit')"
python3 -c "import fastapi; print('✓ FastAPI')"
python3 -c "import pandas; print('✓ Pandas')"
python3 -c "import sklearn; print('✓ scikit-learn')"
python3 -c "from sentence_transformers import SentenceTransformer; print('✓ sentence-transformers')"

echo ""
echo "📊 Final disk usage:"
df -h /

echo ""
echo "✅ Ready to start the server!"
echo "Run: python3 app/cloud_server.py"
