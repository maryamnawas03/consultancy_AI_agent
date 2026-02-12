#!/bin/bash
# EC2 Python Dependency Analyzer and Optimizer
# Identifies unused dependencies and provides recommendations

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║   PYTHON DEPENDENCY ANALYZER & OPTIMIZER                       ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# ============================================================================
# SECTION 1: List all installed packages with sizes
# ============================================================================
echo "📦 INSTALLED PYTHON PACKAGES"
echo "────────────────────────────────────────────────────────────────"
echo ""
echo "All installed packages (sorted by installation size):"
pip list --format=freeze | wc -l | xargs echo "Total packages installed:"
echo ""

# Create a temporary file to store package info
TEMP_PKG_FILE=$(mktemp)

pip list --format=freeze | while read line; do
    pkg_name="${line%%==*}"
    if pip show "$pkg_name" 2>/dev/null | grep -q "Location:"; then
        location=$(pip show "$pkg_name" 2>/dev/null | grep "Location:" | awk '{print $NF}')
        version=$(pip show "$pkg_name" 2>/dev/null | grep "Version:" | awk '{print $NF}')
        if [ -d "$location/$pkg_name" ]; then
            size=$(du -sh "$location/$pkg_name" 2>/dev/null | awk '{print $1}')
        else
            size="N/A"
        fi
        echo "$pkg_name|$version|$size" >> "$TEMP_PKG_FILE"
    fi
done

echo "Package Name                             | Version          | Size"
echo "─────────────────────────────────────────────────────────────────"
sort "$TEMP_PKG_FILE" | tail -50 | column -t -s '|' -N 'PACKAGE,VERSION,SIZE'

rm -f "$TEMP_PKG_FILE"
echo ""

# ============================================================================
# SECTION 2: Check what's actually in requirements.txt
# ============================================================================
echo "📋 REQUIRED DEPENDENCIES (from requirements.txt)"
echo "────────────────────────────────────────────────────────────────"
if [ -f "/home/ec2-user/consultancy_AI_agent/requirements.txt" ]; then
    echo "Current requirements:"
    cat /home/ec2-user/consultancy_AI_agent/requirements.txt
else
    echo "requirements.txt not found"
fi
echo ""

# ============================================================================
# SECTION 3: Identify unused dependencies
# ============================================================================
echo "🔍 DEPENDENCY USAGE ANALYSIS"
echo "────────────────────────────────────────────────────────────────"
echo ""
echo "The following packages are in your environment:"
echo ""

# Check each commonly used package
check_package() {
    local pkg=$1
    local desc=$2
    if pip show "$pkg" 2>/dev/null | grep -q "Name: $pkg"; then
        version=$(pip show "$pkg" 2>/dev/null | grep "Version:" | awk '{print $NF}')
        echo "✅ $pkg ($version) - $desc"
    else
        echo "❌ $pkg - NOT INSTALLED"
    fi
}

echo "Core Dependencies:"
check_package "streamlit" "Frontend UI framework"
check_package "fastapi" "Backend API framework"
check_package "uvicorn" "ASGI web server"
check_package "pandas" "Data manipulation"
check_package "requests" "HTTP client"
check_package "google-generativeai" "Gemini AI API"

echo ""
echo "ML/Search Dependencies:"
check_package "sentence-transformers" "Semantic search embeddings"
check_package "scikit-learn" "ML algorithms (similarity calculations)"

echo ""
echo "Utility Dependencies:"
check_package "markdown" "Markdown processing"

echo ""

# ============================================================================
# SECTION 4: Recommendations
# ============================================================================
echo "💡 RECOMMENDATIONS FOR OPTIMIZATION"
echo "────────────────────────────────────────────────────────────────"
echo ""
echo "Essential packages (DO NOT REMOVE):"
echo "  • streamlit - Frontend interface"
echo "  • fastapi - Backend API"
echo "  • uvicorn - Server"
echo "  • pandas - Data handling"
echo "  • requests - API calls"
echo "  • google-generativeai - Gemini API"
echo "  • sentence-transformers - Semantic search"
echo "  • scikit-learn - ML operations"
echo ""

