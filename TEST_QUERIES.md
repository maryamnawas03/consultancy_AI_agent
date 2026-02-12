# 🧪 Test Questions for Construction AI Agent

## Test Queries Demonstrating Semantic Search

---

## 1. Semantic Understanding Tests

### Test 1: Synonym Matching
**Query:** "circuit keeps disconnecting"
**Should Find:** "Frequent MCB tripping" cases
**Why:** Semantic search understands "disconnecting" = "tripping"

```bash
curl -X POST http://16.16.193.209:8000/chat \
  -H "Content-Type: application/json" \
  -d '{
    "session_id": "test1",
    "message": "circuit keeps disconnecting",
    "search_method": "semantic",
    "top_k": 3
  }' | jq '.'
```

---

### Test 2: Concept Matching
**Query:** "water flow issues in plumbing"
**Should Find:** "Low water pressure", "Drain pipe slope" cases
**Why:** Semantic search connects "flow" with "pressure" and "drainage"

```bash
curl -X POST http://16.16.193.209:8000/chat \
  -H "Content-Type: application/json" \
  -d '{
    "session_id": "test2",
    "message": "water flow issues in plumbing",
    "search_method": "hybrid",
    "top_k": 3
  }' | jq '.'
```

---

### Test 3: Natural Language
**Query:** "tiles falling off bathroom walls"
**Should Find:** "Wet area tile debonding" cases
**Why:** Understands "falling off" = "debonding"

```bash
curl -X POST http://16.16.193.209:8000/chat \
  -H "Content-Type: application/json" \
  -d '{
    "session_id": "test3",
    "message": "tiles falling off bathroom walls",
    "search_method": "semantic",
    "top_k": 3
  }' | jq '.'
```

---

### Test 4: Domain Knowledge
**Query:** "safety compliance for welding work"
**Should Find:** "Hot work without permit" cases
**Why:** Knows "welding" is a type of "hot work"

```bash
curl -X POST http://16.16.193.209:8000/chat \
  -H "Content-Type: application/json" \
  -d '{
    "session_id": "test4",
    "message": "safety compliance for welding work",
    "search_method": "semantic",
    "top_k": 3
  }' | jq '.'
```

---

### Test 5: Quality Issues
**Query:** "concrete quality problems after curing"
**Should Find:** "Low concrete strength test result", "Honeycombing" cases
**Why:** Connects "quality problems" with specific defects

```bash
curl -X POST http://16.16.193.209:8000/chat \
  -H "Content-Type: application/json" \
  -d '{
    "session_id": "test5",
    "message": "concrete quality problems after curing",
    "search_method": "semantic",
    "top_k": 3
  }' | jq '.'
```

---

## 2. Construction-Specific Queries

### Test 6: MEP Issue
**Query:** "HVAC system has low airflow complaints"

```bash
curl -X POST http://16.16.193.209:8000/chat \
  -H "Content-Type: application/json" \
  -d '{
    "session_id": "test6",
    "message": "HVAC system has low airflow complaints",
    "search_method": "hybrid",
    "top_k": 5
  }' | jq '.'
```

---

### Test 7: Concrete Problem
**Query:** "Concrete slab shows early cracking after curing"

```bash
curl -X POST http://16.16.193.209:8000/chat \
  -H "Content-Type: application/json" \
  -d '{
    "session_id": "test7",
    "message": "Concrete slab shows early cracking after curing",
    "search_method": "hybrid",
    "top_k": 5
  }' | jq '.'
```

---

### Test 8: Electrical Issue
**Query:** "Cable tray is overfilled and there is overheating risk"

```bash
curl -X POST http://16.16.193.209:8000/chat \
  -H "Content-Type: application/json" \
  -d '{
    "session_id": "test8",
    "message": "Cable tray is overfilled and there is overheating risk",
    "search_method": "semantic",
    "top_k": 3
  }' | jq '.'
```

---

### Test 9: Finishing Problem
**Query:** "Paint is blistering after finishing"

```bash
curl -X POST http://16.16.193.209:8000/chat \
  -H "Content-Type: application/json" \
  -d '{
    "session_id": "test9",
    "message": "Paint is blistering after finishing",
    "search_method": "hybrid",
    "top_k": 3
  }' | jq '.'
```

---

### Test 10: Structural Concern
**Query:** "Found rebar cover nonconformance during inspection"

```bash
curl -X POST http://16.16.193.209:8000/chat \
  -H "Content-Type: application/json" \
  -d '{
    "session_id": "test10",
    "message": "Found rebar cover nonconformance during inspection",
    "search_method": "hybrid",
    "top_k": 3
  }' | jq '.'
```

---

## 3. Comparison Tests (Semantic vs Keyword vs Hybrid)

### Test 11: Compare All Methods
**Query:** "electrical breaker keeps shutting off"

**Test Keyword:**
```bash
curl -X POST http://16.16.193.209:8000/chat \
  -H "Content-Type: application/json" \
  -d '{
    "session_id": "test11a",
    "message": "electrical breaker keeps shutting off",
    "search_method": "keyword",
    "top_k": 3
  }' | jq '.sources, .best_score, .search_method'
```

**Test Semantic:**
```bash
curl -X POST http://16.16.193.209:8000/chat \
  -H "Content-Type: application/json" \
  -d '{
    "session_id": "test11b",
    "message": "electrical breaker keeps shutting off",
    "search_method": "semantic",
    "top_k": 3
  }' | jq '.sources, .best_score, .search_method'
```

