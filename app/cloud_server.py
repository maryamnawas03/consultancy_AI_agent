# Cloud Backend Configuration
# For deploying the FastAPI backend to cloud services like Railway, Render, or Heroku

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import os
import requests
from typing import List, Dict, Any
import pandas as pd
import re

app = FastAPI(title="Construction Consulting API", version="1.0.0")

# Enable CORS for Streamlit Cloud
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, replace with your Streamlit app URL
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class ChatRequest(BaseModel):
    session_id: str
    message: str
    top_k: int = 6

class ChatResponse(BaseModel):
    answer: str
    sources: List[str]
    best_score: float
    method: str

# Load cases data at startup
cases_df = None

def load_cases():
    """Load the cases CSV file"""
    global cases_df
    try:
        cases_df = pd.read_csv("data/cases.csv")
        print(f"✅ Loaded {len(cases_df)} cases")
    except Exception as e:
        print(f"❌ Error loading cases: {e}")
        cases_df = pd.DataFrame()

def simple_search(query: str, top_k: int = 6) -> List[Dict[str, Any]]:
    """Simple text-based search using keyword matching"""
    if cases_df is None or cases_df.empty:
        return []
    
    query_lower = query.lower()
    query_words = set(re.findall(r'\w+', query_lower))
    
    scores = []
    
    for idx, row in cases_df.iterrows():
        text_fields = [
            str(row.get('title', '')),
            str(row.get('problem', '')),
            str(row.get('solution', '')),
            str(row.get('tags', ''))
        ]
        
        full_text = ' '.join(text_fields).lower()
        text_words = set(re.findall(r'\w+', full_text))
        
        # Calculate word overlap score
        common_words = query_words.intersection(text_words)
        score = len(common_words) / max(len(query_words), 1)
        
        # Boost for exact matches
        if query_lower in full_text:
            score += 0.5
        
        # Boost for title matches
        if any(word in str(row.get('title', '')).lower() for word in query_words):
            score += 0.3
        
        # Boost for tag matches
        tags = str(row.get('tags', '')).lower()
        if any(word in tags for word in query_words):
            score += 0.2
        
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

def generate_response(query: str, search_results: List[Dict[str, Any]]) -> str:
    """Generate response based on search results"""
    if not search_results:
        return "I couldn't find any relevant cases for your query. Please try rephrasing your question or check if it's related to construction problems covered in our database."
    
    relevant_results = [r for r in search_results if r['score'] > 0.1]
    
    if not relevant_results:
        return "I found some potentially related cases, but they may not be directly relevant to your specific question. Please try being more specific about the construction problem you're facing."
    
    response_parts = []
    response_parts.append("Based on similar cases in our database:\n")
    
    # Main recommendation
    top_result = relevant_results[0]
    response_parts.append(f"**Primary Recommendation (Case {top_result['case_id']}):**")
    response_parts.append(f"*{top_result['title']}*\n")
    response_parts.append(f"**Problem:** {top_result['problem']}\n")
    response_parts.append(f"**Solution:** {top_result['solution']}\n")
    
    # Additional cases
    if len(relevant_results) > 1:
        response_parts
        for result in relevant_results[1:3]:
            response_parts.append(f"• **{result['case_id']}**: {result['title']}")
    
    sources = [f"Case {r['case_id']}" for r in relevant_results[:3]]
    response_parts.append(f"\n**Sources:** {', '.join(sources)}")
    
    return "\n".join(response_parts)

GEMINI_API_KEY = "AIzaSyBOL1MerZ-WZrukiFxhMGRe4UNBcGxdC6I"

def gemini_response(query: str, search_results: list) -> str:
    """Generate a response using Gemini LLM (google-generativeai SDK)"""
    print(f"🔍 Attempting Gemini API call with key: {GEMINI_API_KEY[:20]}...")
    
    try:
        import google.generativeai as genai
        print("✅ google.generativeai imported successfully")
    except ImportError as e:
        error_msg = f"Gemini API error: google-generativeai package not installed. {e}"
        print(f"❌ {error_msg}")
        return error_msg
    
    # Configure API
    try:
        genai.configure(api_key=GEMINI_API_KEY)
        print("✅ Gemini API configured")
    except Exception as e:
        error_msg = f"Gemini API error: Failed to configure API. {e}"
        print(f"❌ {error_msg}")
        return error_msg
    
    context = ""
    for i, case in enumerate(search_results[:3]):
        context += f"Case {i+1}:\nTitle: {case['title']}\nProblem: {case['problem']}\nSolution: {case['solution']}\n\n"
    
    prompt = (
        f"You are a construction expert. Use the following cases to answer the user's question.\n\n"
        f"{context}"
        f"User question: {query}\n\n"
        f"Give a clear, practical answer for a construction site engineer."
    )
    
    try:
        print("🤖 Creating Gemini model: models/gemini-2.5-flash")
        model = genai.GenerativeModel('models/gemini-2.5-flash')
        print("🚀 Calling generate_content...")
        response = model.generate_content(prompt)
        print(f"✅ Gemini response received: {len(response.text)} characters")
        return response.text.strip()
    except Exception as e:
        error_msg = f"Gemini API error: {e}"
        print(f"❌ {error_msg}")
        return error_msg
    
@app.on_event("startup")
async def startup_event():
    """Load data when the app starts"""
    load_cases()

@app.get("/")
async def root():
    """Health check endpoint"""
    return {"status": "Construction Consulting API is running", "cases_loaded": len(cases_df) if cases_df is not None else 0}

@app.post("/chat", response_model=ChatResponse)
async def chat(request: ChatRequest):
    """Main chat endpoint"""
    search_results = simple_search(request.message, request.top_k)
    
    if search_results:
        # Try Gemini first
        gemini_answer = gemini_response(request.message, search_results)
        
        # Check if Gemini failed (error message starts with "Gemini API error:")
        if gemini_answer.startswith("Gemini API error:"):
            print(f"⚠️ Gemini failed: {gemini_answer}")
            # Fall back to simple response
            answer = generate_response(request.message, search_results)
            method = "simple_search_fallback"
        else:
            print(f"✅ Gemini response generated successfully")
            answer = gemini_answer
            method = "gemini"
    else:
        answer = generate_response(request.message, search_results)
        method = "simple_search"
    
    return ChatResponse(
        answer=answer,
        sources=[r['case_id'] for r in search_results[:3] if r['score'] > 0.1],
        best_score=search_results[0]['score'] if search_results else 0.0,
        method=method
    )

if __name__ == "__main__":
    import uvicorn
    port = int(os.getenv("PORT", 8000))
    uvicorn.run(app, host="0.0.0.0", port=port)
