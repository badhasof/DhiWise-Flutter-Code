# Word Timestamp Implementation for Audio Text Tracking

This documentation explains how to use the OpenAI Whisper API to generate word-level timestamps for story audio files and implement precise text tracking in the app.

## Overview

The implementation consists of the following components:

1. A script to generate word timestamps using OpenAI's Whisper API
2. A model class to represent word timestamps
3. A service to load and manage word timestamps
4. Updates to the StoryScreen to use the timestamps for precise word highlighting

## Generating Word Timestamps

### Using OpenAI Whisper API

The `scripts/generate_word_timestamps.dart` script sends audio files to OpenAI's Whisper API to get word-level timestamps. To use it:

1. Replace `your_openai_api_key_here` with your actual OpenAI API key
2. Run the script using Dart:
   ```bash
   dart scripts/generate_word_timestamps.dart
   ```

The script will process the specified audio files and save the timestamps as JSON files in the `assets/data/timestamps` directory.

### Testing with Sample Data

For development and testing without using the API, you can use the `scripts/test_timestamps.dart` script to generate sample timestamp data:

```bash
dart scripts/test_timestamps.dart
```

This will create sample JSON files with estimated word timestamps based on the audio file duration.

## Generated Timestamp Format

The timestamp JSON files have the following structure:

```json
{
  "text": "Full transcribed text",
  "words": [
    {
      "word": "first",
      "start": 0.0,
      "end": 0.4
    },
    {
      "word": "word",
      "start": 0.4,
      "end": 0.8
    },
    ...
  ],
  "language": "ar"
}
```

## Integration in the App

The implementation is integrated into the app as follows:

1. The `WordTimestamp` and `WordTimestampCollection` classes in `lib/domain/story/word_timestamp.dart` represent the timestamp data
2. The `TimestampService` in `lib/services/timestamp_service.dart` loads and manages timestamp data
3. The `StoryScreen` has been updated to use the timestamp service for precise word highlighting

## How It Works

1. When the user plays an audio file, the app loads the corresponding timestamp file
2. As the audio plays, the app uses the current playback position to find the word that should be highlighted
3. The app highlights the word in the text

## Extending for More Stories

To extend this implementation for more stories:

1. Add the audio files to `assets/data/audio/`
2. Run the timestamp generation script for those audio files
3. Update the `msa_stories.json` file with the correct audio paths

## Adding More Languages

The current implementation supports both Arabic and English. When adding new languages:

1. Add the audio files for the new language
2. Generate timestamps for those audio files
3. Update the Story model and UI to support the new language 