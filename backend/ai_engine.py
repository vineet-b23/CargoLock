import sys
import base64
import os
import json
from groq import Groq
from dotenv import load_dotenv

load_dotenv()
client = Groq(api_key=os.getenv("GROQ_API_KEY"))

def analyze_from_mobile(image_path, ipfs_url):
    # Same encoding logic you already have
    with open(image_path, "rb") as f:
        img_b64 = base64.b64encode(f.read()).decode('utf-8')

    # Same Groq logic from your app.py
    completion = client.chat.completions.create(
        model="meta-llama/llama-4-scout-17b-16e-instruct",
        messages=[{
            "role": "user",
            "content": [
                {"type": "text", "text": """Analyze this CargoLock evidence. 
                You MUST return ONLY a JSON object with these EXACT keys:
                {
                    "result": "Tire Puncture / Accident / Medical",
                    "summary": "Short description of what you see",
                    "confidence": 95,
                    "status": "VERIFIED"
                }
                Do not include any conversational text before or after the JSON."""},
                {"type": "image_url", "image_url": {"url": f"data:image/jpeg;base64,{img_b64}"}}
            ]
        }],
        response_format={"type": "json_object"}
    )
    return completion.choices[0].message.content

if __name__ == "__main__":
    # Node.js will call this script and pass the image path + IPFS link
    result = analyze_from_mobile(sys.argv[1], sys.argv[2])
    print(result) # This "sends" the result back to your Node.js server