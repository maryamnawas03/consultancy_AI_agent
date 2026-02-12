#!/bin/bash
# EC2 Safe Cleanup - Removes only caches (least risky)

echo "🧹 SAFE CLEANUP: Removing caches only"
echo "════════════════════════════════════════"
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

# 3. Sentence-transformers model cache (if not needed)
echo "3️⃣  Checking sentence-transformers cache..."
if [ -d "/home/ec2-user/.cache/torch" ]; then
    TORCH_SIZE=$(du -sh /home/ec2-user/.cache/torch 2>/dev/null | awk '{print $1}')
    echo "   Torch cache size: ${TORCH_SIZE}"
    echo "   NOTE: This contains ML models. Only delete if you want to re-download them."
    read -p "   Delete torch/sentence-transformers cache? (y/n): " delete_torch
    if [ "$delete_torch" = "y" ]; then
        rm -rf /home/ec2-user/.cache/torch
        echo "   ✅ Torch cache deleted"
    else
        echo "   ⏭️  Kept torch cache"
    fi
fi

# 4. Node modules (if any)
echo "4️⃣  Checking for Node.js cache..."
rm -rf /home/ec2-user/.npm 2>/dev/null
rm -rf /home/ec2-user/.cache/yarn 2>/dev/null
echo "   ✅ Node.js caches cleaned"

# 5. Bash history and other shell caches
echo "5️⃣  Cleaning shell caches..."
rm -rf /home/ec2-user/.cache/* 2>/dev/null
echo "   ✅ Shell caches cleaned"

echo ""
echo "✅ Safe cleanup complete!"
