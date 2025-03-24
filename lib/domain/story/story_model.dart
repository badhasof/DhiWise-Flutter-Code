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
    
    // Check for fiction-style audio paths (using snake_case)
    if (json['audio_ar_male'] != null) {
      audioArMale = json['audio_ar_male'] as String?;
    } 
    // Check for nonfiction-style audio paths (using camelCase)
    else if (json['audioArMale'] != null) {
      audioArMale = json['audioArMale'] as String?;
    }
    
    // Same for female audio
    if (json['audio_ar_female'] != null) {
      audioArFemale = json['audio_ar_female'] as String?;
    } 
    else if (json['audioArFemale'] != null) {
      audioArFemale = json['audioArFemale'] as String?;
    }
    
    return Story(
      id: json['id'] as String,
      titleEn: json['title_en'] as String,
      titleAr: json['title_ar'] as String,
      genre: json['genre'] as String,
      subGenre: json['sub_genre'] as String? ?? '',
      level: json['level'] as String,
      dialect: json['dialect'] as String,
      summaryEn: json['summary_en'] as String,
      contentAr: json['content_ar'] as String,
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
} 