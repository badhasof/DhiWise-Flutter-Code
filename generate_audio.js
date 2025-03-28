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
 * - node generate_audio.js             # Processes fiction stories (default)
 * - node generate_audio.js nonfiction  # Processes non-fiction stories
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

// Determine the story type from command line arguments
const storyType = process.argv[2] === 'nonfiction' ? 'nonfiction' : 'fiction';

// Path to the stories JSON file
const storiesFilePath = path.join(
  __dirname, 
  'assets', 
  storyType === 'nonfiction' ? 'stories_json/msa/msa_stories_nonfiction.json' : 'stories_json/msa/msa_stories.json'
);

// Directory to save audio files
const audioDir = path.join(
  __dirname, 
  'assets', 
  'data', 
  'audio', 
  storyType === 'nonfiction' ? 'nonfiction' : ''
);

console.log(`Processing ${storyType} stories from: ${storiesFilePath}`);
console.log(`Saving audio files to: ${audioDir}`);

// Define voice IDs for male and female voices
const VOICE_IDS = {
  male: 's3://voice-cloning-zero-shot/c8731d9b-c16c-4dda-b320-7db983880687/original/manifest.json',
  female: 's3://voice-cloning-zero-shot/b6f988dc-c137-4753-ad11-aa7cb0215e17/original/manifest.json'
};

// Add a sleep function to handle API rate limits
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
      // Based on the list of voices, we're using the Arabic language parameter
      const voiceOptions = {
        voiceId: VOICE_IDS[voiceType],
        voiceEngine: 'Play3.0-mini', // Using the new multilingual voice engine
        language: 'arabic', // Using full language name instead of language code
        outputFormat: 'mp3',
      };

      console.log(`Generating ${voiceType} audio for Arabic text: "${text.substring(0, 30)}..."`);
      console.log('Voice options:', JSON.stringify(voiceOptions, null, 2));
      
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
      
      // Wait before retry - exponential backoff
      const waitTime = 5000 * Math.pow(2, retries - 1); // 5s, 10s, 20s
      console.log(`Waiting ${waitTime/1000} seconds before retry...`);
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
    
    // Handle different JSON structures for fiction vs non-fiction
    const stories = storiesData.stories || storiesData;
    const totalStories = stories.length;
    
    console.log(`Found ${totalStories} stories to process`);
    
    // Process all stories and check which ones need audio
    for (let i = 0; i < totalStories; i++) {
      const story = stories[i];
      const contentAr = story.content_ar || story.contentAr;
      const titleAr = story.title_ar || story.titleAr || '';
      const titleEn = story.title_en || story.titleEn || '';
      const displayTitle = titleAr || titleEn || `Story ${i+1}`;
      
      // Skip if story has no valid Arabic content or if both male and female audio files already exist
      if (!validateArabicContent(contentAr) || 
          (story.audio_ar_male && story.audio_ar_female) || 
          (story.audioArMale && story.audioArFemale)) {
        console.log(`Skipping story ${i + 1}/${totalStories}: ${displayTitle} (already has audio or invalid content)`);
        continue;
      }
      
      console.log(`Processing story ${i + 1}/${totalStories}: ${displayTitle}`);
      
      try {
        const filePrefix = storyType === 'nonfiction' ? 'nonfiction_' : '';
        const storyId = story.id || `story${i+1}`;
        const relativePath = storyType === 'nonfiction' ? 'data/audio/nonfiction/' : 'data/audio/';
        
        // Generate Arabic audio with male voice if needed
        if (!story.audio_ar_male && !story.audioArMale) {
          const maleAudioFileName = `${filePrefix}${storyId}_ar_male.mp3`;
          await generateAudio(contentAr, maleAudioFileName, 'male');
          
          // Update appropriate field based on JSON structure
          if (storyType === 'nonfiction') {
            story.audioArMale = `${relativePath}${maleAudioFileName}`;
          } else {
            story.audio_ar_male = `${relativePath}${maleAudioFileName}`;
          }
          
          console.log(`Generated male audio for story: ${displayTitle}`);
          
          // Add a small delay between requests to avoid API rate limits
          await sleep(2000);
        }
        
        // Generate Arabic audio with female voice if needed
        if (!story.audio_ar_female && !story.audioArFemale) {
          const femaleAudioFileName = `${filePrefix}${storyId}_ar_female.mp3`;
          await generateAudio(contentAr, femaleAudioFileName, 'female');
          
          // Update appropriate field based on JSON structure
          if (storyType === 'nonfiction') {
            story.audioArFemale = `${relativePath}${femaleAudioFileName}`;
          } else {
            story.audio_ar_female = `${relativePath}${femaleAudioFileName}`;
          }
          
          console.log(`Generated female audio for story: ${displayTitle}`);
          
          // Add a small delay between story processing
          await sleep(2000);
        }
        
        // Remove any old single audio reference if it exists
        if (story.audio_ar) {
          delete story.audio_ar;
        }
        if (story.audioAr) {
          delete story.audioAr;
        }
        
        // Update the story in the original data
        if (storiesData.stories) {
          storiesData.stories[i] = story;
        } else {
          storiesData[i] = story;
        }
        
        // Write the updated JSON back to the file after each story
        // This ensures we don't lose progress if the script is interrupted
        await writeFileAsync(storiesFilePath, JSON.stringify(storiesData, null, 2), 'utf8');
        console.log(`Updated stories JSON for: ${displayTitle}`);
      } catch (error) {
        console.error(`Failed to process story ${displayTitle}: ${error.message}`);
        failedGenerations.push({
          id: story.id || `story${i+1}`,
          title: displayTitle,
          error: error.message
        });
        
        // Continue with next story despite errors
        continue;
      }
    }
    
    console.log(`All ${storyType} stories processed. Stories JSON updated with Arabic audio file paths for male and female voices`);
    
    // Report any failed generations
    if (failedGenerations.length > 0) {
      console.log('\nFailed generations:');
      failedGenerations.forEach(failure => {
        console.log(`- ${failure.title} (${failure.id}): ${failure.error}`);
      });
    }
    
  } catch (error) {
    console.error(`Error processing stories: ${error.message || error}`);
    console.error('Error details:', error);
  }
}

// Create audio directory if it doesn't exist
if (!fs.existsSync(audioDir)) {
  fs.mkdirSync(audioDir, { recursive: true });
}

// Run the script
processStories()
  .then(() => console.log(`Arabic audio generation complete for ${storyType} stories (both male and female voices)`))
  .catch(err => console.error('Error:', err.message || err));

/**
 * Note: To run this script, you need to:
 * 1. Sign up for a PlayHT account and get your API credentials
 * 2. Run the script with:
 *    - node generate_audio.js              # For fiction stories (default)
 *    - node generate_audio.js nonfiction   # For non-fiction stories
 * 
 * The script will:
 * - Check all stories in the selected JSON file and identify which ones need audio generation
 * - Generate Arabic audio files (male and female voices) only for stories that don't have them
 * - Save the files to the appropriate audio directory based on story type
 * - Update the JSON file with paths to these audio files
 * - Skip stories that already have both male and female audio or don't have valid Arabic content
 */