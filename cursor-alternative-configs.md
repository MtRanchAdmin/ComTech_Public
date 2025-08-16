# Alternative Cursor Configuration Methods

## Method 1: Using Cursor's Command Palette

1. **Open Command Palette**: `Ctrl+Shift+P` (Windows/Linux) or `Cmd+Shift+P` (macOS)
2. **Search for**: "Preferences: Open Settings (JSON)"
3. **Add the configuration** directly to the JSON file

## Method 2: Using Cursor's Settings UI

1. **Open Settings**: `Ctrl+,` or `Cmd+,`
2. **Search for**: "custom models" or "AI models"
3. **Look for sections like**:
   - "Cursor: Custom Models"
   - "AI: Custom Models" 
   - "Model Configuration"

## Method 3: Environment Variables (if supported)

Some versions of Cursor support environment variables:

```bash
# Set environment variables
export CURSOR_CUSTOM_MODELS='[{"id":"oracle-llm","name":"Oracle LLM","api":{"type":"openai","baseURL":"https://your-endpoint.com/v1","apiKey":"your-key"}}]'
export CURSOR_DEFAULT_MODEL="oracle-llm"
```

## Method 4: Workspace Settings

Create a `.vscode/settings.json` file in your project:

```json
{
    "cursor.customModels": [
        {
            "id": "oracle-llm",
            "name": "Oracle Cloud LLM",
            "api": {
                "type": "openai",
                "baseURL": "https://your-oracle-endpoint.com/v1",
                "apiKey": "your-api-key"
            }
        }
    ],
    "cursor.defaultModel": "oracle-llm"
}
```

## Method 5: Cursor Configuration File

Some versions use a dedicated config file:

**Windows**: `%APPDATA%\Cursor\cursor.json`
**macOS**: `~/Library/Application Support/Cursor/cursor.json`
**Linux**: `~/.config/Cursor/cursor.json`