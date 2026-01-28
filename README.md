# Construction Consulting Agent

A construction consulting agent that provides expert guidance based on 50+ real construction cases. Built for **cloud deployment** with a clean, minimal interface.

## 🚀 Quick Start

### 1. Clone & Setup
```bash
git clone https://github.com/YOUR_USERNAME/construction-assistant
cd construction-assistant
pip install -r requirements.txt
```

### 2. Test Locally (Optional)
```bash
streamlit run app/ui.py
```

### 3. Deploy to Cloud (FREE)
1. Push to GitHub
2. Deploy on [share.streamlit.io](https://share.streamlit.io)
3. Share your public URL!

## 📁 Project Structure
```
construction-assistant/
├── app/
│   ├── ui.py              # Streamlit interface
│   ├── server.py          # API backend (optional)
│   └── ingest.py          # Data processing
├── data/
│   └── cases.csv          # Construction cases dataset
├── requirements.txt       # Dependencies
└── README.md             # This file
```

## 🌐 Deployment

**Streamlit Community Cloud (FREE)**:
- Zero setup cost
- Automatic HTTPS
- Custom subdomain
- Auto-deploys on git push

See `CLOUD_READY.md` for detailed deployment instructions.

## ✨ Features

- 🏗️ **50+ Real Cases**: Based on actual construction problems
- 🔍 **Smart Search**: Find similar past cases
- 📱 **Mobile-Friendly**: Works on all devices
- ⚡ **Fast**: Lightweight and optimized
- 🆓 **Free**: Deploy at zero cost

## 🛠️ Tech Stack

- **Frontend**: Streamlit (Python web framework)
- **Data**: CSV with construction cases
- **Deployment**: Streamlit Community Cloud
- **Styling**: Custom CSS for professional look

Built with ❤️ for the construction industry.totype

A construction consulting agent that leverages past problems and solutions to provide guidance on new similar issues. Built with **Mistral AI via Ollama** and **100% open-source** vector search using Qdrant.

## � **Completely Open Source & Local**

- **LLM**: Mistral 7B Instruct via Ollama (OpenAI-compatible API)
- **Embeddings**: Nomic Embed Text via Ollama (no external APIs needed)
- **Vector DB**: Qdrant (for semantic search)
- **API**: FastAPI with `/chat` endpoint
- **Session Management**: In-memory chat history

**✅ No external accounts, tokens, or API keys required!**

## 🚀 Quick Start

### Prerequisites

1. **Ollama**: Install from [ollama.com](https://ollama.com)
2. **Docker**: Make sure Docker is installed and running  
3. **Python 3.8+**: Required for the Python dependencies

**✅ No external accounts or API keys needed!**

### Automated Setup

Run the setup script to automatically configure everything:

```bash
chmod +x setup.sh
./setup.sh
```

This script will:
- Check dependencies (Ollama, Docker)
- Start Qdrant vector database  
- Pull Mistral 7B Instruct model
- Pull Nomic Embed Text model (for embeddings)
- Create Python virtual environment
- Install dependencies
- Ingest your cases into the vector database
- Check dependencies
- Start Qdrant vector database
- Pull Mistral 7B Instruct model
- Create Python virtual environment
- Install dependencies
- Ingest your cases into the vector database

### Manual Setup (Alternative)

If you prefer to set up manually:

1. **Install Ollama and pull Mistral**:
   ```bash
   # Install Ollama first, then:
   ollama pull mistral:7b-instruct
   ```

2. **Start Qdrant**:
   ```bash
   docker compose up -d
   ```

3. **Set up Python environment**:
   ```bash
   python3 -m venv .venv
   source .venv/bin/activate
   pip install -r requirements.txt
   ```

4. **Ingest the cases**:
   ```bash
   python app/ingest.py
   ```

## 🏃‍♂️ Running the Agent

1. **Start the API server**:
   ```bash
   source .venv/bin/activate
   uvicorn app.server:app --reload --port 9001
   ```

2. **Test the agent**:
   ```bash
   curl -X POST http://localhost:9001/chat \
     -H "Content-Type: application/json" \
     -d '{"session_id":"demo","message":"Concrete slab shows early cracking after curing. What checks and fixes do we apply first?","top_k":6}'
   ```

3. **Check system status**:
   ```bash
   python status.py
   ```

## 📊 Example Response

```json
{
  "answer": "Based on our internal cases (C-030, C-041), early-age slab cracking typically results from plastic shrinkage due to rapid evaporation and delayed curing...",
  "sources": ["C-030", "C-041"],
  "best_score": 0.852
}
```

## 🔧 API Reference

### POST `/chat`

**Request Body**:
```json
{
  "session_id": "string",    // Unique session identifier
  "message": "string",       // User's question
  "top_k": 6                 // Number of similar cases to retrieve (optional)
}
```

**Response**:
```json
{
  "answer": "string",        // Agent's response
  "sources": ["string"],     // Case IDs used as sources
  "best_score": 0.85         // Confidence score (0-1)
}
```

## 📂 Project Structure

```
internal-agent-proto/
├── app/
│   ├── ingest.py          # Script to load cases into Qdrant
│   └── server.py          # FastAPI agent server
├── data/
│   └── cases.csv          # Construction cases database
├── docker-compose.yml     # Qdrant vector database
├── requirements.txt       # Python dependencies
├── setup.sh              # Automated setup script
└── README.md             # This file
```

## 🗃️ Case Data Format

The `data/cases.csv` file should have these columns:
- `case_id`: Unique identifier (e.g., "C-001")
- `title`: Brief description
- `problem`: Detailed problem description
- `solution`: Detailed solution and prevention measures
- `tags`: Comma-separated tags (e.g., "concrete,qa")

## ⚙️ Configuration

### Confidence Threshold
The agent uses a confidence threshold of 0.25. If the best match scores below this, it returns "Not enough internal evidence to answer."

### Session History
The agent maintains the last 10 exchanges per session in memory for context.

### Chunking
Text is chunked into 1200-character segments for better semantic search.

## 🔍 Troubleshooting

### Ollama Issues
- Make sure Ollama is running: `ollama list`
- Test the OpenAI API: `curl http://localhost:11434/v1/models`

### Qdrant Issues  
- Check if Qdrant is healthy: `curl http://localhost:6333/healthz`
- View logs: `docker compose logs qdrant`

### Python Issues
- Ensure virtual environment is activated: `source .venv/bin/activate`
- Check dependencies: `pip list`

## 🚀 Next Steps

1. **Improve Data Quality**: Enhance your CSV with more detailed problem/solution descriptions
2. **Add Filtering**: Implement tag-based filtering (concrete/MEP/QA/etc.)
3. **Tune Confidence**: Adjust the 0.25 threshold based on your results
4. **Build UI**: Consider adding a Streamlit frontend for easier interaction
5. **Add Authentication**: Implement user management for production use

## 📝 Notes

- The OpenAI compatibility in Ollama is experimental and may have breaking changes
- For 8GB M1 Macs, keep contexts smaller and retrieve fewer chunks
- The agent only uses internal knowledge - it won't answer questions outside your case database


