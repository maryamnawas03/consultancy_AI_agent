import os
import requests
from fastapi import FastAPI
from pydantic import BaseModel
from qdrant_client import QdrantClient
from openai import OpenAI

COLLECTION = "cases"
OLLAMA_BASE = "http://localhost:11434"

def get_ollama_embedding(text: str):
    """Get embedding from Ollama (100% local & open-source)"""
    try:
        response = requests.post(
            f"{OLLAMA_BASE}/api/embeddings",
            json={"model": "nomic-embed-text", "prompt": text},
            timeout=120  # Increased timeout for M1 Air
        )
        if response.status_code == 200:
            return response.json()["embedding"]
        else:
            raise Exception(f"Ollama embedding failed: {response.text}")
    except Exception as e:
        print(f"❌ Error getting embedding: {e}")
        raise

# Ollama OpenAI-compatible endpoint
client = OpenAI(base_url="http://localhost:11434/v1", api_key="ollama")  # required but ignored

qdrant = QdrantClient(url="http://localhost:6333")

app = FastAPI()
CHAT_HISTORY = {}

class ChatRequest(BaseModel):
    session_id: str
    message: str
    top_k: int = 6

SYSTEM = """You are an internal construction consulting assistant.
Rules:
- Use ONLY the provided internal context (retrieved cases).
- If context is insufficient, say: "Not enough internal evidence to answer."
- Always include Sources: with the case_id(s) you used.
- Keep it practical: checks, steps, risks, and what info is missing.
"""

def retrieve(query: str, top_k: int):
    qvec = get_ollama_embedding(query)
    return qdrant.query_points(collection_name=COLLECTION, query=qvec, limit=top_k, with_payload=True).points

@app.post("/chat")
def chat(req: ChatRequest):
    hits = retrieve(req.message, req.top_k)

    if not hits:
        return {"answer": "Not enough internal evidence to answer.", "sources": []}

    # Simple confidence gate (prototype)
    best_score = hits[0].score if hits else 0.0
    if best_score < 0.25:
        return {"answer": "Not enough internal evidence to answer.", "sources": []}

    context_blocks = []
    sources = []
    for h in hits:
        p = h.payload or {}
        cid = p.get("case_id", "unknown")
        sources.append(cid)
        context_blocks.append(f"[case_id={cid} score={h.score:.3f}]\n{p.get('text','')}\n")

    context = "\n---\n".join(context_blocks)

    # Keep lightweight session history (optional)
    hist = CHAT_HISTORY.get(req.session_id, [])
    hist_text = ""
    if hist:
        hist_text = "\n".join([f"User: {x['u']}\nAssistant: {x['a']}" for x in hist[-3:]])

    user_prompt = f"""Question:
{req.message}

Recent chat (optional):
{hist_text}

Internal context (use only this):
{context}
"""

    resp = client.chat.completions.create(
        model="mistral:7b-instruct",
        messages=[
            {"role": "system", "content": SYSTEM},
            {"role": "user", "content": user_prompt},
        ],
        temperature=0.2,
    )

    answer = resp.choices[0].message.content

    # update history
    hist.append({"u": req.message, "a": answer})
    CHAT_HISTORY[req.session_id] = hist[-10:]

    return {"answer": answer, "sources": sorted(set(sources)), "best_score": best_score}