**Test Hybrid:**
```bash
curl -X POST http://16.16.193.209:8000/chat \
  -H "Content-Type: application/json" \
  -d '{
    "session_id": "test11c",
    "message": "electrical breaker keeps shutting off",
    "search_method": "hybrid",
    "top_k": 3
  }' | jq '.sources, .best_score, .search_method'
```

---

## 4. Simple Test Script

Save as `test_queries.sh`:

```bash
#!/bin/bash

# Configuration
API_URL="http://16.16.193.209:8000/chat"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "🧪 Testing Construction AI Agent..."
echo ""

# Test 1: Semantic understanding
echo -e "${BLUE}Test 1: Semantic Understanding${NC}"
echo "Query: 'circuit keeps disconnecting'"
curl -s -X POST $API_URL \
  -H "Content-Type: application/json" \
  -d '{
    "session_id": "test1",
    "message": "circuit keeps disconnecting",
    "search_method": "semantic",
    "top_k": 3
  }' | jq -r '.sources, .best_score, .search_method'
echo ""

# Test 2: Water issues
echo -e "${BLUE}Test 2: Water Flow Issues${NC}"
echo "Query: 'water flow problems'"
curl -s -X POST $API_URL \
  -H "Content-Type: application/json" \
  -d '{
    "session_id": "test2",
    "message": "water flow problems",
    "search_method": "hybrid",
    "top_k": 3
  }' | jq -r '.sources, .best_score, .search_method'
echo ""

# Test 3: Tiles falling
echo -e "${BLUE}Test 3: Tiles Falling Off${NC}"
echo "Query: 'tiles falling off bathroom walls'"
curl -s -X POST $API_URL \
  -H "Content-Type: application/json" \
  -d '{
    "session_id": "test3",
    "message": "tiles falling off bathroom walls",
    "search_method": "semantic",
    "top_k": 3
  }' | jq -r '.sources, .best_score, .search_method'
echo ""

# Test 4: Safety
echo -e "${BLUE}Test 4: Safety Compliance${NC}"
echo "Query: 'welding without permit'"
curl -s -X POST $API_URL \
  -H "Content-Type: application/json" \
  -d '{
    "session_id": "test4",
    "message": "welding without permit",
    "search_method": "semantic",
    "top_k": 3
  }' | jq -r '.sources, .best_score, .search_method'
echo ""

# Test 5: Concrete
echo -e "${BLUE}Test 5: Concrete Issues${NC}"
echo "Query: 'concrete is weak'"
curl -s -X POST $API_URL \
  -H "Content-Type: application/json" \
  -d '{
    "session_id": "test5",
    "message": "concrete is weak",
    "search_method": "hybrid",
    "top_k": 3
  }' | jq -r '.sources, .best_score, .search_method'
echo ""

echo -e "${GREEN}✅ Tests complete!${NC}"
```

**Run it:**
```bash
chmod +x test_queries.sh
./test_queries.sh
```

---

## 5. Expected Results

### Good Semantic Search Results:
```json
{
  "sources": ["C-010", "C-018", "C-029"],
  "best_score": 0.85,
  "search_method": "semantic",
  "answer": "Detailed expert response..."
}
```

**Indicators of Success:**
- ✅ `best_score` > 0.7 (high confidence)
- ✅ Relevant case IDs in sources
- ✅ `search_method` confirms which method was used
- ✅ Answer is detailed and contextual

### Poor Results (Semantic Not Working):
```json
{
  "sources": ["C-001", "C-002", "C-003"],
  "best_score": 0.3,
  "search_method": "keyword",
  "answer": "Generic response..."
}
```

**Warning Signs:**
- ⚠️ Low `best_score` < 0.5
- ⚠️ Falls back to "keyword" when "semantic" requested
- ⚠️ Irrelevant case IDs

---

## 6. Batch Testing

Test all queries at once:

```bash
# Save as test_all.sh
#!/bin/bash

API="http://16.16.193.209:8000/chat"

queries=(
  "circuit keeps disconnecting"
  "water flow issues"
  "tiles falling off walls"
  "welding safety"
  "concrete is weak"
  "HVAC airflow problem"
  "cable tray full"
  "paint bubbling up"
  "rebar cover too small"
  "drain pipe blocked"
)

for query in "${queries[@]}"; do
  echo "Testing: $query"
  curl -s -X POST $API \
    -H "Content-Type: application/json" \
    -d "{
      \"session_id\": \"batch_test\",
      \"message\": \"$query\",
      \"search_method\": \"hybrid\",
      \"top_k\": 3
    }" | jq -r '"Score: \(.best_score) | Sources: \(.sources | join(", "))"'
  echo "---"
done
```

---

## 7. Performance Testing

Test response times:

```bash
# Measure response time
time curl -X POST http://16.16.193.209:8000/chat \
  -H "Content-Type: application/json" \
  -d '{
    "session_id": "perf_test",
    "message": "concrete quality problems",
    "search_method": "semantic",
    "top_k": 5
  }' > /dev/null 2>&1

# Expected: 2-5 seconds (including Gemini API)
# Search only: <500ms
```

---

## Summary

### Key Test Queries:

1. **"circuit keeps disconnecting"** - Tests synonym understanding
2. **"water flow issues"** - Tests concept matching  
3. **"tiles falling off walls"** - Tests natural language
4. **"welding work safety"** - Tests domain knowledge
5. **"concrete is weak"** - Tests quality terms

### What to Look For:

✅ **Good Results:**
- High scores (>0.7)
- Relevant case IDs
- Detailed answers
- Semantic method used

❌ **Poor Results:**
- Low scores (<0.5)
- Generic responses
- Falls back to keyword
- Timeout errors

Use **`CHECK_SEMANTIC_EC2.md`** to verify installation first! 🚀
