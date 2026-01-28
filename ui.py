"""
Simple ChatGPT-like UI for Construction Consulting Agent
"""
import streamlit as st
import requests
import time
import os

# Configure the page
st.set_page_config(
    page_title="Construction Consulting Agent",
    page_icon="🏗️",
    layout="centered",
    initial_sidebar_state="collapsed"
)

# Simple, clean CSS inspired by ChatGPT
st.markdown("""
<style>
    /* Main app styling */
    .stApp {
        background-color: #ffffff;
        color: #343434;
        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
    }
    
    /* Header */
    .main-title {
        text-align: center;
        padding: 2rem 0 1rem 0;
        color: #2c3e50;
    }
    
    .main-title h1 {
        font-size: 2rem;
        font-weight: 600;
        margin-bottom: 0.5rem;
    }
    
    .main-title p {
        color: #6b7280;
        font-size: 1rem;
        margin: 0;
    }
    
    /* Chat messages */
    .chat-message {
        margin: 1rem 0;
        padding: 1rem 1.5rem;
        border-radius: 12px;
        line-height: 1.6;
        box-shadow: 0 1px 3px rgba(0,0,0,0.1);
    }
    
    .user-message {
        background-color: #1565c0;
        color: white;
        margin-left: 2rem;
        margin-right: 0.5rem;
    }
    
    .assistant-message {
        background-color: #f8f9fa;
        color: #2c3e50;
        margin-right: 2rem;
        margin-left: 0.5rem;
        border: 1px solid #e9ecef;
    }
    
    /* Sample question buttons */
    .stButton > button {
        width: 100%;
        margin: 0.5rem auto;
        padding: 1.2rem 1.5rem;
        background-color: #f8f9fa;
        border: 2px solid #dee2e6;
        border-radius: 12px;
        color: #495057;
        text-align: center;
        transition: all 0.3s ease;
        font-size: 1rem;
        font-weight: 500;
        height: 80px;
        display: flex;
        align-items: center;
        justify-content: center;
        box-shadow: 0 2px 6px rgba(0,0,0,0.08);
        line-height: 1.3;
        word-wrap: break-word;
        overflow: hidden;
    }
    
    .stButton > button:hover {
        background-color: #e9ecef;
        border-color: #1565c0;
        transform: translateY(-3px);
        box-shadow: 0 6px 16px rgba(21, 101, 192, 0.15);
        color: #1565c0;
    }
    
    /* Button container for consistent spacing */
    .stButton {
        margin: 0.6rem 0;
        text-align: center;
    }
    
    /* Hide Streamlit default elements */
    .stDeployButton {display: none;}
    header[data-testid="stHeader"] {display: none;}
    .stMainBlockContainer {padding-top: 1rem;}
    
    /* Loading spinner */
    .stSpinner > div {
        text-align: center;
        color: #6c757d;
    }
    
    /* Error messages */
    .stAlert {
        border-radius: 8px;
        margin: 1rem 0;
    }
    
    /* Clear chat button - smaller height */
    .stButton[data-testid="stButton"] button[kind="secondary"] {
        height: 40px;
        padding: 0.5rem 1rem;
        font-size: 0.9rem;
    }
</style>
""", unsafe_allow_html=True)

# API configuration - use environment variable for cloud deployment
API_URL = os.getenv("API_URL", "http://localhost:8000/chat")

# Try to import fallback search for when API is not available
try:
    from fallback_search import fallback_chat
    FALLBACK_AVAILABLE = True
except ImportError:
    FALLBACK_AVAILABLE = False
    fallback_chat = None

# Initialize session state
if "messages" not in st.session_state:
    st.session_state.messages = []
if "session_id" not in st.session_state:
    st.session_state.session_id = f"streamlit-{int(time.time())}"

def process_user_message(prompt):
    """Process user message and get response from agent"""
    # Add user message first
    st.session_state.messages.append({"role": "user", "content": prompt})
    
    # Force a rerun to show the user message immediately
    st.rerun()

# Simple header
st.markdown("""
<div class="main-title">
    <h1>🏗️ Construction Assistant</h1>
    <p>Get expert guidance based on 50+ construction cases</p>
</div>
""", unsafe_allow_html=True)

# Display chat messages
for message in st.session_state.messages:
    if message["role"] == "user":
        st.markdown(f"""
        <div class="chat-message user-message">
            <strong>You:</strong><br>{message["content"]}
        </div>
        """, unsafe_allow_html=True)
    else:
        st.markdown(f"""
        <div class="chat-message assistant-message">
            <strong>Assistant:</strong><br>{message["content"]}
        </div>
        """, unsafe_allow_html=True)
        
        # Show sources if available
        if "sources" in message and message["sources"]:
            st.caption(f"📚 **Sources**: {', '.join(message['sources'])}")

