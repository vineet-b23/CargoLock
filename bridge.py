import streamlit as st
import requests
import pandas as pd
from datetime import datetime

# --- CONFIGURATION ---
st.set_page_config(page_title="CargoLock | AI Oracle", page_icon="🛡️", layout="wide")

if 'logs' not in st.session_state:
    st.session_state['logs'] = []

def add_log(message):
    timestamp = datetime.now().strftime("%H:%M:%S")
    st.session_state['logs'].insert(0, f"[{timestamp}] {message}")

# --- UI HEADER ---
st.title("🛡️ Sentinel AI: CargoLock Oracle Node")
st.markdown("""**System Status:** <span style="color:green">● Operational</span>  
*Processing Escrow Release Triggers, Penalties, and Reputation Metrics.*""", unsafe_allow_html=True)

# --- SIDEBAR ---
st.sidebar.header("📡 Oracle Settings")
api_url_v2 = st.sidebar.text_input("V2 API Endpoint", "http://127.0.0.1:8000/analyze_v2")
task_mode = st.sidebar.selectbox("Select AI Audit Task", ["fraud", "penalty", "reputation"])

st.sidebar.divider()
st.sidebar.info(f"**Mode:** {task_mode.upper()}\n\nAI is now tuned to the specific logic required for this bonus feature.")

# --- MAIN LAYOUT ---
col_input, col_viz = st.columns([1, 1], gap="large")

with col_input:
    st.subheader("📥 Incoming Node Data")
    
    placeholders = {
        "fraud": "Example: Driver uploaded a blurry photo. GPS shows 10km deviation from delivery zone.",
        "penalty": "Example: Delivery is 3 hours late. Driver reports traffic congestion due to heavy rain.",
        "reputation": "Example: Driver D-01 has completed 200 trips with 0 disputes. All GPS logs are consistent."
    }
    
    raw_data = st.text_area("Event Description:", placeholder=placeholders[task_mode], height=150)

    if st.button("🚀 Execute AI Audit", use_container_width=True):
        if raw_data:
            add_log(f"📡 SIGNAL: Auditing {task_mode} for CargoLock...")
            try:
                payload = {"data_to_check": raw_data, "task": task_mode}
                response = requests.post(api_url_v2, json=payload, timeout=10)
                
                if response.status_code == 200:
                    st.session_state['last_result'] = response.json()
                    add_log(f"✅ VERDICT: {response.json()['verdict']} broadcasted to ledger.")
                else:
                    st.error("AI Brain error. Check Terminal.")
            except Exception as e:
                st.error("Connection Failed! Ensure brain.py is running.")
        else:
            st.warning("Please provide data.")

with col_viz:
    st.subheader("🧠 Oracle Reasoning")
    if 'last_result' in st.session_state:
        res = st.session_state['last_result']
        v = res['verdict']
        
        # Color coding for high-stakes decisions
        if v in ["Verified Delivery", "Excusable Delay", "Exemplary Professional", "Reliable"]:
            st.success(f"### FINAL VERDICT: {v}")
        elif v in ["Fraudulent Proof", "Major Violation", "High Risk"]:
            st.error(f"### FINAL VERDICT: {v}")
        else:
            st.warning(f"### FINAL VERDICT: {v}")

        st.metric("Confidence Score", res['confidence'])
        
        st.write("**Probability Distribution:**")
        chart_data = pd.DataFrame({'Category': list(res['scores'].keys()), 'Score': list(res['scores'].values())})
        st.bar_chart(chart_data.set_index('Category'))
    else:
        st.info("Awaiting blockchain event stream...")

st.divider()
st.subheader("🛰️ Live Connection Log")
if st.session_state['logs']:
    st.code("\n".join(st.session_state['logs'][:5]), language="bash")