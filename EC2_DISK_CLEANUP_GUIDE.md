# EC2 Disk Cleanup & Dependency Optimization Guide

## Quick Start

### Step 1: Run Full Analysis and Cleanup
```bash
cd /home/ec2-user/consultancy_AI_agent

# Make scripts executable
chmod +x ec2_*.sh

# Run the main analysis script (interactive menu)
bash ec2_analyze_and_cleanup.sh
```

## Available Scripts

### 1. **ec2_analyze_and_cleanup.sh** (MAIN SCRIPT)
Interactive menu-driven script that:
- Shows current disk usage
- Identifies largest directories
- Analyzes Python dependencies
- Shows temporary files and logs
- Offers 3 cleanup levels

**Run this first!**

```bash
bash ec2_analyze_and_cleanup.sh
```

---

### 2. **ec2_cleanup_safe.sh**
Removes only caches (safest option):
- Python __pycache__
- pip cache
- General caches

**Frees: ~200-500MB**

```bash
bash ec2_cleanup_safe.sh
```

---

### 3. **ec2_cleanup_aggressive.sh**
Removes caches + logs + temp files:
- Python caches
- pip cache
- /tmp and /var/tmp
- Old log files
- Journal logs
- Core dumps

**Frees: ~500MB-2GB**

```bash
bash ec2_cleanup_aggressive.sh
```

---

### 4. **ec2_cleanup_full.sh**
Complete cleanup including package manager:
- All caches
- All temp/log files
- Package manager cache (YUM/DNF)
- Optional: Torch/sentence-transformers cache (~400MB)

**Frees: ~2-3GB**

```bash
bash ec2_cleanup_full.sh
```

---

### 5. **ec2_analyze_dependencies.sh**
Analyzes Python dependencies:
- Lists all installed packages
- Shows package sizes
- Identifies unused dependencies
- Recommends removals
- Can export clean requirements.txt

```bash
bash ec2_analyze_dependencies.sh
```

---

## Recommended Cleanup Strategy

### Option A: Quick Fix (5 minutes)
```bash
# Just clean caches
bash ec2_cleanup_safe.sh
```

### Option B: Thorough Fix (10 minutes)
```bash
# Clean everything except package manager
bash ec2_cleanup_aggressive.sh
```

### Option C: Deep Clean (15 minutes)
```bash
# Complete cleanup
bash ec2_cleanup_full.sh

# Then analyze and remove unused dependencies
bash ec2_analyze_dependencies.sh
```

---

## What Each Directory Contains

| Directory | Size | Safe to Clean? | Notes |
|-----------|------|---|---|
| `/tmp` | Usually 100-500MB | ⚠️ Mostly | Don't delete while apps are running |
| `/var/tmp` | Usually 10-100MB | ✅ Yes | Safe to delete |
| `/var/log` | Usually 200MB-2GB | ✅ Most | Keep recent logs |
| `/var/cache/yum` | 50-500MB | ✅ Yes | Package manager downloads (will re-download if needed) |
| `~/.cache/pip` | 100-500MB | ✅ Yes | Pip package cache |
| `~/.cache/torch` | ~400MB | ⚠️ Optional | Sentence-transformers models (re-downloads ~5min) |
| `__pycache__` | 50-200MB | ✅ Yes | Python cache (auto-recreated) |

---

## Essential vs Optional Dependencies

### Essential (DO NOT REMOVE)
```
streamlit>=1.29.0           # Frontend UI
fastapi>=0.104.0            # Backend API
uvicorn>=0.24.0             # Web server
pandas>=1.5.0               # Data handling
requests>=2.28.0            # HTTP calls
google-generativeai>=0.8.0  # Gemini API
sentence-transformers>=2.2.0 # Semantic search embeddings
scikit-learn>=1.3.0         # ML operations (similarity)
```

### Optional
```
markdown>=3.4.0  # Only if you need markdown processing
```

---

## Disk Space Reference

- **All 3 cleanup scripts combined**: Can free ~3-4GB
- **Torch/sentence-transformers**: ~400MB (optional to keep for faster startup)
- **Python packages themselves**: ~1-2GB
- **Application code + data**: ~50-100MB

---

## If Disk is Still Full After Cleanup

1. Check for large unused files:
   ```bash
   find / -type f -size +100M 2>/dev/null | head -20
   ```

2. Check for Docker images/containers:
   ```bash
   docker system df
   docker system prune -af
   ```

3. Consider increasing EBS volume size in AWS console (if needed)

---

## After Cleanup

Once you've freed up space:

```bash
# Verify disk space
df -h

# Install dependencies (if needed)
pip install --no-cache-dir -r requirements.txt

# Start the application
cd /home/ec2-user/consultancy_AI_agent
python3 app/cloud_server.py
```

---

## Troubleshooting

### Problem: Scripts won't run
```bash
# Make them executable
chmod +x ec2_*.sh
```

### Problem: Permission denied
```bash
# Use sudo for system-wide cleanup
sudo bash ec2_cleanup_full.sh
```

### Problem: Package manager errors
```bash
# Fix YUM database
sudo yum check
sudo yum clean metadata
```

---

## Questions?

Check the output of the analysis script first - it will tell you exactly what's using space and what can be safely removed!
