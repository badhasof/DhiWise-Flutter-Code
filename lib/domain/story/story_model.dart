import 'package:equatable/equatable.dart';
import '../../presentation/stories_overview_screen/stories_overview_screen.dart';
import 'dart:io';

/// Story model class representing a story from the JSON file
class Story extends Equatable {
  final String id;
  final String titleEn;
  final String titleAr;
  final String genre;
  final String subGenre;
  final String level;
  final String dialect;
  final String summaryEn;
  final String contentAr;
  final String contentEn;
  
  // Audio file paths
  final String? audioAr;
  final String? audioEn;
  
  // Male and female voice audio files
  final String? audioArMale;
  final String? audioArFemale;
  
  // Image path for the story
  final String imagePath;

  const Story({
    required this.id,
    required this.titleEn,
    required this.titleAr,
    required this.genre,
    this.subGenre = '',
    required this.level,
    required this.dialect,
    required this.summaryEn,
    required this.contentAr,
    required this.contentEn,
    this.audioAr,
    this.audioEn,
    this.audioArMale,
    this.audioArFemale,
    this.imagePath = 'assets/images/img_image_10.png', // Default image
  });

  // Factory constructor to create a Story from JSON
  factory Story.fromJson(Map<String, dynamic> json) {
    // Handle both fiction and nonfiction audio path formats
    String? audioArMale;
    String? audioArFemale;
    
    // Check for the dialect
    String dialect = json['dialect'] as String? ?? 'MSA Arabic';
    String dialectCode = 'msa';
    
    // Determine dialect code from dialect name
    if (dialect.contains('Egyptian')) {
      dialectCode = 'egyptian';
    } else if (dialect.contains('Jordanian')) {
      dialectCode = 'jordanian';
    } else if (dialect.contains('Moroccan')) {
      dialectCode = 'moroccan';
    }
    
    // Check for fiction-style audio paths (using snake_case)
    if (json['audio_ar_male'] != null) {
      audioArMale = json['audio_ar_male'] as String?;
    } 
    // Check for nonfiction-style audio paths (using camelCase)
    else if (json['audioArMale'] != null) {
      audioArMale = json['audioArMale'] as String?;
    }
    // Check for dialect-specific audio paths
    else if (json['audio_${dialectCode}_male'] != null) {
      audioArMale = json['audio_${dialectCode}_male'] as String?;
    }
    // Check for dialect-specific nonfiction audio paths
    else if (json['audio_${dialectCode}_nonfiction_male'] != null) {
      audioArMale = json['audio_${dialectCode}_nonfiction_male'] as String?;
    }
    
    // Same for female audio
    if (json['audio_ar_female'] != null) {
      audioArFemale = json['audio_ar_female'] as String?;
    } 
    else if (json['audioArFemale'] != null) {
      audioArFemale = json['audioArFemale'] as String?;
    }
    // Check for dialect-specific audio paths
    else if (json['audio_${dialectCode}_female'] != null) {
      audioArFemale = json['audio_${dialectCode}_female'] as String?;
    }
    // Check for dialect-specific nonfiction audio paths
    else if (json['audio_${dialectCode}_nonfiction_female'] != null) {
      audioArFemale = json['audio_${dialectCode}_nonfiction_female'] as String?;
    }
    
    // Handle story content field variations
    String contentAr = '';
    if (json['content_ar'] != null) {
      contentAr = json['content_ar'] as String;
    } else if (json['story_content'] != null) {
      contentAr = json['story_content'] as String;
    }
    
    final String id = json['id'] as String;
    final String genre = json['genre'] as String;
    
    // Determine image path based on whether it's fiction or nonfiction
    String imagePath;
    if (genre.toLowerCase() == 'nonfiction' || genre.toLowerCase() == 'non-fiction') {
      imagePath = 'assets/nonfiction_images/$id.png';
    } else {
      imagePath = 'assets/story_images/$id.png';
    }
    
    // Create the story object
    return Story(
      id: id,
      titleEn: json['title_en'] as String,
      titleAr: json['title_ar'] as String,
      genre: genre,
      subGenre: json['sub_genre'] as String? ?? '',
      level: json['level'] as String,
      dialect: dialect,
      summaryEn: json['summary_en'] as String,
      contentAr: contentAr,
      contentEn: json['content_en'] as String,
      audioAr: json['audio_ar'] as String?,
      audioEn: json['audio_en'] as String?,
      audioArMale: audioArMale,
      audioArFemale: audioArFemale,
      imagePath: imagePath,
    );
  }

  // Convert Story to StoryData for the StoriesOverviewScreen
  StoryData toStoryData() {
    return StoryData(
      title: titleEn,
      arabicTitle: titleAr,
      description: summaryEn,
      imagePath: imagePath,
      level: level,
      duration: _getDurationFromLevel(level),
    );
  }

  // Helper method to get estimated duration based on level
  String _getDurationFromLevel(String level) {
    switch (level) {
      case 'Beginner':
        return '10 min';
      case 'Intermediate':
        return '15 min';
      case 'Advanced':
        return '20 min';
      default:
        return '15 min';
    }
  }

  @override
  List<Object?> get props => [
        id,
        titleEn,
        titleAr,
        genre,
        subGenre,
        level,
        dialect,
        summaryEn,
        contentAr,
        contentEn,
        audioAr,
        audioEn,
        audioArMale,
        audioArFemale,
        imagePath,
      ];
      
  // Debug method to print audio paths
  void printAudioPaths() {
    // Method kept but implementation removed
  }
  
  // Helper method to verify if the image path exists
  bool imageExists() {
    final file = File(imagePath);
    final exists = file.existsSync();
    return exists;
  }
} 