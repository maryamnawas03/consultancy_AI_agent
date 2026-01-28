"""
Standalone search functionality for when backend API is not available
Uses simple text matching on the cases data
"""
import pandas as pd
import re
from typing import List, Dict, Any
import os

def load_cases_data():
    """Load the cases CSV file"""
    try:
        # Try relative path first (for Streamlit Cloud)
        if os.path.exists("data/cases.csv"):
            return pd.read_csv("data/cases.csv")
        # Try from app directory
        elif os.path.exists("../data/cases.csv"):
            return pd.read_csv("../data/cases.csv")
        else:
            # If we can't find the file, return empty dataframe
            return pd.DataFrame()
    except Exception as e:
        print(f"Error loading cases data: {e}")
        return pd.DataFrame()

def simple_search(query: str, top_k: int = 6) -> List[Dict[str, Any]]:
    """
    Simple text-based search when vector search is not available
    """
    df = load_cases_data()
    
    if df.empty:
        return []
    
    # Convert query to lowercase for matching
    query_lower = query.lower()
    query_words = set(re.findall(r'\w+', query_lower))
    
    scores = []
    
    for idx, row in df.iterrows():
        # Combine all text fields
        text_fields = [
            str(row.get('title', '')),
            str(row.get('problem', '')),
            str(row.get('solution', '')),
            str(row.get('tags', ''))
        ]
        
        full_text = ' '.join(text_fields).lower()
        text_words = set(re.findall(r'\w+', full_text))
        
        # Calculate simple word overlap score
        common_words = query_words.intersection(text_words)
        score = len(common_words) / max(len(query_words), 1)
        
        # Boost score for exact phrase matches
        if query_lower in full_text:
            score += 0.5
        
        # Boost score for matches in title
        if any(word in str(row.get('title', '')).lower() for word in query_words):
            score += 0.3
        
        # Boost score for tag matches
        tags = str(row.get('tags', '')).lower()
        if any(word in tags for word in query_words):
            score += 0.2
        
        scores.append({
            'case_id': str(row.get('case_id', '')),
            'title': str(row.get('title', '')),
            'problem': str(row.get('problem', '')),
            'solution': str(row.get('solution', '')),
            'tags': str(row.get('tags', '')),
            'score': score,
            'full_text': ' '.join(text_fields)
        })
    
    # Sort by score and return top results
    scores.sort(key=lambda x: x['score'], reverse=True)
    return scores[:top_k]

def generate_response(query: str, search_results: List[Dict[str, Any]]) -> str:
    """
    Generate a response based on search results
    """
    if not search_results:
        return "I couldn't find any relevant cases for your query. Please try rephrasing your question or check if it's related to construction problems covered in our database."
    
    # Filter results with meaningful scores
    relevant_results = [r for r in search_results if r['score'] > 0.1]
    
    if not relevant_results:
        return "I found some potentially related cases, but they may not be directly relevant to your specific question. Please try being more specific about the construction problem you're facing."
    
    # Build response
    response_parts = []
    response_parts.append("Based on similar cases in our database:\n")
    
    # Add main response based on top result
    top_result = relevant_results[0]
    response_parts.append(f"**Primary Recommendation (Case {top_result['case_id']}):**")
    response_parts.append(f"*{top_result['title']}*\n")
    response_parts.append(f"**Problem:** {top_result['problem']}\n")
    response_parts.append(f"**Solution:** {top_result['solution']}\n")
    
    # Add additional relevant cases
    if len(relevant_results) > 1:
        response_parts.append("\n**Additional Related Cases:**")
        for result in relevant_results[1:3]:  # Show up to 2 more
            response_parts.append(f"• **{result['case_id']}**: {result['title']}")
    
    # Add sources
    sources = [f"Case {r['case_id']}" for r in relevant_results[:3]]
    response_parts.append(f"\n**Sources:** {', '.join(sources)}")
    
    return "\n".join(response_parts)

def fallback_chat(query: str, top_k: int = 6) -> Dict[str, Any]:
    """
    Main fallback function that mimics the API response format
    """
    search_results = simple_search(query, top_k)
    answer = generate_response(query, search_results)
    
    return {
        "answer": answer,
        "sources": [r['case_id'] for r in search_results[:3] if r['score'] > 0.1],
        "best_score": search_results[0]['score'] if search_results else 0.0,
        "method": "fallback_search"
    }
