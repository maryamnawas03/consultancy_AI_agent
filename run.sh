#!/bin/bash
# Simple script to run the agent on localhost

set -e

PROJECT_DIR="/Users/maryamnawas/Desktop/consultancy_AI_agent"
VENV_DIR="$PROJECT_DIR/venv"

echo "╔════════════════════════════════════════════════════════════╗"
echo "║  🏗️  Construction Consulting AI Agent - Quick Start        ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Check if venv exists
if [ ! -d "$VENV_DIR" ]; then
    echo "❌ Virtual environment not found"
    echo "Run: bash setup_macos.sh"
    exit 1
fi

echo "📋 Checking setup..."
source "$VENV_DIR/bin/activate"

# Check API key
echo ""
if [ -z "$GOOGLE_API_KEY" ]; then
    echo "⚠️  GOOGLE_API_KEY not set"
    echo ""
    echo "Get free key at: https://makersuite.google.com/app/apikey"
    read -p "Enter your API key: " api_key
    if [ ! -z "$api_key" ]; then
        export GOOGLE_API_KEY="$api_key"
        echo "✅ API key set"
    else
        echo "❌ API key required!"
        exit 1
    fi
else
    echo "✅ GOOGLE_API_KEY is set"
fi

echo ""
echo "🚀 Starting system..."
echo ""
echo "Choose what to start:"
echo "1) Backend only (FastAPI on :8000)"
echo "2) Frontend only (Streamlit on :8501)"
echo "3) Both (Backend + Frontend)"
echo ""
read -p "Select (1-3): " choice

case $choice in
    1)
        echo ""
        echo "Starting backend on http://localhost:8000"
        echo "API docs: http://localhost:8000/docs"
        echo ""
        cd "$PROJECT_DIR"
        python3 app/cloud_server.py
        ;;
    2)
        echo ""
        echo "Starting frontend on http://localhost:8501"
        echo ""
        cd "$PROJECT_DIR"
        streamlit run app/ui.py
        ;;
    3)
        echo ""
        echo "Starting both services..."
        echo "Backend: http://localhost:8000"
        echo "Frontend: http://localhost:8501"
        echo "API Docs: http://localhost:8000/docs"
        echo ""
        
        cd "$PROJECT_DIR"
        
        # Start backend in background
        echo "Starting backend..."
        nohup python3 app/cloud_server.py > backend.log 2>&1 &
        BACKEND_PID=$!
        echo "Backend PID: $BACKEND_PID"
        
        # Wait for backend to start
        sleep 5
        
        # Start frontend
        echo "Starting frontend..."
        echo ""
        streamlit run app/ui.py --server.port 8501
        ;;
    *)
        echo "Invalid choice"
        exit 1
        ;;
esac
