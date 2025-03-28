const fs = require('fs');
const path = require('path');
const PlayHT = require('playht');
const util = require('util');

// Convert callbacks to promises
const writeFileAsync = util.promisify(fs.writeFile);
const readFileAsync = util.promisify(fs.readFile);

/**
 * This script generates audio files for Arabic text content from story JSON files
 * using the PlayHT API. It processes stories and adds paths to the audio files
 * in the JSON data structure.
 * 
 * Usage:
 * - node generate_audio.js             # Processes MSA fiction stories (default)
 * - node generate_audio.js nonfiction  # Processes MSA non-fiction stories
 * - node generate_audio.js egyptian    # Processes Egyptian dialect stories
 * 
 * Prerequisites:
 * 1. PlayHT API credentials (userId and apiKey)
 * 2. Installed dependencies: playht
 */

// Initialize PlayHT with your credentials
// You need to replace these with your actual credentials from your PlayHT account
PlayHT.init({
  userId: 'o89zFo5DFBdxa4w7qyegbwV1ZPF3', // Replace with your actual user ID
  apiKey: 'ak-4c0056e0f44d47d88244294e68dded22',  // Replace with your actual API key
});

// Determine the story type and dialect from command line arguments
const isEgyptian = process.argv[2] === 'egyptian';
const storyType = process.argv[2] === 'nonfiction' ? 'nonfiction' : 'fiction';

// Path to the stories JSON file
let storiesFilePath;
if (isEgyptian) {
  storiesFilePath = path.join(__dirname, 'assets', 'stories_json/egyptian/egyptian_stories.json');
} else {
  storiesFilePath = path.join(
    __dirname, 
    'assets', 
    storyType === 'nonfiction' ? 'stories_json/msa/msa_stories_nonfiction.json' : 'stories_json/msa/msa_stories.json'
  );
}

// Directory to save audio files
let audioDir;
if (isEgyptian) {
  audioDir = path.join(__dirname, 'assets', 'data', 'audio', 'egyptian');
} else {
  audioDir = path.join(
    __dirname, 
    'assets', 
    'data', 
    'audio', 
    storyType === 'nonfiction' ? 'nonfiction' : ''
  );
}

// Ensure audio directory exists
if (!fs.existsSync(audioDir)) {
  fs.mkdirSync(audioDir, { recursive: true });
}

console.log(`Processing ${isEgyptian ? 'Egyptian' : storyType} stories from: ${storiesFilePath}`);
console.log(`Saving audio files to: ${audioDir}`);

// Define voice IDs for male and female voices 
// Using the same MSA voices for all dialects
const VOICE_IDS = {
  male: 's3://voice-cloning-zero-shot/c8731d9b-c16c-4dda-b320-7db983880687/original/manifest.json',
  female: 's3://voice-cloning-zero-shot/b6f988dc-c137-4753-ad11-aa7cb0215e17/original/manifest.json'
};

// Add a sleep function to handle API rate limits if necessary
const sleep = (ms) => new Promise(resolve => setTimeout(resolve, ms));

/**
 * Validates Arabic content to ensure it's not empty or too short
 * 
 * @param {string} text - The text to validate
 * @returns {boolean} - Whether the text is valid for audio generation
 */
function validateArabicContent(text) {
  if (!text || typeof text !== 'string') {
    return false;
  }
  
  // Remove spaces, newlines, and punctuation to check actual content length
  const cleanedText = text.replace(/[\s\n\r.,،؛!؟:؟()-]/g, '');
  
  // If there are less than 10 meaningful characters, consider it invalid
  if (cleanedText.length < 10) {
    return false;
  }
  
  return true;
}

/**
 * Generates audio from text using PlayHT API with retry logic
 * 
 * @param {string} text - The text to convert to speech
 * @param {string} outputFileName - Name of the output audio file
 * @param {string} voiceType - The type of voice to use ('male' or 'female')
 * @returns {Promise<string>} - Path to the generated audio file
 */
async function generateAudio(text, outputFileName, voiceType = 'male') {
  const maxRetries = 3;
  let retries = 0;
  
  while (retries < maxRetries) {
    try {
      // Using Play3.0-mini with Arabic language setting
      const voiceOptions = {
        voiceId: VOICE_IDS[voiceType],
        voiceEngine: 'Play3.0-mini', // Using the multilingual voice engine
        language: 'arabic',
        outputFormat: 'mp3',
      };

      console.log(`Generating ${voiceType} audio for Arabic text: "${text.substring(0, 30)}..."`);
      
      // Generate audio and stream to file
      const stream = await PlayHT.stream(text, voiceOptions);
      const outputPath = path.join(audioDir, outputFileName);
      
      // Create a write stream and pipe the PlayHT stream to it
      const fileStream = fs.createWriteStream(outputPath);
      stream.pipe(fileStream);
      
      // Wait for the file to finish writing
      return new Promise((resolve, reject) => {
        fileStream.on('finish', () => {
          console.log(`Audio saved to ${outputPath}`);
          resolve(outputPath);
        });
        fileStream.on('error', (err) => {
          console.error(`Error saving audio: ${err.message || err}`);
          reject(err);
        });
      });
    } catch (error) {
      retries++;
      console.error(`Error generating audio (attempt ${retries}/${maxRetries}): ${error.message || error}`);
      
      if (retries >= maxRetries) {
        console.error('Maximum retry attempts reached. Skipping this audio generation.');
        throw error;
      }
      
      // Shorter wait before retry if needed
      const waitTime = 1000;
      console.log(`Waiting ${waitTime/1000} second before retry...`);
      await sleep(waitTime);
    }
  }
}

