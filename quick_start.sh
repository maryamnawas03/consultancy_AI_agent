#!/bin/bash
# Quick Start Script for Construction Consulting AI Agent
# This script sets up and runs the entire system

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  🏗️  Construction Consulting AI Agent - Quick Start        ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""

# ============================================================================
# SECTION 1: Check Prerequisites
# ============================================================================
echo -e "${BLUE}[1/5] Checking Prerequisites${NC}"
echo "────────────────────────────────────────────────────────────"

# Check Python version
PYTHON_VERSION=$(python3 --version 2>&1 | awk '{print $2}')
echo "Python version: $PYTHON_VERSION"

if ! command -v python3 &> /dev/null; then
    echo -e "${RED}❌ Python3 not found!${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Python3 found${NC}"

# Check pip
if ! command -v pip3 &> /dev/null; then
    echo -e "${RED}❌ pip3 not found!${NC}"
    exit 1
fi
echo -e "${GREEN}✅ pip3 found${NC}"

# Check data file
if [ ! -f "data/cases.csv" ]; then
    echo -e "${RED}❌ data/cases.csv not found!${NC}"
    exit 1
fi
echo -e "${GREEN}✅ data/cases.csv found${NC}"

# Check disk space
AVAILABLE=$(df . | tail -1 | awk '{print $4}')
if [ "$AVAILABLE" -lt 2000000 ]; then
    echo -e "${RED}⚠️  WARNING: Less than 2GB available (have: $(df -h . | tail -1 | awk '{print $4}'))${NC}"
    read -p "Continue anyway? (y/n): " continue
    if [ "$continue" != "y" ]; then
        exit 1
    fi
fi
echo -e "${GREEN}✅ Disk space OK${NC}"

echo ""

# ============================================================================
# SECTION 2: Install Dependencies
# ============================================================================
echo -e "${BLUE}[2/5] Installing Dependencies${NC}"
echo "────────────────────────────────────────────────────────────"

echo "Upgrading pip..."
pip3 install --upgrade pip 2>&1 | tail -3

echo ""
echo "Installing required packages..."
echo "(This may take 5-10 minutes on first install)"
echo ""

pip3 install --no-cache-dir -r requirements.txt 2>&1 | grep -E "Successfully|Collecting|ERROR" || true

echo ""
echo -e "${GREEN}✅ Dependencies installed${NC}"

echo ""

# ============================================================================
# SECTION 3: Verify Installation
# ============================================================================
echo -e "${BLUE}[3/5] Verifying Installation${NC}"
echo "────────────────────────────────────────────────────────────"

python3 << 'EOF'
import sys
try:
    import streamlit
    print("✅ streamlit")
    import fastapi
    print("✅ fastapi")
    import pandas as pd
    print("✅ pandas")
    from sentence_transformers import SentenceTransformer
    print("✅ sentence-transformers")
    from sklearn.metrics.pairwise import cosine_similarity
    print("✅ scikit-learn")
    import google.generativeai
    print("✅ google-generativeai")
    print("")
    print("All packages verified successfully!")
except ImportError as e:
    print(f"❌ Missing package: {e}")
    sys.exit(1)
EOF

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Verification failed!${NC}"
    exit 1
fi

echo ""

# ============================================================================
# SECTION 4: Configure API Key
# ============================================================================
echo -e "${BLUE}[4/5] Configuring Gemini API Key${NC}"
echo "────────────────────────────────────────────────────────────"

if [ -z "$GOOGLE_API_KEY" ]; then
    echo -e "${YELLOW}⚠️  GOOGLE_API_KEY environment variable not set${NC}"
    echo ""
    echo "You can get a free API key at:"
    echo "   https://makersuite.google.com/app/apikey"
    echo ""
    read -p "Enter your Gemini API key (or press Enter to skip): " api_key
    
    if [ ! -z "$api_key" ]; then
        export GOOGLE_API_KEY="$api_key"
        echo "API key set ✅"
    else
        echo -e "${YELLOW}⚠️  Skipping API key setup${NC}"
        echo "   You'll need to set it before running:"
        echo "   export GOOGLE_API_KEY='your-key-here'"
    fi
else
    echo -e "${GREEN}✅ GOOGLE_API_KEY already set${NC}"
fi

echo ""

# ============================================================================
# SECTION 5: Start the System
# ============================================================================
echo -e "${BLUE}[5/5] Starting the System${NC}"
echo "────────────────────────────────────────────────────────────"
echo ""

echo "Would you like to start:"
echo "1) Both Backend & Frontend"
echo "2) Backend only (for testing)"
echo "3) Frontend only (if backend already running)"
echo "4) Skip (just show instructions)"
echo ""
read -p "Select (1-4): " start_choice

case $start_choice in
    1)
        echo ""
        echo -e "${YELLOW}Starting both services...${NC}"
        echo ""
        echo "🚀 Backend will start on http://localhost:8000"
        echo "🎨 Frontend will start on http://localhost:8501"
        echo ""
        
        # Start backend in background
        echo "Starting backend..."
        nohup python3 app/cloud_server.py > backend.log 2>&1 &
        BACKEND_PID=$!
        echo "Backend PID: $BACKEND_PID"
        
        # Give backend time to start
        sleep 3
        
        # Start frontend in background
        echo "Starting frontend..."
        nohup streamlit run app/ui.py --server.port 8501 2>&1 | tee frontend.log &
        FRONTEND_PID=$!
        echo "Frontend PID: $FRONTEND_PID"
        
        echo ""
        echo -e "${GREEN}✅ Both services started!${NC}"
        echo ""
        echo "Open your browser to:"
        echo "  🎨 Frontend: http://localhost:8501"
        echo "  📚 API Docs: http://localhost:8000/docs"
        echo ""
        echo "View logs:"
        echo "  Backend:  tail -f backend.log"
        echo "  Frontend: tail -f frontend.log"
        ;;
        
    2)
        echo ""
        echo -e "${YELLOW}Starting backend only...${NC}"
        echo ""
        python3 app/cloud_server.py
        ;;
        
    3)
        echo ""
        echo -e "${YELLOW}Starting frontend only...${NC}"
        echo ""
        streamlit run app/ui.py --server.port 8501
        ;;
        
    4)
        echo ""
        echo -e "${GREEN}✅ Setup complete!${NC}"
        echo ""
        echo "To start manually:"
        echo ""
        echo "Terminal 1 (Backend):"
        echo "  export GOOGLE_API_KEY='your-key-here'"
        echo "  python3 app/cloud_server.py"
        echo ""
        echo "Terminal 2 (Frontend):"
        echo "  streamlit run app/ui.py"
        echo ""
        ;;
        
    *)
        echo "Invalid option"
        exit 1
        ;;
esac

echo ""
echo "📖 For more help, see SETUP_AND_RUN_GUIDE.md"
