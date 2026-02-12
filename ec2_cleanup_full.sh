#!/bin/bash
# EC2 Full Cleanup - Removes everything unnecessary including package manager caches

echo "🧹 FULL CLEANUP: Complete cleanup including package manager caches"
echo "════════════════════════════════════════════════════════════════════"
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
pip cache purge 2>/dev/null
echo "   ✅ Pip cache cleaned"

# 3. General cache
echo "3️⃣  Cleaning general caches..."
rm -rf /home/ec2-user/.cache/* 2>/dev/null
echo "   ✅ General caches cleaned"

# 4. Temporary files in /tmp
echo "4️⃣  Cleaning /tmp directory..."
sudo find /tmp -type f -delete 2>/dev/null
sudo find /tmp -type d -empty -delete 2>/dev/null
echo "   ✅ /tmp cleaned"

# 5. Temporary files in /var/tmp
echo "5️⃣  Cleaning /var/tmp directory..."
sudo find /var/tmp -type f -delete 2>/dev/null
sudo find /var/tmp -type d -empty -delete 2>/dev/null
echo "   ✅ /var/tmp cleaned"

# 6. Log files
echo "6️⃣  Cleaning old log files..."
sudo find /var/log -type f -name "*.log.*" -delete 2>/dev/null
sudo find /var/log -type f -name "*.gz" -delete 2>/dev/null
sudo find /var/log -type f -name "*.old" -delete 2>/dev/null
# Truncate large log files but keep them
sudo find /var/log -type f -name "*.log" -size +100M -exec truncate -s 0 {} \; 2>/dev/null
echo "   ✅ Old log files cleaned"

# 7. Journal logs
echo "7️⃣  Cleaning journal logs..."
sudo journalctl --vacuum-time=1d 2>/dev/null
echo "   ✅ Journal cleaned"

# 8. Core dumps
echo "8️⃣  Removing core dumps..."
sudo rm -rf /var/crash/* 2>/dev/null
sudo rm -f /core.* 2>/dev/null
echo "   ✅ Core dumps removed"

# 9. YUM/DNF package manager cache (Amazon Linux)
echo "9️⃣  Cleaning package manager cache..."
sudo yum clean all 2>/dev/null || sudo dnf clean all 2>/dev/null
sudo rm -rf /var/cache/yum/* 2>/dev/null
sudo rm -rf /var/cache/dnf/* 2>/dev/null
echo "   ✅ Package manager cache cleaned"

# 10. Sentence-transformers and Torch cache
echo "🔟  Checking ML model cache..."
if [ -d "/home/ec2-user/.cache/torch" ]; then
    TORCH_SIZE=$(du -sh /home/ec2-user/.cache/torch 2>/dev/null | awk '{print $1}')
    echo "   Torch cache size: ${TORCH_SIZE}"
    read -p "   Delete torch/sentence-transformers cache? (y/n): " delete_torch
    if [ "$delete_torch" = "y" ]; then
        rm -rf /home/ec2-user/.cache/torch
        echo "   ✅ Torch cache deleted (will be ~400MB when re-downloaded)"
    else
        echo "   ⏭️  Kept torch cache"
    fi
fi

# 11. Truncate other large logs
echo "1️⃣1️⃣  Truncating remaining large logs..."
sudo truncate -s 0 /var/log/messages 2>/dev/null
sudo truncate -s 0 /var/log/syslog 2>/dev/null
sudo truncate -s 0 /var/log/secure 2>/dev/null
echo "   ✅ Large logs truncated"

# 12. Remove old kernel modules
echo "1️⃣2️⃣  Checking for old kernel versions..."
sudo yum install -y yum-utils 2>/dev/null
sudo package-cleanup --oldkernels --count=1 -y 2>/dev/null || echo "   (Skipping old kernels)"
echo "   ✅ Old kernels cleaned"

echo ""
echo "════════════════════════════════════════════════════════════════════"
echo "✅ Full cleanup complete!"
echo "════════════════════════════════════════════════════════════════════"