echo "Optional packages:"
echo "  • markdown - Only needed for markdown processing"
echo ""

# ============================================================================
# SECTION 5: Check dependency sizes
# ============================================================================
echo "📊 LARGE DEPENDENCIES BREAKDOWN"
echo "────────────────────────────────────────────────────────────────"
echo ""

show_dep_size() {
    local pkg=$1
    if pip show "$pkg" 2>/dev/null | grep -q "Location:"; then
        location=$(pip show "$pkg" 2>/dev/null | grep "Location:" | awk '{print $NF}')
        if [ -d "$location/$pkg" ]; then
            size=$(du -sh "$location/$pkg" 2>/dev/null | awk '{print $1}')
            echo "  $pkg: $size"
        fi
    fi
}

echo "Top 10 largest packages:"
show_dep_size "torch"
show_dep_size "sentence-transformers"
show_dep_size "pandas"
show_dep_size "scikit-learn"
show_dep_size "numpy"
show_dep_size "google-generativeai"
show_dep_size "transformers"
show_dep_size "streamlit"
show_dep_size "fastapi"
show_dep_size "sklearn"

echo ""

# ============================================================================
# SECTION 6: Menu for actions
# ============================================================================
echo "🛠️  CLEANUP ACTIONS"
echo "────────────────────────────────────────────────────────────────"
echo ""
echo "What would you like to do?"
echo ""
echo "1) Remove all unused dependencies"
echo "2) View detailed package info"
echo "3) Export clean requirements.txt"
echo "4) Exit"
echo ""
read -p "Select option (1-4): " action

case $action in
    1)
        echo ""
        echo "🗑️  Removing unused dependencies..."
        pip install pipdeptree 2>/dev/null
        pip list --format=freeze > /tmp/current_packages.txt
        
        # Keep only required packages
        REQUIRED_PACKAGES=(
            "streamlit"
            "fastapi"
            "uvicorn"
            "pandas"
            "requests"
            "markdown"
            "google-generativeai"
            "sentence-transformers"
            "scikit-learn"
        )
        
        pip freeze | while read package; do
            pkg_name="${package%%==*}"
            is_required=false
            for req in "${REQUIRED_PACKAGES[@]}"; do
                if [[ "$pkg_name" == "$req" ]]; then
                    is_required=true
                    break
                fi
            done
            
            if [ "$is_required" = false ]; then
                echo "Would remove: $package"
            fi
        done
        
        read -p "Proceed with removal? (y/n): " confirm
        if [ "$confirm" = "y" ]; then
            # Create clean environment
            pip freeze | while read package; do
                pkg_name="${package%%==*}"
                is_required=false
                for req in "${REQUIRED_PACKAGES[@]}"; do
                    if [[ "$pkg_name" == "$req" ]]; then
                        is_required=true
                        break
                    fi
                done
                
                if [ "$is_required" = false ] && [[ "$pkg_name" != "pip" ]] && [[ "$pkg_name" != "setuptools" ]]; then
                    echo "Removing: $pkg_name"
                    pip uninstall -y "$pkg_name" 2>/dev/null || true
                fi
            done
            echo "✅ Unused dependencies removed"
        fi
        ;;
    2)
        echo ""
        pip show sentence-transformers
        echo ""
        pip show scikit-learn
        ;;
    3)
        echo ""
        echo "Exporting clean requirements.txt..."
        pip freeze > /home/ec2-user/consultancy_AI_agent/requirements_clean.txt
        echo "✅ Saved to requirements_clean.txt"
        echo ""
        cat /home/ec2-user/consultancy_AI_agent/requirements_clean.txt
        ;;
    4)
        echo "Exiting..."
        exit 0
        ;;
    *)
        echo "Invalid option"
        exit 1
        ;;
esac
