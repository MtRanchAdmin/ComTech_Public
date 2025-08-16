#!/usr/bin/env python3
"""
Oracle Cloud LLM Proxy for Cursor AI-IDE
This script acts as a proxy between Cursor and your Oracle Cloud LLM,
converting OpenAI-compatible requests to Oracle Cloud LLM format.
"""

import json
import requests
import os
from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

# Oracle Cloud LLM Configuration
ORACLE_API_ENDPOINT = os.getenv('ORACLE_API_ENDPOINT', 'https://your-oracle-endpoint.com/api/v1')
ORACLE_API_KEY = os.getenv('ORACLE_API_KEY', 'your-oracle-api-key')
ORACLE_MODEL_NAME = os.getenv('ORACLE_MODEL_NAME', 'your-model-name')

def convert_openai_to_oracle_format(openai_request):
    """Convert OpenAI-compatible request to Oracle Cloud LLM format"""
    
    messages = openai_request.get('messages', [])
    model = openai_request.get('model', ORACLE_MODEL_NAME)
    temperature = openai_request.get('temperature', 0.7)
    max_tokens = openai_request.get('max_tokens', 4096)
    
    # Convert messages to Oracle format
    oracle_messages = []
    for msg in messages:
        oracle_messages.append({
            "role": msg.get("role", "user"),
            "content": msg.get("content", "")
        })
    
    # Oracle Cloud LLM request format
    oracle_request = {
        "model": model,
        "messages": oracle_messages,
        "temperature": temperature,
        "max_tokens": max_tokens,
        "stream": False
    }
    
    return oracle_request

def convert_oracle_to_openai_format(oracle_response):
    """Convert Oracle Cloud LLM response to OpenAI-compatible format"""
    
    try:
        oracle_data = oracle_response.json()
        
        # Extract the response content
        content = ""
        if 'choices' in oracle_data and len(oracle_data['choices']) > 0:
            content = oracle_data['choices'][0].get('message', {}).get('content', '')
        
        # Create OpenAI-compatible response
        openai_response = {
            "id": oracle_data.get('id', 'oracle-llm-response'),
            "object": "chat.completion",
            "created": oracle_data.get('created', 1234567890),
            "model": oracle_data.get('model', ORACLE_MODEL_NAME),
            "choices": [
                {
                    "index": 0,
                    "message": {
                        "role": "assistant",
                        "content": content
                    },
                    "finish_reason": "stop"
                }
            ],
            "usage": oracle_data.get('usage', {
                "prompt_tokens": 0,
                "completion_tokens": 0,
                "total_tokens": 0
            })
        }
        
        return openai_response
        
    except Exception as e:
        return {
            "error": {
                "message": f"Failed to convert Oracle response: {str(e)}",
                "type": "server_error"
            }
        }

@app.route('/v1/chat/completions', methods=['POST'])
def chat_completions():
    """Handle chat completion requests from Cursor"""
    
    try:
        # Get OpenAI-compatible request from Cursor
        openai_request = request.json
        
        # Convert to Oracle format
        oracle_request = convert_openai_to_oracle_format(openai_request)
        
        # Make request to Oracle Cloud LLM
        headers = {
            'Content-Type': 'application/json',
            'Authorization': f'Bearer {ORACLE_API_KEY}'
        }
        
        oracle_response = requests.post(
            f"{ORACLE_API_ENDPOINT}/chat/completions",
            headers=headers,
            json=oracle_request,
            timeout=60
        )
        
        # Convert Oracle response back to OpenAI format
        openai_response = convert_oracle_to_openai_format(oracle_response)
        
        return jsonify(openai_response)
        
    except Exception as e:
        return jsonify({
            "error": {
                "message": f"Proxy error: {str(e)}",
                "type": "server_error"
            }
        }), 500

@app.route('/v1/models', methods=['GET'])
def list_models():
    """List available models (required by Cursor)"""
    
    models = [
        {
            "id": ORACLE_MODEL_NAME,
            "object": "model",
            "created": 1234567890,
            "owned_by": "oracle-cloud"
        }
    ]
    
    return jsonify({
        "object": "list",
        "data": models
    })

if __name__ == '__main__':
    port = int(os.getenv('PORT', 8000))
    app.run(host='0.0.0.0', port=port, debug=True)