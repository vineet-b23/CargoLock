from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI()

class AIRequest(BaseModel):
    text: String

@app.post("/process")
async def process_ai(request: AIRequest):
    result = f"AI Processed: {request.text}" 
    return {"response": result}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)