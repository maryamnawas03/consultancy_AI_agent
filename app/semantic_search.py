"""
Semantic Search with Embeddings for Construction Cases
Uses sentence-transformers to generate embeddings and find semantically similar cases
"""
import pandas as pd
import numpy as np
import pickle
import os
from pathlib import Path
from typing import List, Dict, Any, Optional
from sentence_transformers import SentenceTransformer
from sklearn.metrics.pairwise import cosine_similarity
import re

class SemanticSearchEngine:
    """Semantic search engine using sentence-transformers"""
    
    def __init__(self, model_name: str = 'all-MiniLM-L6-v2', cache_dir: str = 'data'):
        """
        Initialize the semantic search engine
        
        Args:
            model_name: Name of the sentence-transformers model to use
                       'all-MiniLM-L6-v2' is lightweight and fast (22MB, 384 dims)
                       'all-mpnet-base-v2' is more accurate but larger (420MB, 768 dims)
            cache_dir: Directory to cache embeddings
        """
        self.model_name = model_name
        
        # Handle cache directory path (try both relative and absolute)
        if os.path.isabs(cache_dir):
            self.cache_dir = Path(cache_dir)
        else:
            # Try relative paths
            for candidate in [cache_dir, f"../{cache_dir}"]:
                if os.path.exists(candidate):
                    self.cache_dir = Path(candidate)
                    break
            else:
                # Default to the first path
                self.cache_dir = Path(cache_dir)
        
        self.cache_dir.mkdir(parents=True, exist_ok=True)
        self.cache_file = self.cache_dir / f'embeddings_{model_name.replace("/", "_")}.pkl'
        
        print(f"🔄 Loading semantic search model: {model_name}")
        self.model = SentenceTransformer(model_name)
        print(f"✅ Model loaded: {model_name}")
        
        self.embeddings = None
        self.cases_df = None
        self.cases_text = None
        
    def _create_text_representation(self, row: pd.Series) -> str:
        """Create a comprehensive text representation of a case for embedding"""
        parts = []
        
        # Title is most important
        if pd.notna(row.get('title')):
            parts.append(f"Title: {row['title']}")
        
        # Problem description
        if pd.notna(row.get('problem')):
            parts.append(f"Problem: {row['problem']}")
        
        # Solution
        if pd.notna(row.get('solution')):
            parts.append(f"Solution: {row['solution']}")
        
        # Tags (expanded to be more searchable)
        if pd.notna(row.get('tags')):
            tags = row['tags'].replace(',', ', ')
            parts.append(f"Tags: {tags}")
        
        return " | ".join(parts)
    
    def load_and_embed_cases(self, cases_df: pd.DataFrame, force_refresh: bool = False) -> None:
        """
        Load cases and generate embeddings (with caching)
        
        Args:
            cases_df: DataFrame containing the cases
            force_refresh: If True, regenerate embeddings even if cache exists
        """
        self.cases_df = cases_df
        
        # Check if we can load from cache
        if not force_refresh and self.cache_file.exists():
            try:
                print(f"📦 Loading cached embeddings from {self.cache_file}")
                with open(self.cache_file, 'rb') as f:
                    cache_data = pickle.load(f)
                    
                # Verify cache is valid for current data
                if (len(cache_data['cases_text']) == len(cases_df) and 
                    cache_data['model_name'] == self.model_name):
                    self.embeddings = cache_data['embeddings']
                    self.cases_text = cache_data['cases_text']
                    print(f"✅ Loaded {len(self.embeddings)} cached embeddings")
                    return
                else:
                    print("⚠️ Cache invalid (data changed), regenerating embeddings")
            except Exception as e:
                print(f"⚠️ Error loading cache: {e}, regenerating embeddings")
        
        # Generate embeddings
        print(f"🔄 Generating embeddings for {len(cases_df)} cases...")
        self.cases_text = [self._create_text_representation(row) for _, row in cases_df.iterrows()]
        
        # Generate embeddings in batches for efficiency
        self.embeddings = self.model.encode(
            self.cases_text,
            show_progress_bar=True,
            batch_size=32,
            convert_to_numpy=True
        )
        
        print(f"✅ Generated {len(self.embeddings)} embeddings (shape: {self.embeddings.shape})")
        
        # Cache the embeddings
        try:
            self.cache_dir.mkdir(parents=True, exist_ok=True)
            cache_data = {
                'embeddings': self.embeddings,
                'cases_text': self.cases_text,
                'model_name': self.model_name
            }
            with open(self.cache_file, 'wb') as f:
                pickle.dump(cache_data, f)
            print(f"💾 Cached embeddings to {self.cache_file}")
        except Exception as e:
            print(f"⚠️ Could not cache embeddings: {e}")
    
    def semantic_search(self, query: str, top_k: int = 6) -> List[Dict[str, Any]]:
        """
        Perform semantic search using embeddings
        
        Args:
            query: User's query text
            top_k: Number of results to return
            
        Returns:
            List of dictionaries containing case info and similarity scores
        """
        if self.embeddings is None or self.cases_df is None:
            raise ValueError("No embeddings loaded. Call load_and_embed_cases() first.")
        
        # Encode the query
        query_embedding = self.model.encode([query], convert_to_numpy=True)
        
        # Calculate cosine similarity
        similarities = cosine_similarity(query_embedding, self.embeddings)[0]
        
        # Get top results
        top_indices = np.argsort(similarities)[::-1][:top_k]
        
        results = []
        for idx in top_indices:
            row = self.cases_df.iloc[idx]
            results.append({
                'case_id': str(row.get('case_id', '')),
                'title': str(row.get('title', '')),
                'problem': str(row.get('problem', '')),
                'solution': str(row.get('solution', '')),
                'tags': str(row.get('tags', '')),
                'score': float(similarities[idx]),  # Cosine similarity (0-1)
                'method': 'semantic'
            })
        
        return results
    
    def keyword_search(self, query: str, top_k: int = 6) -> List[Dict[str, Any]]:
        """
        Keyword-based search (original method) for comparison
        
        Args:
            query: User's query text
            top_k: Number of results to return
            
        Returns:
            List of dictionaries containing case info and keyword scores
        """
        if self.cases_df is None:
            raise ValueError("No cases loaded.")
        
        query_lower = query.lower()
        query_words = set(re.findall(r'\w+', query_lower))
        
        scores = []
        
        for idx, row in self.cases_df.iterrows():
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
                'score': score,
                'method': 'keyword'
            })
        
        scores.sort(key=lambda x: x['score'], reverse=True)
        return scores[:top_k]
    
    def hybrid_search(self, query: str, top_k: int = 6, 
                     semantic_weight: float = 0.7, keyword_weight: float = 0.3) -> List[Dict[str, Any]]:
        """
        Hybrid search combining semantic and keyword-based approaches
        
        Args:
            query: User's query text
            top_k: Number of results to return
            semantic_weight: Weight for semantic similarity (0-1)
            keyword_weight: Weight for keyword matching (0-1)
            
        Returns:
            List of dictionaries containing case info and hybrid scores
        """
        # Get both types of results
        semantic_results = self.semantic_search(query, top_k=top_k*2)  # Get more for hybrid
        keyword_results = self.keyword_search(query, top_k=top_k*2)
        
        # Normalize scores to 0-1 range
        if semantic_results:
            max_sem_score = max(r['score'] for r in semantic_results)
            if max_sem_score > 0:
                for r in semantic_results:
                    r['score'] = r['score'] / max_sem_score
        
        if keyword_results:
            max_kw_score = max(r['score'] for r in keyword_results)
            if max_kw_score > 0:
                for r in keyword_results:
                    r['score'] = r['score'] / max_kw_score
        
        # Combine scores
        combined = {}
        
        for result in semantic_results:
            case_id = result['case_id']
            combined[case_id] = {
                **result,
                'semantic_score': result['score'],
                'keyword_score': 0.0,
                'score': result['score'] * semantic_weight,
                'method': 'hybrid'
            }
        
        for result in keyword_results:
            case_id = result['case_id']
            if case_id in combined:
                combined[case_id]['keyword_score'] = result['score']
                combined[case_id]['score'] += result['score'] * keyword_weight
            else:
                combined[case_id] = {
                    **result,
                    'semantic_score': 0.0,
                    'keyword_score': result['score'],
                    'score': result['score'] * keyword_weight,
                    'method': 'hybrid'
                }
        
        # Sort by combined score
        results = list(combined.values())
        results.sort(key=lambda x: x['score'], reverse=True)
        
        return results[:top_k]


# Global instance for the application
_search_engine: Optional[SemanticSearchEngine] = None


def get_search_engine(model_name: str = 'all-MiniLM-L6-v2') -> SemanticSearchEngine:
    """Get or create the global search engine instance"""
    global _search_engine
    if _search_engine is None:
        _search_engine = SemanticSearchEngine(model_name=model_name)
    return _search_engine


def initialize_search(cases_df: pd.DataFrame, model_name: str = 'all-MiniLM-L6-v2', 
                      force_refresh: bool = False) -> SemanticSearchEngine:
    """
    Initialize the semantic search engine with cases data
    
    Args:
        cases_df: DataFrame containing the cases
        model_name: Name of the sentence-transformers model
        force_refresh: If True, regenerate embeddings even if cache exists
        
    Returns:
        Initialized SemanticSearchEngine instance
    """
    engine = get_search_engine(model_name)
    engine.load_and_embed_cases(cases_df, force_refresh=force_refresh)
    return engine
