import uuid
import pandas as pd
import requests
import json
from qdrant_client import QdrantClient
from qdrant_client.models import Distance, VectorParams, PointStruct

COLLECTION = "cases"
OLLAMA_BASE = "http://localhost:11434"

def get_ollama_embedding(text: str):
    """Get embedding from Ollama (100% local & open-source)"""
    try:
        response = requests.post(
            f"{OLLAMA_BASE}/api/embeddings",
            json={"model": "nomic-embed-text", "prompt": text},
            timeout=30
        )
        if response.status_code == 200:
            return response.json()["embedding"]
        else:
            raise Exception(f"Ollama embedding failed: {response.text}")
    except Exception as e:
        print(f"❌ Error getting embedding: {e}")
        raise

def chunk_text(text: str, max_chars: int = 1200):
    text = (text or "").strip()
    if not text:
        return []
    return [text[i:i+max_chars] for i in range(0, len(text), max_chars)]

def main():
    print("🚀 Using Ollama embeddings (100% local & open-source)")
    
    # First, pull the embedding model
    print("📥 Pulling nomic-embed-text model...")
    try:
        pull_response = requests.post(
            f"{OLLAMA_BASE}/api/pull",
            json={"name": "nomic-embed-text"}
        )
        print("✅ Model ready")
    except Exception as e:
        print(f"⚠️  Warning: Could not pull model automatically: {e}")
        print("   Please run: ollama pull nomic-embed-text")
    
    df = pd.read_csv("data/cases.csv")
    
    # Test embedding to get dimension
    print("🔍 Testing embedding...")
    test_vec = get_ollama_embedding("test")
    dim = len(test_vec)
    print(f"📊 Embedding dimension: {dim}")

    qdrant = QdrantClient(url="http://localhost:6333")
    existing = [c.name for c in qdrant.get_collections().collections]
    if COLLECTION not in existing:
        qdrant.create_collection(
            collection_name=COLLECTION,
            vectors_config=VectorParams(size=dim, distance=Distance.COSINE),
        )

    points = []
    total_rows = len(df)
    for idx, row in df.iterrows():
        case_id = str(row.get("case_id", "")).strip()
        title = str(row.get("title", "")).strip()
        problem = str(row.get("problem", "")).strip()
        solution = str(row.get("solution", "")).strip()
        tags = str(row.get("tags", "")).strip()

        full = f"TITLE: {title}\nPROBLEM: {problem}\nSOLUTION: {solution}\nTAGS: {tags}"
        
        for chunk_idx, chunk in enumerate(chunk_text(full)):
            print(f"🔄 Processing case {case_id} ({idx+1}/{total_rows}), chunk {chunk_idx+1}")
            vec = get_ollama_embedding(chunk)
            points.append(PointStruct(
                id=str(uuid.uuid4()),
                vector=vec,
                payload={
                    "case_id": case_id,
                    "title": title,
                    "chunk_index": chunk_idx,
                    "tags": tags,
                    "text": chunk
                }
            ))

    qdrant.upsert(collection_name=COLLECTION, points=points)
    print(f"✅ Indexed {len(points)} chunks into '{COLLECTION}'")

if __name__ == "__main__":
    main()
