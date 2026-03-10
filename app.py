import streamlit as st
import base64
from groq import Groq
import os
from dotenv import load_dotenv
load_dotenv()
GROQ_API_KEY = os.getenv("GROQ_API_KEY") 
client = Groq(api_key=GROQ_API_KEY)

def encode_image(uploaded_file):
    """Convert Streamlit file to base64 string."""
    return base64.b64encode(uploaded_file.getvalue()).decode('utf-8')

def analyze_claim(base64_image):
    """Send image to Groq for analysis using Llama 4 Scout."""
    completion = client.chat.completions.create(
        model="meta-llama/llama-4-scout-17b-16e-instruct", # Updated for 2026
        messages=[
            {
                "role": "user",
                "content": [
                    {
                        "type": "text", 
                        "text": """As a CargoLock verification expert, analyze this evidence:
                        1. CATEGORY: Identify if this is a Tire Puncture, Accident, or Medical Bill.
                        2. DATA EXTRACTION: Extract dates, names, and currency amounts.
                        3. VERIFICATION: Does the image content match the claimed category?
                        
                        Format your response as follows:
                        RESULT: [Category]
                        SUMMARY: [Key Details]
                        CONFIDENCE: [0-100]%"""
                    },
                    {
                        "type": "image_url",
                        "image_url": {"url": f"data:image/jpeg;base64,{base64_image}"}
                    }
                ]
            }
        ],
        temperature=0.1,
        max_tokens=1024
    )
    return completion.choices[0].message.content
st.set_page_config(page_title="CargoLock AI", page_icon="🚚")
st.title("🚚 CargoLock | Dispute Verification")
st.markdown("Automated evidence analysis powered by Groq LPU.")

with st.sidebar:
    st.header("Settings")
    st.info("Currently using: Llama 3.2 Vision (11B)")
    if not GROQ_API_KEY:
        st.warning("API Key not found! Add it to your .env file.")

uploaded_file = st.file_uploader("Upload Evidence (Receipt, Bill, or Photo)", type=['jpg', 'jpeg', 'png'])

if uploaded_file:
    st.image(uploaded_file, caption="Evidence Preview", use_container_width=True)
    
    if st.button("Run AI Verification"):
        with st.spinner("Analyzing evidence at lightning speed..."):
            try:
                img_b64 = encode_image(uploaded_file)
                analysis = analyze_claim(img_b64)
                st.subheader("Verification Results")
                st.code(analysis, language="markdown")
                if "MATCH:" in analysis:
                    st.success("Analysis successful. Check the categorization above.")
            except Exception as e:
                st.error(f"Error: {e}")
                st.info("Tip: Check if your Groq API key is valid or if you have hit a rate limit.")