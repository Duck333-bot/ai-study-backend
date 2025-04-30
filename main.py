from fastapi import FastAPI, Request
from fastapi.responses import StreamingResponse
import requests
import os
from dotenv import load_dotenv

load_dotenv()

app = FastAPI()

DEEPSEEK_API_KEY = os.getenv("DEEPSEEK_API_KEY")
DEEPSEEK_URL = "https://api.deepseek.com/chat/completions"

headers = {
    "Content-Type": "application/json",
    "Authorization": f"Bearer {DEEPSEEK_API_KEY}"
}

@app.post("/chat")
async def chat(request: Request):
    body = await request.json()
    user_message = body.get("message", "")

    payload = {
        "model": "deepseek-chat",
        "messages": [
            {"role": "system", "content": "You are a helpful AI study assistant."},
            {"role": "user", "content": user_message}
        ],
        "stream": True,
        "temperature": 0.7
    }

    def stream_response():
        with requests.post(DEEPSEEK_URL, headers=headers, json=payload, stream=True) as response:
            for line in response.iter_lines():
                if line and line.startswith(b"data: "):
                    yield line[6:] + b"\n"

    return StreamingResponse(stream_response(), media_type="text/event-stream")
