#!/bin/bash
# EC2 Aggressive Cleanup - Removes caches, logs, and temp files

echo "🧹 AGGRESSIVE CLEANUP: Removing caches, logs, and temp files"
echo "════════════════════════════════════════════════════════════════"
echo ""

# 1. Python cache files
echo "1️⃣  Cleaning Python cache files..."
find /home/ec2-user -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null
find /home/ec2-user -type f -name "*.pyc" -delete 2>/dev/null
find /home/ec2-user -type f -name "*.pyo" -delete 2>/dev/null
echo "   ✅ Python cache cleaned"

# 2. Pip cache
echo "2️⃣  Cleaning pip cache..."
rm -rf /home/ec2-user/.cache/pip/* 2>/dev/null
echo "   ✅ Pip cache cleaned"

# 3. General cache
echo "3️⃣  Cleaning general caches..."
rm -rf /home/ec2-user/.cache/* 2>/dev/null
echo "   ✅ General caches cleaned"

# 4. Temporary files in /tmp (⚠️ careful with this)
echo "4️⃣  Cleaning /tmp directory..."
sudo find /tmp -type f -delete 2>/dev/null
sudo find /tmp -type d -empty -delete 2>/dev/null
echo "   ✅ /tmp cleaned"

# 5. Temporary files in /var/tmp
echo "5️⃣  Cleaning /var/tmp directory..."
sudo find /var/tmp -type f -delete 2>/dev/null
sudo find /var/tmp -type d -empty -delete 2>/dev/null
echo "   ✅ /var/tmp cleaned"

# 6. Old log files (keep recent ones)
echo "6️⃣  Cleaning old log files..."
sudo find /var/log -type f -name "*.log.*" -delete 2>/dev/null
sudo find /var/log -type f -name "*.gz" -delete 2>/dev/null
sudo find /var/log -type f -name "*.old" -delete 2>/dev/null
echo "   ✅ Old log files cleaned"

# 7. Journal logs (keep last 24 hours)
echo "7️⃣  Cleaning old journal logs..."
sudo journalctl --vacuum-time=1d 2>/dev/null
echo "   ✅ Journal cleaned"

# 8. Core dumps
echo "8️⃣  Removing core dumps..."
sudo rm -rf /var/crash/* 2>/dev/null
sudo rm -f /core.* 2>/dev/null
echo "   ✅ Core dumps removed"

# 9. Sentence-transformers cache
echo "9️⃣  Checking sentence-transformers cache..."
if [ -d "/home/ec2-user/.cache/torch" ]; then
    TORCH_SIZE=$(du -sh /home/ec2-user/.cache/torch 2>/dev/null | awk '{print $1}')
    echo "   Torch cache size: ${TORCH_SIZE}"
    read -p "   Delete torch/sentence-transformers cache? (y/n): " delete_torch
    if [ "$delete_torch" = "y" ]; then
        rm -rf /home/ec2-user/.cache/torch
        echo "   ✅ Torch cache deleted (will be re-downloaded on next use)"
    else
        echo "   ⏭️  Kept torch cache"
    fi
fi

echo ""
echo "✅ Aggressive cleanup complete!"
