"""
Field-ready construction assistant with structured responses
Decision + Checks + Actions format
"""
import pandas as pd
import re
import os

# Trade detection keywords
TRADE_KEYWORDS = {
    'hvac': ['hvac', 'airflow', 'ahu', 'damper', 'duct', 'vfd', 'fan', 'cooling', 'heating', 'ventilation', 'cfm', 'air'],
    'electrical': ['electrical', 'cable', 'mcb', 'tripping', 'wiring', 'db', 'breaker', 'tray', 'circuit'],
    'plumbing': ['plumbing', 'water', 'pressure', 'pipe', 'valve', 'prv', 'pump', 'tap', 'fixture', 'drainage'],
    'concrete': ['concrete', 'rebar', 'cover', 'honeycombing', 'crack', 'formwork', 'pour', 'cube', 'strength', 'slab'],
    'finishes': ['tile', 'paint', 'debonding', 'blistering', 'screed', 'adhesive', 'waterproofing'],
    'safety': ['hot work', 'permit', 'fire', 'safety', 'hse'],
    'contracts': ['variation', 'claim', 'design change', 'boq', 'scope']
}

def detect_trade(query):
    """Detect trade from query"""
    query_lower = query.lower()
    for trade, keywords in TRADE_KEYWORDS.items():
        if any(kw in query_lower for kw in keywords):
            return trade
    return 'general'

def load_cases_data():
    """Load cases CSV file"""
    paths = ["data/cases.csv", "../data/cases.csv"]
    for path in paths:
        if os.path.exists(path):
            return pd.read_csv(path)
    return pd.DataFrame()

def simple_search(query, top_k=5):
    """Text-based search with scoring"""
    df = load_cases_data()
    if df.empty:
        return []
    
    query_lower = query.lower()
    query_words = set(re.findall(r'\w+', query_lower))
    scores = []
    
    for _, row in df.iterrows():
        text = f"{row.get('title', '')} {row.get('problem', '')} {row.get('solution', '')} {row.get('tags', '')}".lower()
        text_words = set(re.findall(r'\w+', text))
        
        score = len(query_words & text_words) / max(len(query_words), 1)
        if query_lower in text: score += 0.5
        if any(w in str(row.get('title', '')).lower() for w in query_words): score += 0.3
        if any(w in str(row.get('tags', '')).lower() for w in query_words): score += 0.2
        
        scores.append({
            'case_id': str(row.get('case_id', '')),
            'title': str(row.get('title', '')),
            'problem': str(row.get('problem', '')),
            'solution': str(row.get('solution', '')),
            'tags': str(row.get('tags', '')),
            'score': score
        })
    
    scores.sort(key=lambda x: x['score'], reverse=True)
    return scores[:top_k]

def extract_causes(results):
    """Extract root causes from solution texts"""
    causes = []
    for r in results:
        solution = r['solution'].lower()
        patterns = [
            r'root cause[s]?:?\s*([^.]+)',
            r'cause[d]? by:?\s*([^.]+)',
        ]
        for pattern in patterns:
            matches = re.findall(pattern, solution)
            for m in matches:
                if m.strip() and len(m) > 10:
                    causes.append(m.strip().capitalize())
    return list(dict.fromkeys(causes))[:3]  # unique, max 3

def extract_checks(solution):
    """Extract check items from solution"""
    checks = []
    keywords = ['check', 'verify', 'inspect', 'confirm', 'measure', 'test']
    sentences = solution.split('.')
    for s in sentences:
        if any(kw in s.lower() for kw in keywords):
            clean = s.strip()
            if clean and len(clean) > 15:
                checks.append(clean)
    return checks[:4]

def extract_fixes(solution):
    """Extract corrective actions"""
    fixes = []
    # Look for corrective section
    match = re.search(r'corrective:?\s*([^.]+\.?[^.]*\.?)', solution.lower())
    if match:
        fixes.append(match.group(1).strip().capitalize())
    else:
        # Extract action-oriented sentences
        action_words = ['replace', 'repair', 'adjust', 'seal', 'clean', 'install', 'remove', 'set']
        for s in solution.split('.'):
            if any(w in s.lower() for w in action_words):
                clean = s.strip()
                if clean and len(clean) > 10:
                    fixes.append(clean)
    return fixes[:4]

def extract_prevention(solution):
    """Extract prevention tips"""
    match = re.search(r'prevent[ion]?:?\s*([^.]+)', solution.lower())
    if match:
        return match.group(1).strip().capitalize()
    return None

def build_structured_response(query, results):
    """Build simple direct response"""
    if not results:
        return "No matching cases found. Try describing the issue differently."
    
    relevant = [r for r in results if r['score'] > 0.1]
    if not relevant:
        return "Low confidence match. Consider consulting a specialist."
    
    top = relevant[0]
    
    # Natural paragraph response
    response = f"**{top['title']}**\n\n"
    response += f"{top['problem']}\n\n"
    response += f"{top['solution']}"
    
    return response

def fallback_chat(query, top_k=5):
    """Main search function with structured output"""
    results = simple_search(query, top_k)
    relevant = [r for r in results if r['score'] > 0.1]
    
    answer = build_structured_response(query, results)
    
    return {
        "answer": answer,
        "sources": [r['case_id'] for r in relevant[:3]],
        "best_score": results[0]['score'] if results else 0.0,
        "trade": detect_trade(query)
    }
