import 'dart:convert';
import 'package:flutter/services.dart';
import '../domain/story/story_model.dart';

class StoryService {
  // Default paths (MSA)
  static const String _msaFictionPath = 'assets/stories_json/msa/msa_stories.json';
  static const String _msaNonfictionPath = 'assets/stories_json/msa/msa_stories_nonfiction.json';
  
  // Egyptian paths
  static const String _egyptianFictionPath = 'assets/stories_json/egyptian/egyptian_stories.json';
  static const String _egyptianNonfictionPath = 'assets/stories_json/egyptian/egyptian_stories_nonfiction.json';
  
  // Jordanian paths
  static const String _jordanianFictionPath = 'assets/stories_json/jordanian/jordanian_stories.json';
  static const String _jordanianNonfictionPath = 'assets/stories_json/jordanian/jordanian_stories_nonfiction.json';
  
  // Moroccan paths
  static const String _moroccanFictionPath = 'assets/stories_json/moroccan/moroccan_stories.json';
  static const String _moroccanNonfictionPath = 'assets/stories_json/moroccan/moroccan_stories_nonfiction.json';
  
  // Current dialect - default to MSA
  String _currentDialect = 'msa';
  
  // Singleton instance
  static final StoryService _instance = StoryService._internal();
  
  // Private constructor
  StoryService._internal();
  
  // Factory constructor to return the singleton instance
  factory StoryService() {
    return _instance;
  }
  
  // List to cache the stories for each dialect
  Map<String, List<Story>> _cachedStories = {};
  
  // Set the current dialect
  void setDialect(String dialect) {
    if (_currentDialect != dialect) {
      _currentDialect = dialect;
    }
  }
  
  // Get the current dialect
  String getDialect() {
    return _currentDialect;
  }
  
  // Get the file paths for the current dialect
  Map<String, String> _getFilePathsForDialect(String dialect) {
    switch (dialect) {
      case 'egyptian':
        return {
          'fiction': _egyptianFictionPath,
          'nonfiction': _egyptianNonfictionPath,
        };
      case 'jordanian':
        return {
          'fiction': _jordanianFictionPath,
          'nonfiction': _jordanianNonfictionPath,
        };
      case 'moroccan':
        return {
          'fiction': _moroccanFictionPath,
          'nonfiction': _moroccanNonfictionPath,
        };
      case 'msa':
      default:
        return {
          'fiction': _msaFictionPath,
          'nonfiction': _msaNonfictionPath,
        };
    }
  }
  
  // Load stories from the JSON files for the current dialect
  Future<List<Story>> getStories() async {
    // Return cached stories if available for current dialect
    if (_cachedStories.containsKey(_currentDialect)) {
      print('Using cached stories for dialect: $_currentDialect');
      return _cachedStories[_currentDialect]!;
    }
    
    try {
      // Get file paths for current dialect
      final paths = _getFilePathsForDialect(_currentDialect);
      print('Loading stories for dialect: $_currentDialect');
      print('Fiction path: ${paths['fiction']}');
      print('Non-fiction path: ${paths['nonfiction']}');
      
      // Load both JSON files
      final String fictionJsonString = await rootBundle.loadString(paths['fiction']!);
      final String nonfictionJsonString = await rootBundle.loadString(paths['nonfiction']!);
      
      final Map<String, dynamic> fictionJsonData = json.decode(fictionJsonString);
      final Map<String, dynamic> nonfictionJsonData = json.decode(nonfictionJsonString);
      
      // Parse the stories from both files
      final List<dynamic> fictionStoriesJson = fictionJsonData['stories'];
      final List<dynamic> nonfictionStoriesJson = nonfictionJsonData['stories'];
      
      print('Fiction stories count: ${fictionStoriesJson.length}');
      print('Non-fiction stories count: ${nonfictionStoriesJson.length}');
      
      // Combine the stories from both sources
      final List<Story> fictionStories = fictionStoriesJson.map((json) => Story.fromJson(json)).toList();
      final List<Story> nonfictionStories = nonfictionStoriesJson.map((json) => Story.fromJson(json)).toList();
      
      final allStories = [...fictionStories, ...nonfictionStories];
      _cachedStories[_currentDialect] = allStories;
      
      print('Total stories loaded for $_currentDialect: ${_cachedStories[_currentDialect]!.length}');
      
      // Validate that all story images exist
      validateStoryImages(allStories);
      
      return _cachedStories[_currentDialect]!;
    } catch (e) {
      print('Error loading stories for dialect $_currentDialect: $e');
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
  
  // Check if image assets exist for stories
  void validateStoryImages(List<Story> stories) {
    print('Validating image paths for ${stories.length} stories...');
    
    final Set<String> missingPaths = {};
    final Set<String> foundPaths = {};
    
    for (var story in stories) {
      // Print the ID and image path
      print('Story ID: ${story.id}');
      print('Image path: ${story.imagePath}');
      
      if (story.genre.toLowerCase() == 'nonfiction' || 
          story.genre.toLowerCase() == 'non-fiction') {
        // Check if the story ID matches any nonfiction image filenames
        print('Checking nonfiction image: ${story.id}.png');
      } else {
        // Check if the story ID matches any fiction image filenames
        print('Checking fiction image: ${story.id}.png');
      }
    }
    
    print('Validation complete. Found: ${foundPaths.length}, Missing: ${missingPaths.length}');
    if (missingPaths.isNotEmpty) {
      print('Missing image paths:');
      for (var path in missingPaths) {
        print(' - $path');
      }
    }
  }
  
  // Clear cache to force reload stories
  void clearCache() {
    _cachedStories.clear();
  }
  
  // Clear cache for a specific dialect
  void clearCacheForDialect(String dialect) {
    _cachedStories.remove(dialect);
  }
  
  // Get stories by main category (Fiction/Non-Fiction)
  Future<List<Story>> getStoriesByCategory(bool isFiction) async {
    final stories = await getStories();
    
    return stories.where((story) {
      // Check if the story's genre matches the requested Fiction/Non-Fiction category
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