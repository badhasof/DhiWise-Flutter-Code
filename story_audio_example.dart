import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

/// This is an example Flutter widget that demonstrates how to play the
/// audio files that were generated for the Arabic and English stories.
///
/// To use this code, you'll need to:
/// 1. Add the audioplayers package to your pubspec.yaml:
///    audioplayers: ^5.0.0
/// 2. Import the audioplayers package:
///    import 'package:audioplayers/audioplayers.dart';
/// 3. Make sure the audio files are accessible in your assets
///
/// NOTE: This code will show linter errors until you add the audioplayers package
/// to your pubspec.yaml and run 'flutter pub get'.

// The code below is commented out until you add the audioplayers package
// Uncomment after adding the package to your pubspec.yaml

/*
class StoryAudioPlayer extends StatefulWidget {
  const StoryAudioPlayer({Key? key}) : super(key: key);

  @override
  _StoryAudioPlayerState createState() => _StoryAudioPlayerState();
}

class _StoryAudioPlayerState extends State<StoryAudioPlayer> {
  // List to store the stories loaded from the JSON file
  List<dynamic> stories = [];
  
  // Audio player instance
  final AudioPlayer audioPlayer = AudioPlayer();
  
  // Track if audio is currently playing
  bool isPlaying = false;
  
  // Track which story and language is being played
  String? currentStoryId;
  String? currentLanguage;

  @override
  void initState() {
    super.initState();
    // Load the stories when the widget initializes
    _loadStories();
    
    // Listen for audio player state changes
    audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
        
        // Reset current playing indicators if the audio has finished
        if (state == PlayerState.completed) {
          currentStoryId = null;
          currentLanguage = null;
        }
      });
    });
  }

  @override
  void dispose() {
    // Clean up the audio player resources when the widget is disposed
    audioPlayer.dispose();
    super.dispose();
  }

  // Load the stories from the JSON file
  Future<void> _loadStories() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/msa_stories.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      setState(() {
        stories = jsonData['stories'];
      });
    } catch (e) {
      print('Error loading stories: $e');
    }
  }

  // Play audio for a specific story in the specified language
  Future<void> playAudio(String storyId, String language) async {
    try {
      // Find the story
      final story = stories.firstWhere((s) => s['id'] == storyId, orElse: () => null);
      
      if (story == null) {
        print('Story not found!');
        return;
      }
      
      // Get the audio path based on the language
      final String audioPath = language == 'en' ? story['audio_en'] : story['audio_ar'];
      
      if (audioPath == null || audioPath.isEmpty) {
        print('No audio available for this story in $language');
        return;
      }
      
      // Stop any currently playing audio
      await audioPlayer.stop();
      
      // Set the source and play
      await audioPlayer.play(AssetSource('assets/$audioPath'));
      
      // Update the current playing indicators
      setState(() {
        currentStoryId = storyId;
        currentLanguage = language;
      });
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  // Build a card for a single story
  Widget _buildStoryCard(Map<String, dynamic> story) {
    final String storyId = story['id'];
    final bool isEnglishPlaying = isPlaying && currentStoryId == storyId && currentLanguage == 'en';
    final bool isArabicPlaying = isPlaying && currentStoryId == storyId && currentLanguage == 'ar';
    
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Story title in English
            Text(
              story['title_en'],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            
            // Story title in Arabic
            Text(
              story['title_ar'],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 12),
            
            // Audio controls for English
            if (story['audio_en'] != null)
              ElevatedButton.icon(
                onPressed: () => playAudio(storyId, 'en'),
                icon: Icon(isEnglishPlaying ? Icons.pause : Icons.play_arrow),
                label: Text(isEnglishPlaying ? 'Playing English' : 'Play English'),
              ),
            
            const SizedBox(height: 8),
            
            // Audio controls for Arabic
            if (story['audio_ar'] != null)
              ElevatedButton.icon(
                onPressed: () => playAudio(storyId, 'ar'),
                icon: Icon(isArabicPlaying ? Icons.pause : Icons.play_arrow),
                label: Text(isArabicPlaying ? 'Playing Arabic' : 'Play Arabic'),
              ),
            
            const SizedBox(height: 16),
            
            // Show summary
            Text(
              'Summary: ${story['summary_en']}',
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stories with Audio'),
      ),
      body: stories.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: stories.length,
              itemBuilder: (context, index) {
                final story = stories[index];
                return _buildStoryCard(story);
              },
            ),
    );
  }
}
*/

/// Example code for using the generated audio files in a Flutter app
///
/// To use the audio player widget in your app, you would need to:
/// 1. Add the audioplayers package to pubspec.yaml:
///    dependencies:
///      audioplayers: ^5.0.0
///
/// 2. Add the generated audio files to your pubspec.yaml assets section:
///    flutter:
///      assets:
///        - assets/msa_stories.json
///        - assets/data/audio/
///
/// 3. Uncomment the StoryAudioPlayer class above
///
/// 4. Include this widget in your app's navigation:
///    void main() {
///      runApp(MaterialApp(
///        home: StoryAudioPlayer(),
///      ));
///    }

class StoryAudioPlaceholder extends StatelessWidget {
  const StoryAudioPlaceholder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stories with Audio - Placeholder'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Audio Player Example',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'To implement the audio player functionality:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('1. Add audioplayers package to pubspec.yaml'),
                  Text('2. Uncomment the StoryAudioPlayer code'),
                  Text('3. Configure asset paths in pubspec.yaml'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}