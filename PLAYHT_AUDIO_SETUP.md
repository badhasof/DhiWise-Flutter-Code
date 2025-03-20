# PlayHT Text-to-Speech Integration Guide

This guide explains how to use the PlayHT Text-to-Speech API to generate audio files for Arabic and English stories, and how to integrate them into your Flutter application.

## Overview

The solution includes:

1. A Node.js script (`generate_audio.js`) to generate audio files from text using PlayHT's API
2. A Flutter example (`story_audio_example.dart`) that demonstrates how to play these audio files in your app

## Prerequisites

- [Node.js](https://nodejs.org/) installed on your system
- A [PlayHT](https://play.ht/) account with API credentials (User ID and API Key)
- The [Flutter SDK](https://flutter.dev/docs/get-started/install) installed for the app integration

## Step 1: Generate Audio Files

### Setup

1. Sign up for a PlayHT account at [play.ht](https://play.ht/)
2. Get your API credentials from the PlayHT dashboard
3. Update the `YOUR_USER_ID` and `YOUR_API_KEY` placeholders in `generate_audio.js` with your actual credentials

### Install Dependencies

```bash
# Navigate to your project directory
npm install --save playht
```

### Run the Script

```bash
node generate_audio.js
```

This script will:
- Read the story data from `assets/msa_stories.json`
- Process the first two stories (you can modify this to process more or all stories)
- Generate audio files for both English and Arabic text
- Save the audio files to `assets/data/audio/`
- Update the JSON file with paths to the audio files

## Step 2: Integrate Audio in Your Flutter App

### Update pubspec.yaml

Add the audioplayers package to your dependencies:

```yaml
dependencies:
  flutter:
    sdk: flutter
  audioplayers: ^5.0.0  # Check for latest version
```

Add the audio files to your assets:

```yaml
flutter:
  assets:
    - assets/msa_stories.json
    - assets/data/audio/
```

### Run Flutter Pub Get

```bash
flutter pub get
```

### Use the Audio Player Widget

1. Uncomment the `StoryAudioPlayer` class in `story_audio_example.dart`
2. Add the widget to your app's navigation

```dart
import 'story_audio_example.dart';

// Then in your app navigation
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => StoryAudioPlayer()),
);
```

## Voice Customization

You can customize the voices used for English and Arabic audio by modifying the `voiceOptions` in the `generateAudio` function:

### Arabic Voice Options

PlayHT offers several Arabic voices with different dialects. Here are some options:

- `ar-XA-Standard-A` (Alya) - Female, Modern Standard Arabic
- `ar-XA-Standard-B` (Idris) - Male, Modern Standard Arabic
- `ar-XA-Standard-C` (Jalal) - Male, Modern Standard Arabic
- `ar-XA-Standard-D` (Salma) - Female, Modern Standard Arabic
- `ar-EG-SalmaNeural` - Female, Egyptian Arabic
- `ar-SA-ZariyahNeural` - Female, Saudi Arabic

### English Voice Options

PlayHT offers many English voices. You can also use their AI voice cloning feature for more realistic voices.

## PlayHT API Pricing and Limits

- The free tier includes around 12,500 characters per month
- For production use, you'll need a paid plan
- Check the [PlayHT pricing page](https://play.ht/pricing/) for current pricing

## Troubleshooting

### Audio Generation Issues

- Ensure your PlayHT API credentials are correct
- Check that you haven't exceeded your API limits
- Look at the console output for error messages

### Flutter Integration Issues

- Make sure you've added the audioplayers package to pubspec.yaml
- Ensure the audio file paths in the JSON match the actual file locations
- Check that the audio files are properly included in your Flutter assets

## Next Steps

- Process all stories instead of just the first two
- Add playback controls (speed, pause, seek)
- Implement caching for offline playback
- Add visual indicators for the currently playing segment

## Resources

- [PlayHT API Documentation](https://docs.play.ht/)
- [audioplayers Package](https://pub.dev/packages/audioplayers)
- [Flutter Asset Management](https://flutter.dev/docs/development/ui/assets-and-images)