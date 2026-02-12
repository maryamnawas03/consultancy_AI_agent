#!/bin/bash

# EC2 Quick Start Script
# This script sets up and runs the Construction AI Agent on EC2

set -e  # Exit on error

echo "==================================="
echo "Construction AI Agent - EC2 Setup"
echo "==================================="

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if running on EC2
if [ ! -f /sys/hypervisor/uuid ] || ! grep -q ec2 /sys/hypervisor/uuid 2>/dev/null; then
    echo -e "${YELLOW}Warning: This doesn't appear to be an EC2 instance${NC}"
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# 1. Update system
echo -e "\n${GREEN}Step 1: Updating system packages...${NC}"
if [ -f /etc/redhat-release ]; then
    sudo yum update -y
    sudo yum install -y python3 python3-pip gcc python3-devel
elif [ -f /etc/debian_version ]; then
    sudo apt update && sudo apt upgrade -y
    sudo apt install -y python3 python3-pip python3-venv build-essential python3-dev
fi

# 2. Navigate to project directory
echo -e "\n${GREEN}Step 2: Setting up project directory...${NC}"
PROJECT_DIR="$HOME/consultancy_AI_agent"

if [ ! -d "$PROJECT_DIR" ]; then
    echo -e "${RED}Error: Project directory not found at $PROJECT_DIR${NC}"
    echo "Please upload your project first using:"
    echo "  scp -i your-key.pem -r consultancy_AI_agent ec2-user@your-ip:~/"
    exit 1
fi

cd "$PROJECT_DIR"

# 3. Create virtual environment
echo -e "\n${GREEN}Step 3: Creating virtual environment...${NC}"
if [ ! -d "venv" ]; then
    python3 -m venv venv
fi

source venv/bin/activate

# 4. Upgrade pip
echo -e "\n${GREEN}Step 4: Upgrading pip...${NC}"
pip install --upgrade pip

# 5. Install dependencies
echo -e "\n${GREEN}Step 5: Installing dependencies...${NC}"
pip install -r requirements.txt

# 6. Check for API key
echo -e "\n${GREEN}Step 6: Checking API key...${NC}"
if [ -z "$GEMINI_API_KEY" ] && [ -z "$GOOGLE_API_KEY" ]; then
    echo -e "${YELLOW}API key not set!${NC}"
    read -p "Enter your Gemini API key: " api_key
    export GEMINI_API_KEY="$api_key"
    echo "export GEMINI_API_KEY='$api_key'" >> ~/.bashrc
    echo -e "${GREEN}API key saved to ~/.bashrc${NC}"
else
    echo -e "${GREEN}API key is set${NC}"
fi

# 7. Check security group configuration
echo -e "\n${YELLOW}Step 7: Security Group Configuration${NC}"
echo "Please ensure your EC2 security group has the following inbound rules:"
echo "  - Port 8000 (TCP) - FastAPI Backend"
echo "  - Port 8501 (TCP) - Streamlit Frontend"
echo "  - Port 22 (TCP) - SSH"
read -p "Have you configured the security group? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Please configure security group in AWS Console before proceeding${NC}"
    exit 1
fi

# 8. Start services
echo -e "\n${GREEN}Step 8: Starting services...${NC}"

# Kill existing processes
pkill -f uvicorn 2>/dev/null || true
pkill -f streamlit 2>/dev/null || true

# Start backend
echo "Starting FastAPI backend on port 8000..."
nohup python -m uvicorn app.cloud_server:app --host 0.0.0.0 --port 8000 > backend.log 2>&1 &
BACKEND_PID=$!

# Wait a bit for backend to start
sleep 3

# Start frontend
echo "Starting Streamlit frontend on port 8501..."
nohup streamlit run app/ui.py --server.port 8501 --server.address 0.0.0.0 > frontend.log 2>&1 &
FRONTEND_PID=$!

# Wait for services to start
sleep 5

# 9. Verify services
echo -e "\n${GREEN}Step 9: Verifying services...${NC}"

if ps -p $BACKEND_PID > /dev/null; then
    echo -e "${GREEN}✓ Backend is running (PID: $BACKEND_PID)${NC}"
else
    echo -e "${RED}✗ Backend failed to start${NC}"
    echo "Check logs: tail -f backend.log"
fi

if ps -p $FRONTEND_PID > /dev/null; then
    echo -e "${GREEN}✓ Frontend is running (PID: $FRONTEND_PID)${NC}"
else
    echo -e "${RED}✗ Frontend failed to start${NC}"
    echo "Check logs: tail -f frontend.log"
fi

# Test backend health
if curl -s http://localhost:8000/health > /dev/null; then
    echo -e "${GREEN}✓ Backend health check passed${NC}"
else
    echo -e "${YELLOW}⚠ Backend health check failed (may still be starting)${NC}"
fi

# 10. Display access information
echo -e "\n${GREEN}==================================="
echo "Setup Complete!"
echo "===================================${NC}"

# Get public IP
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || echo "your-ec2-ip")

echo -e "\n${GREEN}Access your application:${NC}"
echo "  Streamlit UI:    http://$PUBLIC_IP:8501"
echo "  FastAPI Backend: http://$PUBLIC_IP:8000"
echo "  API Docs:        http://$PUBLIC_IP:8000/docs"

echo -e "\n${GREEN}View logs:${NC}"
echo "  Backend:  tail -f $PROJECT_DIR/backend.log"
echo "  Frontend: tail -f $PROJECT_DIR/frontend.log"

echo -e "\n${GREEN}Manage services:${NC}"
echo "  Check status: ps aux | grep -E '(uvicorn|streamlit)'"
echo "  Stop backend: kill $BACKEND_PID"
echo "  Stop frontend: kill $FRONTEND_PID"
echo "  Stop all: pkill -f uvicorn && pkill -f streamlit"

echo -e "\n${GREEN}Test endpoints:${NC}"
echo "  curl http://localhost:8000/health"
echo "  curl -X POST http://localhost:8000/search -H 'Content-Type: application/json' -d '{\"query\": \"concrete\", \"top_k\": 3}'"

echo -e "\n${YELLOW}Note: Services are running in background${NC}"
echo "They will stop if you log out. For persistent services, use systemd."
echo "See EC2_DEPLOYMENT.md for systemd setup instructions."

echo -e "\n${GREEN}Setup complete!${NC}"
