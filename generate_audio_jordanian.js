const fs = require('fs');
const path = require('path');
const PlayHT = require('playht');
const util = require('util');

// Convert callbacks to promises
const writeFileAsync = util.promisify(fs.writeFile);
const readFileAsync = util.promisify(fs.readFile);

/**
 * This script generates audio files for Jordanian Arabic text content from story JSON files
 * using the PlayHT API. It processes stories and adds paths to the audio files
 * in the JSON data structure.
 * 
 * Usage:
 * - node generate_audio_jordanian.js                    # Processes Jordanian fiction stories (default)
 * - node generate_audio_jordanian.js nonfiction         # Processes Jordanian non-fiction stories
 * 
 * Prerequisites:
 * 1. PlayHT API credentials (userId and apiKey)
 * 2. Installed dependencies: playht
 */

// Initialize PlayHT with your credentials
// You need to replace these with your actual credentials from your PlayHT account
PlayHT.init({
  userId: 'o89zFo5DFBdxa4w7qyegbwV1ZPF3', // Same as the Egyptian script
  apiKey: 'ak-4c0056e0f44d47d88244294e68dded22',  // Same as the Egyptian script
});

// Determine if processing nonfiction from command line arguments
const arg = process.argv[2] || '';
const isNonfiction = arg === 'nonfiction';

// Path to the stories JSON file
const storiesFilePath = path.join(
  __dirname, 
  'assets', 
  'stories_json',
  'jordanian',
  isNonfiction ? 'jordanian_stories_nonfiction.json' : 'jordanian_stories.json'
);

// Directory to save audio files
const audioDir = path.join(
  __dirname, 
  'assets', 
  'data', 
  'audio', 
  'jordanian', 
  isNonfiction ? 'nonfiction' : ''
);

// Ensure audio directory exists
if (!fs.existsSync(audioDir)) {
  fs.mkdirSync(audioDir, { recursive: true });
}

console.log(`Processing Jordanian ${isNonfiction ? 'nonfiction' : 'fiction'} stories from: ${storiesFilePath}`);
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
    
    // Handle different JSON structures for fiction vs non-fiction
    const stories = storiesData.stories || storiesData;
    const totalStories = stories.length;
    
    console.log(`Found ${totalStories} stories to process`);
    
    // Process all stories and check which ones need audio
    for (let i = 0; i < totalStories; i++) {
      const story = stories[i];
      
      // Handle JSON structures 
      const contentAr = story.content_ar || story.contentAr || story.story_content;
      const titleAr = story.story_title || story.title_ar || '';
      const titleEn = story.title_en || story.titleEn || '';
      const displayTitle = titleAr || titleEn || `Story ${i+1}`;
      
      // Set up the audio file field names
      let maleAudioField, femaleAudioField;
      
      if (isNonfiction) {
        maleAudioField = 'audio_jordanian_nonfiction_male';
        femaleAudioField = 'audio_jordanian_nonfiction_female';
      } else {
        maleAudioField = 'audio_jordanian_male';
        femaleAudioField = 'audio_jordanian_female';
      }
      
      // Check if audio files already exist for this story
      if (story[maleAudioField] && story[femaleAudioField]) {
        console.log(`Skipping story ${i + 1}/${totalStories}: ${displayTitle} (audio files already exist)`);
        continue;
      }
      
      // Skip if story has no valid Arabic content
      if (!validateArabicContent(contentAr)) {
        console.log(`Skipping story ${i + 1}/${totalStories}: ${displayTitle} (invalid content)`);
        continue;
      }
      
      console.log(`Processing story ${i + 1}/${totalStories}: ${displayTitle}`);
      
      // Setup file paths
      const filePrefix = isNonfiction ? 'nonfiction_' : '';
      const storyId = story.id || `story${i+1}`;
      
      // Define audio file names with dialect prefix
      const maleAudioFileName = `${storyId}_jordanian_${isNonfiction ? 'nonfiction_' : ''}male.mp3`;
      const femaleAudioFileName = `${storyId}_jordanian_${isNonfiction ? 'nonfiction_' : ''}female.mp3`;
      
      // Set relative path for audio files
      const relativePath = isNonfiction ? 'data/audio/jordanian/nonfiction/' : 'data/audio/jordanian/';
      
      try {
        // Generate male audio
        await generateAudio(contentAr, maleAudioFileName, 'male');
        console.log(`Generated male audio for story: ${displayTitle}`);
        story[maleAudioField] = `${relativePath}${maleAudioFileName}`;
        
        // Add a small delay between requests
        await sleep(500);
        
        // Generate female audio
        await generateAudio(contentAr, femaleAudioFileName, 'female');
        console.log(`Generated female audio for story: ${displayTitle}`);
        story[femaleAudioField] = `${relativePath}${femaleAudioFileName}`;
        
        // Save the updated story back to the stories array
        if (storiesData.stories) {
          storiesData.stories[i] = story;
        } else {
          storiesData[i] = story;
        }
        
        // Write the updated JSON back to the file after each story
        await writeFileAsync(storiesFilePath, JSON.stringify(storiesData, null, 2), 'utf8');
        console.log(`Updated JSON file with audio paths for story: ${displayTitle}`);
        
        // Add a delay between stories to avoid overwhelming the API
        await sleep(1000);
      } catch (error) {
        console.error(`Failed to generate audio for story "${displayTitle}": ${error.message || error}`);
        failedGenerations.push({
          id: storyId,
          title: displayTitle,
          error: error.message || error
        });
        // Continue with the next story even if this one fails
        continue;
      }
    }
    
    // Final report
    if (failedGenerations.length > 0) {
      console.log('\nFailed audio generations:');
      failedGenerations.forEach(failed => {
        console.log(`- ${failed.title} (${failed.id}): ${failed.error}`);
      });
    }
    
    console.log(`All ${isNonfiction ? 'nonfiction' : 'fiction'} stories processed. Stories JSON updated with audio file paths.`);
  } catch (error) {
    console.error(`Error processing stories: ${error.message || error}`);
  }
}

// Run the script
processStories()
  .then(() => console.log(`${isNonfiction ? 'Nonfiction' : 'Fiction'} audio generation complete`))
  .catch(err => console.error('Error:', err.message || err)); 