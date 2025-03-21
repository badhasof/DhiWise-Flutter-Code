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
  
  // Clear cache to force reload stories (useful for testing)
  void clearCache() {
    _stories = null;
  }
  
  // Get stories by main category (Fiction/Non-Fiction)
  Future<List<Story>> getStoriesByCategory(bool isFiction) async {
    final stories = await getStories();
    
    return stories.where((story) {
      // Check if the story's genre matches the requested Fiction/Non-Fiction category
      // Fiction is when genre field contains "Fiction", Non-Fiction is when it doesn't
      final isStoryFiction = story.genre == "Fiction";
      return isStoryFiction == isFiction;
    }).toList();
  }
  
  // Get stories filtered by fiction/non-fiction and optionally by specific genre or sub-genre
  Future<List<Story>> getFilteredStories({
    required bool isFiction, 
    String? genre, 
    String? subGenre
  }) async {
    final stories = await getStoriesByCategory(isFiction);
    
    // If no specific genre or sub-genre is requested, return all stories in the category
    if (genre == null && subGenre == null) {
      return stories;
    }
    
    // Filter by genre if specified
    if (genre != null && genre != "All Stories") {
      // If "All Stories" is selected, don't filter by genre
      return stories.where((story) => story.subGenre == genre).toList();
    }
    
    // Further filter by sub-genre if specified
    if (subGenre != null && subGenre != "All Stories") {
      return stories.where((story) => story.subGenre == subGenre).toList();
    }
    
    return stories;
  }
  
  // Get stories by specific genre
  Future<List<Story>> getStoriesByGenre(String genre) async {
    final stories = await getStories();
    return stories.where((story) => story.genre == genre).toList();
  }
  
  // Get stories by sub-genre
  Future<List<Story>> getStoriesBySubGenre(String subGenre) async {
    final stories = await getStories();
    return stories.where((story) => story.subGenre == subGenre).toList();
  }
  
  // Get all available sub-genres for a specific main genre (Fiction/Non-Fiction)
  Future<List<String>> getAvailableSubGenres(bool isFiction) async {
    final stories = await getStoriesByCategory(isFiction);
    
    // Extract unique sub-genres
    final subGenres = stories.map((story) => story.subGenre).toSet().toList();
    
    // Sort them alphabetically
    subGenres.sort();
    
    // Add "All Stories" as the first option
    return ["All Stories", ...subGenres];
  }
  
  // Get stories by level
  Future<List<Story>> getStoriesByLevel(String level) async {
    final stories = await getStories();
    return stories.where((story) => story.level == level).toList();
  }
} 