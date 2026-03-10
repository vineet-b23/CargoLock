from fastapi import FastAPI
from pydantic import BaseModel
from transformers import pipeline
import uvicorn
app = FastAPI(title="Sentinel AI Oracle")
print("Loading Sentinel Brain... Standing by.")
classifier = pipeline("zero-shot-classification", model="facebook/bart-large-mnli")
print("Brain Ready! Oracle is Online.")

class MultiTaskRequest(BaseModel):
    data_to_check: str
    task: str 

@app.post("/analyze_v2")
async def analyze_v2(request: MultiTaskRequest):
    text = request.data_to_check.lower()
    if any(word in text for word in ["year", "month", "decade"]):
        return {
            "verdict": "Major Violation",
            "confidence": "99.9% (Logic-Gate)",
            "scores": {"Major Violation": 1.0, "Minor Negligence": 0.0, "Normal Operations": 0.0}
        }
    if request.task == "fraud":
        labels = ["Verified Delivery", "Fraudulent Proof", "Suspicious Activity"]
    elif request.task == "penalty":
        labels = [
            "Normal Operations", 
            "Excusable Delay", 
            "Minor Negligence", 
            "Major Violation"
        ]
    elif request.task == "reputation":
        labels = ["Exemplary Professional", "Reliable", "Needs Improvement", "High Risk"]
    else:
        labels = ["General Audit Required"]
    result = classifier(request.data_to_check, candidate_labels=labels)
    return {
        "verdict": result['labels'][0],
        "confidence": f"{result['scores'][0] * 100:.2f}%",
        "scores": dict(zip(result['labels'], result['scores']))
    }
if __name__ == "__main__":
    uvicorn.run(app, host="127.0.0.1", port=8000)