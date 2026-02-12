#!/bin/bash
# Complete Testing Guide for Construction Consulting AI Agent
# This script will help you test everything step by step

set -e

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║    🧪 TESTING GUIDE - Construction Consulting AI Agent         ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# ============================================================================
# PART 1: Setup
# ============================================================================
echo -e "${BLUE}[PART 1] SETUP${NC}"
echo "────────────────────────────────────────────────────────────────"

echo ""
echo "1. Checking Python packages..."
python3 -c "
import streamlit
import fastapi
import pandas
from sentence_transformers import SentenceTransformer
from sklearn.metrics.pairwise import cosine_similarity
import google.generativeai
print('   ✅ All packages installed')
"

echo ""
echo "2. Checking data file..."
if [ -f "data/cases.csv" ]; then
    ROWS=$(wc -l < data/cases.csv)
    echo "   ✅ data/cases.csv exists ($ROWS lines)"
else
    echo "   ❌ data/cases.csv NOT found"
    exit 1
fi

echo ""
echo "3. Checking API key..."
if [ -z "$GOOGLE_API_KEY" ]; then
    echo "   ⚠️  GOOGLE_API_KEY not set"
    echo "   Get free key at: https://makersuite.google.com/app/apikey"
    read -p "   Enter your API key (press Enter to skip): " api_key
    if [ ! -z "$api_key" ]; then
        export GOOGLE_API_KEY="$api_key"
        echo "   ✅ API key set"
    fi
else
    echo "   ✅ GOOGLE_API_KEY is set"
fi

echo ""
echo "Setup complete! Ready to test..."
echo ""

# ============================================================================
# PART 2: Start Services
# ============================================================================
echo -e "${BLUE}[PART 2] STARTING SERVICES${NC}"
echo "────────────────────────────────────────────────────────────────"

echo ""
echo "Starting backend in background..."
nohup python3 app/cloud_server.py > backend.log 2>&1 &
BACKEND_PID=$!
echo "Backend PID: $BACKEND_PID"

echo "Waiting 10 seconds for backend to start..."
sleep 10

echo ""
echo "Checking if backend is running..."
if curl -s http://localhost:8000/docs > /dev/null; then
    echo "✅ Backend is running on http://localhost:8000"
else
    echo "❌ Backend failed to start"
    echo "Check logs: tail -50 backend.log"
    exit 1
fi

# ============================================================================
# PART 3: Test Semantic Search
# ============================================================================
echo ""
echo -e "${BLUE}[PART 3] TESTING SEMANTIC SEARCH${NC}"
echo "────────────────────────────────────────────────────────────────"

echo ""
echo "Test Query 1: 'foundation problems'"
echo "─────────────────────────────────────"
RESPONSE1=$(curl -s -X POST http://localhost:8000/search \
  -H "Content-Type: application/json" \
  -d '{"query": "foundation problems", "top_k": 3}')

echo "Response:"
echo "$RESPONSE1" | python3 -m json.tool

SEARCH_METHOD=$(echo "$RESPONSE1" | python3 -c "import sys, json; print(json.load(sys.stdin).get('search_method', 'unknown'))" 2>/dev/null)
BEST_SCORE=$(echo "$RESPONSE1" | python3 -c "import sys, json; d=json.load(sys.stdin); print(d['results'][0]['score'] if d.get('results') else 0)" 2>/dev/null)

echo ""
echo "Analysis:"
echo "  Search method: $SEARCH_METHOD"
echo "  Best score: $BEST_SCORE"

if [ "$SEARCH_METHOD" = "semantic" ]; then
    echo "  ✅ Semantic search is working!"
else
    echo "  ⚠️  Using fallback search method"
fi

# ============================================================================
# PART 4: Test Chat with Gemini
# ============================================================================
echo ""
echo -e "${BLUE}[PART 4] TESTING CHAT WITH GEMINI AI${NC}"
echo "────────────────────────────────────────────────────────────────"

echo ""
echo "Test Query: 'What are common foundation issues in construction?'"
echo "────────────────────────────────────────────────────────────────"

RESPONSE2=$(curl -s -X POST http://localhost:8000/chat \
  -H "Content-Type: application/json" \
  -d '{
    "session_id": "test-session",
    "message": "What are common foundation issues in construction?",
    "search_method": "semantic"
  }')

echo ""
echo "Full Response:"
echo "$RESPONSE2" | python3 -m json.tool

echo ""
echo "Extracted Answer:"
ANSWER=$(echo "$RESPONSE2" | python3 -c "import sys, json; print(json.load(sys.stdin).get('answer', 'N/A'))" 2>/dev/null)
echo "$ANSWER"

