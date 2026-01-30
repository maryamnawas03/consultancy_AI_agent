"""
Construction assistant with Gemini AI integration
Uses LLM to generate responses based on similar cases
"""
import pandas as pd
import re
import os
import google.generativeai as genai

# Configure Gemini API
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY", "AIzaSyAEkUc4dKSmWEj67I1vMLqZWY4peUQaAks")
genai.configure(api_key=GEMINI_API_KEY)

# Initialize Gemini model (using gemini-1.5-flash for free tier availability)
model = genai.GenerativeModel('models/gemini-1.5-flash')

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

def build_gemini_response(query, results):
    """Use Gemini AI to generate response based on similar cases"""
    if not results:
        return "No matching cases found. Try describing the issue differently."
    
    relevant = [r for r in results if r['score'] > 0.1]
    if not relevant:
        return "Low confidence match. Consider consulting a specialist."
    
    # Build context from top 3 matching cases
    context = "# Similar Construction Cases:\n\n"
    for i, case in enumerate(relevant[:3], 1):
        context += f"## Case {i}: {case['title']}\n"
        context += f"**Problem:** {case['problem']}\n"
        context += f"**Solution:** {case['solution']}\n\n"
    
    # Create prompt for Gemini
    prompt = f"""You are a construction consulting expert. A user has asked: \"{query}\"\n\n{context}\n\nBased on these similar cases, provide a clear, actionable response with:\n1. A brief heading (without \"Phase 1\", \"Level 3\" etc.)\n2. Context paragraph explaining the issue\n3. Root cause (if identifiable)\n4. Step-by-step actions to take\n5. Prevention tips\n\nFormat your response in markdown with clear sections. Be concise and practical."""

    try:
        # Call Gemini API with the installed SDK
        response = model.generate_content(prompt)
        return response.text
    except Exception as e:
        # Fallback to simple response if API fails
        print(f"Gemini API error: {e}")
        return build_simple_fallback(relevant[0])

def build_simple_fallback(case):
    """Simple fallback if Gemini fails"""
    title = re.sub(r'\s*\([^)]+\)\s*$', '', case['title']).strip()
    return f"### {title}\n\n{case['problem']}\n\n**Solution:** {case['solution']}"

def fallback_chat(query, top_k=5):
    """Main search function with Gemini AI"""
    results = simple_search(query, top_k)
    relevant = [r for r in results if r['score'] > 0.1]
    
    # Use Gemini to generate response
    answer = build_gemini_response(query, results)
    
    return {
        "answer": answer,
        "sources": [r['case_id'] for r in relevant[:3]],
        "best_score": results[0]['score'] if results else 0.0,
        "trade": detect_trade(query)
    }
