import 'dart:convert';
import 'package:flutter/services.dart';
import '../domain/story/story_model.dart';

class StoryService {
  static const String _jsonPath = 'assets/msa_stories.json';
  
  // Singleton instance
  static final StoryService _instance = StoryService._internal();
  
  // Private constructor
  StoryService._internal();
  
  // Factory constructor to return the singleton instance
  factory StoryService() {
    return _instance;
  }
  
  // List to cache the stories
  List<Story>? _stories;
  
  // Load stories from the JSON file
  Future<List<Story>> getStories() async {
    // Return cached stories if available
    if (_stories != null) {
      return _stories!;
    }
    
    try {
      // Load the JSON file
      final String jsonString = await rootBundle.loadString(_jsonPath);
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      // Parse the stories
      final List<dynamic> storiesJson = jsonData['stories'];
      _stories = storiesJson.map((json) => Story.fromJson(json)).toList();
      
      return _stories!;
    } catch (e) {
      print('Error loading stories: $e');
      return [];
    }
  }
  
  // Get a story by ID
  Future<Story?> getStoryById(String id) async {
    final stories = await getStories();
    try {
      return stories.firstWhere((story) => story.id == id);
    } catch (e) {
      return null;
    }
  }
  
  // Get stories by genre
  Future<List<Story>> getStoriesByGenre(String genre) async {
    final stories = await getStories();
    return stories.where((story) => story.genre == genre).toList();
  }
  
  // Get stories by level
  Future<List<Story>> getStoriesByLevel(String level) async {
    final stories = await getStories();
    return stories.where((story) => story.level == level).toList();
  }
} 