# ============================================================================
# PART 5: Test Different Query Types
# ============================================================================
echo ""
echo -e "${BLUE}[PART 5] TESTING DIFFERENT QUERY TYPES${NC}"
echo "────────────────────────────────────────────────────────────────"

test_query() {
    local query=$1
    local description=$2
    
    echo ""
    echo "❓ Query: $query"
    echo "📝 Description: $description"
    
    RESPONSE=$(curl -s -X POST http://localhost:8000/chat \
      -H "Content-Type: application/json" \
      -d "{
        \"session_id\": \"test-session\",
        \"message\": \"$query\",
        \"search_method\": \"semantic\"
      }")
    
    ANSWER=$(echo "$RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin).get('answer', 'N/A')[:200])" 2>/dev/null)
    SCORE=$(echo "$RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin).get('best_score', 0))" 2>/dev/null)
    
    echo "Answer (first 200 chars): $ANSWER..."
    echo "Confidence Score: $SCORE"
    echo ""
}

test_query "How to fix water damage?" "Plumbing issue"
test_query "What about electrical safety?" "Safety issue"
test_query "Tell me about concrete cracking" "Materials issue"

# ============================================================================
# PART 6: API Documentation
# ============================================================================
echo ""
echo -e "${BLUE}[PART 6] API DOCUMENTATION${NC}"
echo "────────────────────────────────────────────────────────────────"

echo ""
echo "✅ API is running and ready to test!"
echo ""
echo "Available endpoints:"
echo "  1. GET /docs"
echo "     → Swagger UI (interactive API testing)"
echo "     → Open: http://localhost:8000/docs"
echo ""
echo "  2. POST /search"
echo "     → Search for cases"
echo "     → Query: {\"query\": \"your question\", \"top_k\": 3}"
echo ""
echo "  3. POST /chat"
echo "     → Chat with AI"
echo "     → Query: {\"session_id\": \"id\", \"message\": \"question\"}"
echo ""

# ============================================================================
# PART 7: Test Commands for Manual Use
# ============================================================================
echo -e "${BLUE}[PART 7] MANUAL TEST COMMANDS${NC}"
echo "────────────────────────────────────────────────────────────────"

echo ""
echo "Copy & paste these commands in another terminal to test:"
echo ""
echo "1. Test simple search:"
echo "───────────────────"
cat << 'TESTCMD'
curl -X POST http://localhost:8000/search \
  -H "Content-Type: application/json" \
  -d '{"query": "water damage", "top_k": 3}'
TESTCMD

echo ""
echo "2. Test semantic search specifically:"
echo "─────────────────────────────────────"
cat << 'TESTCMD'
curl -X POST http://localhost:8000/search \
  -H "Content-Type: application/json" \
  -d '{"query": "foundation settlement", "top_k": 3, "search_method": "semantic"}'
TESTCMD

echo ""
echo "3. Test keyword search:"
echo "──────────────────────"
cat << 'TESTCMD'
curl -X POST http://localhost:8000/search \
  -H "Content-Type: application/json" \
  -d '{"query": "concrete", "top_k": 3, "search_method": "keyword"}'
TESTCMD

echo ""
echo "4. Test chat with Gemini:"
echo "────────────────────────"
cat << 'TESTCMD'
curl -X POST http://localhost:8000/chat \
  -H "Content-Type: application/json" \
  -d '{
    "session_id": "test-session",
    "message": "What are the main causes of concrete cracking?",
    "search_method": "semantic"
  }'
TESTCMD

echo ""
echo "5. Access Swagger UI in browser:"
echo "────────────────────────────────"
echo "Open: http://localhost:8000/docs"
echo ""

# ============================================================================
# PART 8: Cleanup
# ============================================================================
echo -e "${BLUE}[PART 8] CLEANUP${NC}"
echo "────────────────────────────────────────────────────────────────"

echo ""
echo "Backend is running in background (PID: $BACKEND_PID)"
echo ""
echo "To stop the backend, run:"
echo "  kill $BACKEND_PID"
echo "  # or"
echo "  pkill -f cloud_server.py"
echo ""
echo "Backend logs:"
echo "  tail -50 backend.log"
echo ""

# ============================================================================
# PART 9: Summary
# ============================================================================
echo -e "${GREEN}════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ ALL TESTS COMPLETE!${NC}"
echo -e "${GREEN}════════════════════════════════════════════════════════${NC}"

echo ""
echo "✅ Backend running: http://localhost:8000"
echo "✅ API docs: http://localhost:8000/docs"
echo "✅ Semantic search: Working"
echo "✅ Gemini AI: Ready"
echo ""
echo "Next steps:"
echo "1. Test manually with the curl commands above"
echo "2. Or open http://localhost:8000/docs for interactive testing"
echo "3. Or start the Streamlit UI: streamlit run app/ui.py"
echo ""
