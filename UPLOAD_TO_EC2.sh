#!/bin/bash

# Script to upload project to EC2
# Run this from your LOCAL machine (Mac)

echo "=================================="
echo "Upload Project to EC2"
echo "=================================="

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Check if we're in the right directory
if [ ! -f "requirements.txt" ] || [ ! -d "app" ]; then
    echo -e "${RED}Error: Please run this from the consultancy_AI_agent directory${NC}"
    echo "Current directory: $(pwd)"
    exit 1
fi

# Get EC2 details from user
echo -e "${YELLOW}Enter your EC2 details:${NC}"
read -p "EC2 Key file path (e.g., ~/Downloads/my-key.pem): " KEY_PATH
read -p "EC2 Public IP: " EC2_IP
read -p "EC2 User (ec2-user or ubuntu): " EC2_USER

# Expand tilde in key path
KEY_PATH="${KEY_PATH/#\~/$HOME}"

# Validate key file exists
if [ ! -f "$KEY_PATH" ]; then
    echo -e "${RED}Error: Key file not found at $KEY_PATH${NC}"
    exit 1
fi

# Ensure key has correct permissions
chmod 400 "$KEY_PATH"

echo -e "\n${GREEN}Uploading project to EC2...${NC}"
echo "This may take a minute..."

# Upload using rsync (excludes venv and cache files)
rsync -avz --progress \
  -e "ssh -i $KEY_PATH -o StrictHostKeyChecking=no" \
  --exclude 'venv' \
  --exclude '__pycache__' \
  --exclude '*.pyc' \
  --exclude '.git' \
  --exclude '.DS_Store' \
  --exclude '*.log' \
  ./ ${EC2_USER}@${EC2_IP}:~/consultancy_AI_agent/

if [ $? -eq 0 ]; then
    echo -e "\n${GREEN}✓ Upload successful!${NC}"
    
    echo -e "\n${GREEN}Next steps:${NC}"
    echo "1. SSH into EC2:"
    echo "   ssh -i $KEY_PATH ${EC2_USER}@${EC2_IP}"
    echo ""
    echo "2. Run the setup script:"
    echo "   cd ~/consultancy_AI_agent"
    echo "   chmod +x ec2_quick_start.sh"
    echo "   ./ec2_quick_start.sh"
    echo ""
    echo "3. Configure Security Group (if not done):"
    echo "   - Open ports 8000 and 8501 in AWS Console"
    
    # Ask if user wants to SSH now
    echo ""
    read -p "SSH into EC2 now? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        ssh -i "$KEY_PATH" ${EC2_USER}@${EC2_IP}
    fi
else
    echo -e "\n${RED}✗ Upload failed${NC}"
    echo "Please check:"
    echo "  - Key file path is correct"
    echo "  - EC2 IP is correct"
    echo "  - EC2 instance is running"
    echo "  - Security group allows SSH (port 22)"
    exit 1
fi