# Process pending user message if it needs a response
if (st.session_state.messages and 
    st.session_state.messages[-1]["role"] == "user"):
    
    # Simple check: if last message is user and second-to-last is not assistant, we need response
    needs_response = True
    if len(st.session_state.messages) >= 2:
        if st.session_state.messages[-2]["role"] == "assistant":
            needs_response = False
    
    if needs_response:
        last_user_msg = st.session_state.messages[-1]["content"]
        with st.spinner("🔍 Searching through 50 construction cases..."):
            try:
                payload = {
                    "session_id": st.session_state.session_id,
                    "message": last_user_msg,
                    "top_k": 6
                }
                
                response = requests.post(API_URL, json=payload, timeout=180)
                response.raise_for_status()
                result = response.json()
                
                answer = result["answer"]
                sources = result.get("sources", [])
                confidence = result.get("best_score", 0.0)
                
                # Add assistant response
                st.session_state.messages.append({
                    "role": "assistant",
                    "content": answer,
                    "sources": sources,
                    "confidence": confidence
                })
                st.rerun()
                
            except requests.exceptions.ConnectionError:
                # Try fallback search if available
                if FALLBACK_AVAILABLE:
                    try:
                        result = fallback_chat(last_user_msg)
                        st.session_state.messages.append({
                            "role": "assistant",
                            "content": result["answer"] + "\n\n*Note: Using offline search since API is unavailable.*",
                            "sources": result.get("sources", []),
                            "confidence": result.get("best_score", 0.0)
                        })
                    except Exception as e:
                        st.session_state.messages.append({
                            "role": "assistant", 
                            "content": f"❌ Both API and offline search failed. Error: {str(e)}"
                        })
                else:
                    st.session_state.messages.append({
                        "role": "assistant", 
                        "content": "❌ Connection failed. The backend API is currently unavailable and offline mode is not enabled."
                    })
                st.rerun()
                
            except requests.exceptions.Timeout:
                st.session_state.messages.append({
                    "role": "assistant", 
                    "content": "⏰ Request timed out. The server might be overloaded. Please try again."
                })
                st.rerun()
                
            except requests.exceptions.HTTPError as e:
                st.session_state.messages.append({
                    "role": "assistant", 
                    "content": f"🔥 Server error: {str(e)}"
                })
                st.rerun()
                
            except Exception as e:
                st.session_state.messages.append({
                    "role": "assistant", 
                    "content": f"❌ Unexpected error: {str(e)}"
                })
                st.rerun()

# Sample questions (only show when no conversation)
if not st.session_state.messages:
    st.markdown("### 💡 Try asking about:")
    
    sample_questions = [
        "Concrete slab shows early cracking after curing. What should I do?",
        "Found rebar cover nonconformance during inspection. How to fix?",
        "Cable tray is overfilled and there's overheating risk. Solutions?",
        "What causes honeycombing in concrete and how to repair it?",
        "HVAC system has low airflow complaints. What to check?",
        "Paint is blistering after finishing. Root causes and fixes?"
    ]
    
    for i, question in enumerate(sample_questions):
        if st.button(question, key=f"sample_{i}"):
            process_user_message(question)

# Chat input  
if prompt := st.chat_input("Ask about a construction problem..."):
    process_user_message(prompt)

# Footer with helpful info
if st.session_state.messages:
    st.markdown("---")
    col1, col2, col3 = st.columns([1, 1, 1])
    
    with col2:
        if st.button("🗑️ Clear Chat", type="secondary", use_container_width=True):
            st.session_state.messages = []
            st.rerun()

# Show helpful tips for new users
if not st.session_state.messages:
    with st.expander("ℹ️ How to use this assistant"):
        st.markdown("""
        **Your Construction Assistant**:
        - 🏗️ **50+ Real Cases**: Answers based on actual construction problems and solutions
        - 🔍 **Smart Search**: Finds similar past cases using AI
        - 📚 **Source Citations**: Shows which cases informed each answer
        - ⚡ **First Query**: May take 30-60 seconds as AI model loads
        - 🚀 **Subsequent Queries**: Much faster (5-15 seconds)
        
        **Tips for Better Results**:
        - Be specific about the problem (materials, symptoms, context)
        - Mention relevant details (timeframes, conditions, specifications)
        - Ask follow-up questions to get more detailed guidance
        """)

# Cloud deployment info
st.sidebar.markdown("### 🌐 Deployment Info")
st.sidebar.info(f"API Endpoint: {API_URL}")
if API_URL.startswith("http://localhost"):
    st.sidebar.warning("⚠️ Running in local mode")
else:
    st.sidebar.success("☁️ Connected to cloud API")
