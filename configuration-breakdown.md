# Custom Model Configuration Breakdown

## Basic Model Configuration
```json
{
  "id": "oracle-llm-fast",           // Unique identifier for the model
  "name": "Oracle LLM (Fast)",       // Display name in Cursor UI
  "description": "Fast response...", // Optional description
  "contextLength": 4096,             // Maximum context window size
}
```

## API Configuration
```json
"api": {
  "type": "openai",                  // API type (usually "openai" for compatibility)
  "baseURL": "https://...",          // Your Oracle Cloud LLM endpoint
  "apiKey": "your-api-key",          // Authentication token
  "headers": {                       // Optional additional headers
    "Custom-Header": "value"
  }
}
```

## Model Parameters
```json
"parameters": {
  "temperature": 0.3,                // Creativity level (0.0-1.0)
  "maxTokens": 2048,                 // Maximum response length
  "topP": 0.8,                       // Nucleus sampling parameter
  "frequencyPenalty": 0.0,           // Reduce repetition
  "presencePenalty": 0.0             // Encourage new topics
}
```

## Global Settings
```json
{
  "cursor.defaultModel": "oracle-llm-accurate",  // Default selected model
  "cursor.enableCustomModels": true              // Enable custom models feature
}
```

## Parameter Explanations

### Temperature (0.0 - 1.0)
- **0.0**: Very deterministic, consistent responses
- **0.3**: Balanced, good for coding
- **0.7**: More creative, varied responses
- **1.0**: Maximum creativity, unpredictable

### Max Tokens
- **2048**: Short responses, fast
- **4096**: Standard length
- **8192**: Long responses, more context

### Context Length
- **4096**: Good for most tasks
- **8192**: Better for large codebases
- **16384**: Maximum context (if supported)