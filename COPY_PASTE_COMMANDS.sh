#!/bin/bash

# COPY-PASTE THESE COMMANDS EXACTLY

# ============================================================
# ON YOUR MAC - Terminal 1
# ============================================================
# Navigate to project
cd /Users/maryamnawas/Desktop/consultancy_AI_agent

# Upload everything to EC2 
scp -i ~/Downloads/construction-key.pem -r . ec2-user@16.16.193.209:~/consultancy_AI_agent/

echo "✅ Upload complete. Now SSH into EC2 and run the setup script."

# ============================================================
# ON EC2 - SSH Terminal
# ============================================================
# SSH into EC2
ssh -i ~/Downloads/construction-key.pem ec2-user@16.16.193.209

# Once you're in EC2, run these commands:
cd ~/consultancy_AI_agent
chmod +x setup_ec2.sh
./setup_ec2.sh

# ============================================================
# WAIT FOR SETUP TO COMPLETE
# Then open browser: http://16.16.193.209:8501
# ============================================================
