#!/bin/bash
# EC2 Cleanup Script - Remove unnecessary files to free up disk space

echo "🧹 Starting EC2 cleanup..."
echo "================================"

# Check current disk usage
echo "📊 Current disk usage:"
df -h /

echo ""
echo "🗑️  Step 1: Cleaning package manager cache..."
sudo yum clean all
sudo rm -rf /var/cache/yum/*

echo ""
echo "🗑️  Step 2: Removing old kernels (keeping current)..."
sudo package-cleanup --oldkernels --count=1 -y 2>/dev/null || echo "package-cleanup not available, skipping"

echo ""
echo "🗑️  Step 3: Cleaning journal logs (keeping last 2 days)..."
sudo journalctl --vacuum-time=2d

echo ""
echo "🗑️  Step 4: Removing temporary files..."
sudo rm -rf /tmp/*
sudo rm -rf /var/tmp/*

echo ""
echo "🗑️  Step 5: Cleaning pip cache..."
rm -rf ~/.cache/pip/*

echo ""
echo "🗑️  Step 6: Removing Docker artifacts (if any)..."
docker system prune -af 2>/dev/null || echo "Docker not installed, skipping"

echo ""
echo "🗑️  Step 7: Removing old log files..."
sudo find /var/log -type f -name "*.log.*" -delete
sudo find /var/log -type f -name "*.gz" -delete
sudo find /var/log -type f -name "*.old" -delete

echo ""
echo "🗑️  Step 8: Finding and removing large unnecessary files..."
echo "Top 20 largest files in /var:"
sudo find /var -type f -size +10M -exec ls -lh {} \; 2>/dev/null | sort -k5 -hr | head -20

echo ""
echo "🗑️  Step 9: Cleaning Python cache files..."
find /home/ec2-user -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null
find /home/ec2-user -type f -name "*.pyc" -delete 2>/dev/null
find /home/ec2-user -type f -name "*.pyo" -delete 2>/dev/null

echo ""
echo "🗑️  Step 10: Removing core dumps..."
sudo rm -rf /var/crash/*
sudo rm -f /core.*

echo ""
echo "✅ Cleanup complete!"
echo "================================"
echo "📊 New disk usage:"
df -h /

echo ""
echo "💾 Disk space freed:"
echo "Run 'df -h' to see the difference"
