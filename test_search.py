#!/usr/bin/env python3
"""
Test search functionality without AI backend
"""
import pandas as pd
import re
from typing import List, Dict

def load_cases(file_path: str) -> pd.DataFrame:
    """Load construction cases from CSV"""
    return pd.read_csv(file_path)

def simple_search(query: str, cases_df: pd.DataFrame, top_k: int = 5) -> List[Dict]:
    """Simple keyword-based search"""
    query_lower = query.lower()
    query_words = re.findall(r'\w+', query_lower)
    
    results = []
    
    for idx, case in cases_df.iterrows():
        # Combine all text fields for searching
        search_text = f"{case['title']} {case['problem']} {case['solution']} {case['tags']}".lower()
        
        # Count keyword matches
        score = 0
        for word in query_words:
            score += search_text.count(word)
        
        if score > 0:
            results.append({
                'case_id': case['case_id'],
                'title': case['title'],
                'problem': case['problem'],
                'solution': case['solution'],
                'score': score
            })
    
    # Sort by score and return top results
    results.sort(key=lambda x: x['score'], reverse=True)
    return results[:top_k]

def test_search():
    """Test the search functionality"""
    print("🔍 Testing Construction Case Search")
    print("=" * 50)
    
    # Load cases
    try:
        cases_df = load_cases('data/cases.csv')
        print(f"✅ Loaded {len(cases_df)} construction cases")
    except Exception as e:
        print(f"❌ Error loading cases: {e}")
        return
    
    # Test queries
    test_queries = [
        "HVAC system has low airflow complaints. What to check?",
        "concrete cracking after curing",
        "rebar cover nonconformance",
        "cable tray overfilled",
        "wet tile debonding bathroom"
    ]
    
    for query in test_queries:
        print(f"\n🔎 Query: '{query}'")
        print("-" * 30)
        
        results = simple_search(query, cases_df, top_k=3)
        
        if results:
            for i, result in enumerate(results, 1):
                print(f"\n{i}. [{result['case_id']}] {result['title']}")
                print(f"   Score: {result['score']}")
                print(f"   Problem: {result['problem'][:100]}...")
                print(f"   Solution: {result['solution'][:100]}...")
        else:
            print("   No matching cases found")
    
    print(f"\n✅ Search test completed!")

if __name__ == "__main__":
    test_search()
