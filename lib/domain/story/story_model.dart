import 'package:equatable/equatable.dart';
import '../../presentation/stories_overview_screen/stories_overview_screen.dart';

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
  
  // Default image path for stories - can be customized later
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
      print('Detected Egyptian dialect story: ${json['id']}');
    } else if (dialect.contains('Jordanian')) {
      dialectCode = 'jordanian';
      print('Detected Jordanian dialect story: ${json['id']}');
    } else if (dialect.contains('Moroccan')) {
      dialectCode = 'moroccan';
      print('Detected Moroccan dialect story: ${json['id']}');
    }
    
    // Check for fiction-style audio paths (using snake_case)
    if (json['audio_ar_male'] != null) {
      audioArMale = json['audio_ar_male'] as String?;
      print('Using audio_ar_male: $audioArMale');
    } 
    // Check for nonfiction-style audio paths (using camelCase)
    else if (json['audioArMale'] != null) {
      audioArMale = json['audioArMale'] as String?;
      print('Using audioArMale: $audioArMale');
    }
    // Check for dialect-specific audio paths
    else if (json['audio_${dialectCode}_male'] != null) {
      audioArMale = json['audio_${dialectCode}_male'] as String?;
      print('Using audio_${dialectCode}_male: $audioArMale');
    }
    // Check for dialect-specific nonfiction audio paths
    else if (json['audio_${dialectCode}_nonfiction_male'] != null) {
      audioArMale = json['audio_${dialectCode}_nonfiction_male'] as String?;
      print('Using audio_${dialectCode}_nonfiction_male: $audioArMale');
    }
    
    // Same for female audio
    if (json['audio_ar_female'] != null) {
      audioArFemale = json['audio_ar_female'] as String?;
      print('Using audio_ar_female: $audioArFemale');
    } 
    else if (json['audioArFemale'] != null) {
      audioArFemale = json['audioArFemale'] as String?;
      print('Using audioArFemale: $audioArFemale');
    }
    // Check for dialect-specific audio paths
    else if (json['audio_${dialectCode}_female'] != null) {
      audioArFemale = json['audio_${dialectCode}_female'] as String?;
      print('Using audio_${dialectCode}_female: $audioArFemale');
    }
    // Check for dialect-specific nonfiction audio paths
    else if (json['audio_${dialectCode}_nonfiction_female'] != null) {
      audioArFemale = json['audio_${dialectCode}_nonfiction_female'] as String?;
      print('Using audio_${dialectCode}_nonfiction_female: $audioArFemale');
    }
    
    // Handle story content field variations
    String contentAr = '';
    if (json['content_ar'] != null) {
      contentAr = json['content_ar'] as String;
    } else if (json['story_content'] != null) {
      contentAr = json['story_content'] as String;
    }
    
    // Create the story object
    return Story(
      id: json['id'] as String,
      titleEn: json['title_en'] as String,
      titleAr: json['title_ar'] as String,
      genre: json['genre'] as String,
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
    print('Story ID: $id, Dialect: $dialect');
    print('audioAr: $audioAr');
    print('audioEn: $audioEn');
    print('audioArMale: $audioArMale');
    print('audioArFemale: $audioArFemale');
  }
} 