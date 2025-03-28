const fs = require('fs');
const path = require('path');
const PlayHT = require('playht');
const util = require('util');

// Convert callbacks to promises
const writeFileAsync = util.promisify(fs.writeFile);
const readFileAsync = util.promisify(fs.readFile);

/**
 * This script regenerates audio for all stories in the nonfiction JSON file
 * using the PlayHT API. This fixes orientation issues in the text-to-speech conversion.
 */

// Initialize PlayHT with your credentials
PlayHT.init({
  userId: '',
  apiKey: '',
});

// Path to the stories JSON file
const storiesFilePath = path.join(__dirname, 'assets', 'stories_json', 'msa', 'msa_stories_nonfiction.json');

// Directory to save audio files
const audioDir = path.join(__dirname, 'assets', 'data', 'audio', 'nonfiction');

// Define voice IDs for male and female voices
const VOICE_IDS = {
  male: 's3://voice-cloning-zero-shot/c8731d9b-c16c-4dda-b320-7db983880687/original/manifest.json',
  female: 's3://voice-cloning-zero-shot/b6f988dc-c137-4753-ad11-aa7cb0215e17/original/manifest.json'
};

// Add a sleep function to handle API rate limits
const sleep = (ms) => new Promise(resolve => setTimeout(resolve, ms));

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
        voiceEngine: 'Play3.0-mini',
        language: 'arabic',
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
 * Process all stories from the nonfiction JSON file
 */
async function regenerateAllNonfictionAudio() {
  try {
    // Read the stories JSON file
    const data = await readFileAsync(storiesFilePath, 'utf8');
    const storiesData = JSON.parse(data);
    
    // Get all stories
    const stories = storiesData.stories || storiesData;
    if (!stories || stories.length === 0) {
      console.error('No stories found in the JSON file');
      return;
    }

    console.log(`Found ${stories.length} stories in the nonfiction JSON file`);
    
    // Track failed generations
    const failedGenerations = [];
    
    // Process each story
    for (let i = 0; i < stories.length; i++) {
      const story = stories[i];
      const contentAr = story.content_ar || story.contentAr;
      const storyId = story.id || `story${i+1}`;
      const titleAr = story.title_ar || story.titleAr || '';
      const titleEn = story.title_en || story.titleEn || '';
      const displayTitle = titleAr || titleEn || `Story ${i+1}`;
      
      // Validate that the story has Arabic content
      if (!contentAr || typeof contentAr !== 'string' || contentAr.trim().length < 10) {
        console.log(`[${i+1}/${stories.length}] Skipping story "${displayTitle}": No valid Arabic content`);
        continue;
      }
      
      console.log(`[${i+1}/${stories.length}] Regenerating audio for story: ${displayTitle}`);
      
      // Delete existing audio files if they exist
      const maleAudioFileName = `nonfiction_${storyId}_ar_male.mp3`;
      const femaleAudioFileName = `nonfiction_${storyId}_ar_female.mp3`;
      const malePath = path.join(audioDir, maleAudioFileName);
      const femalePath = path.join(audioDir, femaleAudioFileName);
      
      if (fs.existsSync(malePath)) {
        fs.unlinkSync(malePath);
        console.log(`Deleted existing male audio file: ${malePath}`);
      }
      
      if (fs.existsSync(femalePath)) {
        fs.unlinkSync(femalePath);
        console.log(`Deleted existing female audio file: ${femalePath}`);
      }
      
      try {
        // Generate male audio
        await generateAudio(contentAr, maleAudioFileName, 'male');
        story.audioArMale = `data/audio/nonfiction/${maleAudioFileName}`;
        console.log(`Generated new male audio file for ${displayTitle}`);
        
        // Add a small delay between requests to avoid API rate limits
        await sleep(2000);
        
        // Generate female audio
        await generateAudio(contentAr, femaleAudioFileName, 'female');
        story.audioArFemale = `data/audio/nonfiction/${femaleAudioFileName}`;
        console.log(`Generated new female audio file for ${displayTitle}`);
        
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
        
        // Add a larger delay between stories to avoid overwhelming the API
        await sleep(3000);
      } catch (error) {
        console.error(`Failed to process story "${displayTitle}": ${error.message}`);
        failedGenerations.push({
          id: storyId,
          title: displayTitle,
          error: error.message
        });
        
        // Continue with the next story despite errors
        continue;
      }
    }
    
    console.log('Audio regeneration complete for all nonfiction stories');
    
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

// Ensure the audio directory exists
if (!fs.existsSync(audioDir)) {
  fs.mkdirSync(audioDir, { recursive: true });
}

// Run the script
regenerateAllNonfictionAudio()
  .then(() => console.log('Regeneration process complete for all nonfiction stories'))
  .catch(err => console.error('Error:', err.message || err)); 