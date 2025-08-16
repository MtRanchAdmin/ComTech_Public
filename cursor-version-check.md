# Check Your Cursor Version and Configuration Method

## How to Check Cursor Version

1. **Open Cursor**
2. **Go to Help → About** (or `Ctrl+Shift+P` → "About")
3. **Note the version number**

## Version-Specific Configuration

### Cursor 0.x (Early Versions)
- Uses `settings.json` with `cursor.customModels`
- May require restart after changes

### Cursor 1.x (Current Versions)
- Uses `settings.json` with `cursor.customModels`
- May have UI settings available
- Supports workspace-specific settings

### Cursor 2.x (Latest Versions)
- May use different configuration keys
- Could have built-in custom model support
- Might use `cursor.ai.customModels` instead

## Finding the Right Configuration Key

Try searching in your settings for these terms:
- `customModels`
- `custom models`
- `AI models`
- `model configuration`
- `oracle`
- `llm`

## Testing Configuration

After adding configuration:

1. **Restart Cursor completely**
2. **Open AI chat** (`Ctrl+K` or `Cmd+K`)
3. **Look for model selector** in the chat interface
4. **Check if your Oracle LLM appears** in the model list

## Common Issues

### Issue: Configuration not recognized
- **Solution**: Try different configuration keys
- **Solution**: Check if Cursor supports custom models in your version
- **Solution**: Look for alternative configuration methods

### Issue: Model appears but doesn't work
- **Solution**: Verify API endpoint is accessible
- **Solution**: Check API key format
- **Solution**: Test API endpoint directly with curl/Postman

### Issue: No model selector visible
- **Solution**: Check if custom models are enabled
- **Solution**: Look for different UI locations
- **Solution**: Check Cursor documentation for your version