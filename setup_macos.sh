#!/bin/bash
# Quick setup and run script for macOS

echo "🚀 Setting up Construction Consulting AI Agent"
echo "════════════════════════════════════════════════"
echo ""

# Navigate to project
cd /Users/maryamnawas/Desktop/consultancy_AI_agent

echo "Step 1: Creating Python virtual environment..."
/opt/homebrew/bin/python3 -m venv venv

echo "Step 2: Activating virtual environment..."
source venv/bin/activate

echo "Step 3: Installing dependencies..."
pip install --upgrade pip
pip install -r requirements.txt

echo ""
echo "✅ Setup complete!"
echo ""
echo "To activate the environment in the future:"
echo "  source /Users/maryamnawas/Desktop/consultancy_AI_agent/venv/bin/activate"
echo ""
echo "To start the backend:"
echo "  export GOOGLE_API_KEY='your-api-key'"
echo "  python3 app/cloud_server.py"
echo ""
echo "To start the frontend (in a new terminal):"
echo "  source /Users/maryamnawas/Desktop/consultancy_AI_agent/venv/bin/activate"
echo "  streamlit run app/ui.py"
echo ""