/**
 * Process stories from the JSON file, generate audio for stories that don't have audio files
 * and update the JSON with paths to the audio files
 */
async function processStories() {
  try {
    // Read the stories JSON file
    const data = await readFileAsync(storiesFilePath, 'utf8');
    const storiesData = JSON.parse(data);
    
    // Store failed generations to report at the end
    const failedGenerations = [];
    
    // Handle different JSON structures for fiction vs non-fiction vs Egyptian
    const stories = storiesData.stories || storiesData;
    const totalStories = stories.length;
    
    console.log(`Found ${totalStories} stories to process`);
    
    // Process all stories and check which ones need audio
    for (let i = 0; i < totalStories; i++) {
      const story = stories[i];
      
      // Handle different field names between MSA and Egyptian JSON structures
      let contentAr, titleAr, titleEn, displayTitle;
      
      if (isEgyptian) {
        contentAr = story.story_content;
        titleAr = story.story_title || story.title_ar || '';
      } else {
        contentAr = story.content_ar || story.contentAr;
        titleAr = story.title_ar || story.titleAr || '';
      }
      
      titleEn = story.title_en || story.titleEn || '';
      displayTitle = titleAr || titleEn || `Story ${i+1}`;
      
      // Set up the audio file field names based on dialect
      const maleAudioField = isEgyptian ? 'audio_egyptian_male' : (storyType === 'nonfiction' ? 'audioArMale' : 'audio_ar_male');
      const femaleAudioField = isEgyptian ? 'audio_egyptian_female' : (storyType === 'nonfiction' ? 'audioArFemale' : 'audio_ar_female');
      
      // Skip if story has no valid Arabic content or if both male and female audio files already exist
      if (!validateArabicContent(contentAr) || (story[maleAudioField] && story[femaleAudioField])) {
        console.log(`Skipping story ${i + 1}/${totalStories}: ${displayTitle} (already has audio or invalid content)`);
        continue;
      }
      
      console.log(`Processing story ${i + 1}/${totalStories}: ${displayTitle}`);
      
      try {
        const filePrefix = storyType === 'nonfiction' && !isEgyptian ? 'nonfiction_' : '';
        const storyId = story.id || `story${i+1}`;
        
        // Set appropriate relative path for audio files
        let relativePath;
        if (isEgyptian) {
          relativePath = 'data/audio/egyptian/';
        } else {
          relativePath = storyType === 'nonfiction' ? 'data/audio/nonfiction/' : 'data/audio/';
        }
        
        // Generate audio with male voice if needed
        if (!story[maleAudioField]) {
          const suffix = isEgyptian ? '_egyptian_male.mp3' : '_ar_male.mp3';
          const maleAudioFileName = `${filePrefix}${storyId}${suffix}`;
          
          await generateAudio(contentAr, maleAudioFileName, 'male');
          
          // Update field in JSON
          story[maleAudioField] = `${relativePath}${maleAudioFileName}`;
          
          console.log(`Generated male audio for story: ${displayTitle}`);
        }
        
        // Generate audio with female voice if needed
        if (!story[femaleAudioField]) {
          const suffix = isEgyptian ? '_egyptian_female.mp3' : '_ar_female.mp3';
          const femaleAudioFileName = `${filePrefix}${storyId}${suffix}`;
          
          await generateAudio(contentAr, femaleAudioFileName, 'female');
          
          // Update field in JSON
          story[femaleAudioField] = `${relativePath}${femaleAudioFileName}`;
          
          console.log(`Generated female audio for story: ${displayTitle}`);
        }
        
        // Save updated JSON back to the file after each story is processed
        await writeFileAsync(storiesFilePath, JSON.stringify(storiesData, null, 2), 'utf8');
        console.log(`Updated JSON file with audio paths for story: ${displayTitle}`);
        
      } catch (error) {
        console.error(`Failed to process story: ${displayTitle}`, error.message || error);
        failedGenerations.push({
          title: displayTitle,
          error: error.message || 'Unknown error'
        });
      }
    }
    
    // Final save of the JSON file
    await writeFileAsync(storiesFilePath, JSON.stringify(storiesData, null, 2), 'utf8');
    
    const dialectText = isEgyptian ? 'Egyptian' : storyType;
    console.log(`All ${dialectText} stories processed. Stories JSON updated with audio file paths.`);
    
    // Report any failed generations
    if (failedGenerations.length > 0) {
      console.error('\nThe following stories failed to generate audio:');
      failedGenerations.forEach((failure, index) => {
        console.error(`${index + 1}. ${failure.title}: ${failure.error}`);
      });
    }
  } catch (error) {
    console.error('Error processing stories:', error.message || error);
    console.error('Error details:', error);
  }
}

// Run the main function
processStories()
  .then(() => {
    const dialectText = isEgyptian ? 'Egyptian' : storyType;
    console.log(`${dialectText} audio generation complete`);
  })
  .catch(err => console.error('Fatal error:', err.message || err));

/**
 * Note: To run this script, you need to:
 * 1. Sign up for a PlayHT account and get your API credentials
 * 2. Run the script with:
 *    - node generate_audio.js              # For fiction stories (default)
 *    - node generate_audio.js nonfiction   # For non-fiction stories
 *    - node generate_audio.js egyptian     # For Egyptian dialect stories
 * 
 * The script will:
 * - Check all stories in the selected JSON file and identify which ones need audio generation
 * - Generate Arabic audio files (male and female voices) only for stories that don't have them
 * - Save the files to the appropriate audio directory based on story type
 * - Update the JSON file with paths to these audio files
 * - Skip stories that already have both male and female audio or don't have valid Arabic content
 */