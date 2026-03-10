import sys
import base64
import os
import json
from groq import Groq
from dotenv import load_dotenv

load_dotenv()
client = Groq(api_key=os.getenv("GROQ_API_KEY"))

def analyze_from_mobile(image_path, ipfs_url):
    with open(image_path, "rb") as f:
        img_b64 = base64.b64encode(f.read()).decode('utf-8')

    completion = client.chat.completions.create(
        model="meta-llama/llama-3.2-11b-vision-preview",
        messages=[{
            "role": "user",
            "content": [
                {"type": "text", "text": f"Analyze this CargoLock evidence. IPFS Proof: {ipfs_url}"},
                {"type": "image_url", "image_url": {"url": f"data:image/jpeg;base64,{img_b64}"}}
            ]
        }],
        response_format={"type": "json_object"} 
    )
    return completion.choices[0].message.content

if __name__ == "__main__":
    
    result = analyze_from_mobile(sys.argv[1], sys.argv[2])
    print(result) 