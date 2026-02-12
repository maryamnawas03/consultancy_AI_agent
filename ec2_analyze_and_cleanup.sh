#!/bin/bash
# Comprehensive EC2 Disk Analysis and Cleanup Script
# Diagnoses what's taking space and safely removes unnecessary files

set -e

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║     EC2 DISK ANALYSIS & CLEANUP SCRIPT                         ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ============================================================================
# SECTION 1: Current Disk Status
# ============================================================================
echo -e "${BLUE}[1/6] CURRENT DISK STATUS${NC}"
echo "────────────────────────────────────────────────────────────────"
df -h
echo ""
USED_PERCENT=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
AVAILABLE=$(df / | tail -1 | awk '{print $4}')
echo -e "Status: ${YELLOW}${USED_PERCENT}% Used, ${AVAILABLE}KB Available${NC}"
echo ""

# ============================================================================
# SECTION 2: Find Largest Directories
# ============================================================================
echo -e "${BLUE}[2/6] TOP 15 LARGEST DIRECTORIES${NC}"
echo "────────────────────────────────────────────────────────────────"
echo "System-wide largest directories:"
sudo du -h --max-depth=2 / 2>/dev/null | sort -hr | head -15 | awk '{printf "%-40s %s\n", $2, $1}'
echo ""

# Check home directory specifically
echo "Home directory (/home/ec2-user) breakdown:"
du -h --max-depth=2 /home/ec2-user 2>/dev/null | sort -hr | head -10 | awk '{printf "%-40s %s\n", $2, $1}'
echo ""

# ============================================================================
# SECTION 3: Check Python and Package Information
# ============================================================================
echo -e "${BLUE}[3/6] PYTHON DEPENDENCIES ANALYSIS${NC}"
echo "────────────────────────────────────────────────────────────────"

echo "Installed Python packages and their sizes:"
pip list --format=freeze | while read package; do
    pip show ${package%==*} 2>/dev/null | grep -E "^Name:|^Location:|^Version:" | paste -d " " - - - 
done | sort -k3 -h | tail -20 | awk '{printf "%-40s %s\n", $2, $NF}'

echo ""
echo "Python cache size:"
PYTHON_CACHE=$(find /home/ec2-user -type d -name "__pycache__" -exec du -sh {} \; 2>/dev/null | awk '{sum+=$1} END {print sum}')
echo "  __pycache__: ${PYTHON_CACHE:-0B}"

PIP_CACHE=$(du -sh ~/.cache/pip 2>/dev/null | awk '{print $1}')
echo "  pip cache (~/.cache/pip): ${PIP_CACHE:-0B}"

echo ""

# ============================================================================
# SECTION 4: Check Temporary Files
# ============================================================================
echo -e "${BLUE}[4/6] TEMPORARY FILES ANALYSIS${NC}"
echo "────────────────────────────────────────────────────────────────"

TMP_SIZE=$(du -sh /tmp 2>/dev/null | awk '{print $1}')
VAR_TMP_SIZE=$(du -sh /var/tmp 2>/dev/null | awk '{print $1}')
VAR_LOG_SIZE=$(du -sh /var/log 2>/dev/null | awk '{print $1}')

echo "/tmp directory: ${TMP_SIZE:-0B}"
echo "/var/tmp directory: ${VAR_TMP_SIZE:-0B}"
echo "/var/log directory: ${VAR_LOG_SIZE:-0B}"
echo ""

echo "Largest files in /tmp:"
find /tmp -type f -size +1M 2>/dev/null | xargs ls -lh 2>/dev/null | awk '{print $9, $5}' | sort -k2 -hr | head -10
echo ""

echo "Largest files in /var/log:"
find /var/log -type f -size +10M 2>/dev/null | xargs ls -lh 2>/dev/null | awk '{print $9, $5}' | sort -k2 -hr | head -10
echo ""

# ============================================================================
# SECTION 5: Check Application Directory
# ============================================================================
echo -e "${BLUE}[5/6] APPLICATION DIRECTORY ANALYSIS${NC}"
echo "────────────────────────────────────────────────────────────────"

if [ -d "/home/ec2-user/consultancy_AI_agent" ]; then
    echo "Application directory breakdown:"
    du -h --max-depth=2 /home/ec2-user/consultancy_AI_agent 2>/dev/null | sort -hr | head -15
    echo ""
    
    echo "Application directory structure:"
    ls -lh /home/ec2-user/consultancy_AI_agent/ 2>/dev/null || echo "Directory not found"
    echo ""
fi

# ============================================================================
# SECTION 6: Cleanup Menu
# ============================================================================
echo -e "${BLUE}[6/6] CLEANUP OPTIONS${NC}"
echo "────────────────────────────────────────────────────────────────"
echo ""
echo "Which cleanup would you like to perform?"
echo ""
echo "1) Safe Cleanup (recommended - removes only caches)"
echo "2) Aggressive Cleanup (removes caches, logs, temp files)"
echo "3) Full Cleanup (aggressive + removes package manager caches)"
echo "4) Exit (no cleanup)"
echo ""
read -p "Select option (1-4): " cleanup_option

case $cleanup_option in
    1)
        echo ""
        echo -e "${YELLOW}Starting Safe Cleanup...${NC}"
        bash /home/ec2-user/consultancy_AI_agent/ec2_cleanup_safe.sh
        ;;
    2)
        echo ""
        echo -e "${YELLOW}Starting Aggressive Cleanup...${NC}"
        bash /home/ec2-user/consultancy_AI_agent/ec2_cleanup_aggressive.sh
        ;;
    3)
        echo ""
        echo -e "${YELLOW}Starting Full Cleanup...${NC}"
        bash /home/ec2-user/consultancy_AI_agent/ec2_cleanup_full.sh
        ;;
    4)
        echo -e "${GREEN}Exiting without cleanup${NC}"
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid option${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${BLUE}Final Disk Status:${NC}"
df -h /
echo ""
FINAL_AVAILABLE=$(df / | tail -1 | awk '{print $4}')
FREED=$((($FINAL_AVAILABLE - $AVAILABLE) / 1024))
echo -e "${GREEN}Freed approximately: ${FREED}MB${NC}"
