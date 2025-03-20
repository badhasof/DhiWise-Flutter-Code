const fs = require('fs');
const path = require('path');
const PlayHT = require('playht');
const util = require('util');

// Convert callbacks to promises
const writeFileAsync = util.promisify(fs.writeFile);
const readFileAsync = util.promisify(fs.readFile);

/**
 * This script generates audio files for Arabic text content from story JSON files
 * using the PlayHT API. It processes the first two stories and adds paths to the audio files
 * in the JSON data structure.
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

// Path to the stories JSON file
const storiesFilePath = path.join(__dirname, 'assets', 'msa_stories.json');

// Directory to save audio files
const audioDir = path.join(__dirname, 'assets', 'data', 'audio');

// Define voice IDs for male and female voices
const VOICE_IDS = {
  male: 's3://voice-cloning-zero-shot/c8731d9b-c16c-4dda-b320-7db983880687/original/manifest.json',
  female: 's3://voice-cloning-zero-shot/b6f988dc-c137-4753-ad11-aa7cb0215e17/original/manifest.json'
};

/**
 * Generates audio from text using PlayHT API
 * 
 * @param {string} text - The text to convert to speech
 * @param {string} outputFileName - Name of the output audio file
 * @param {string} voiceType - The type of voice to use ('male' or 'female')
 * @returns {Promise<string>} - Path to the generated audio file
 */
async function generateAudio(text, outputFileName, voiceType = 'male') {
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
    console.error(`Error generating audio: ${error.message || error}`);
    console.error('Error details:', error);
    throw error;
  }
}

/**
 * Process stories from the JSON file, generate audio for the first two stories
 * and update the JSON with paths to the audio files
 */
async function processStories() {
  try {
    // Read the stories JSON file
    const data = await readFileAsync(storiesFilePath, 'utf8');
    const storiesData = JSON.parse(data);
    
    // Process the remaining stories (starting from the third story)
    const storiesToProcess = storiesData.stories.slice(2);
    
    // Update the stories with audio files
    for (let i = 0; i < storiesToProcess.length; i++) {
      const story = storiesToProcess[i];
      const originalIndex = i + 2; // Actual index in the stories array
      
      console.log(`Processing story ${originalIndex + 1}/${storiesData.stories.length}: ${story.title_ar}`);
      
      // Generate Arabic audio with male voice
      const maleAudioFileName = `${story.id}_ar_male.mp3`;
      await generateAudio(story.content_ar, maleAudioFileName, 'male');
      
      // Generate Arabic audio with female voice
      const femaleAudioFileName = `${story.id}_ar_female.mp3`;
      await generateAudio(story.content_ar, femaleAudioFileName, 'female');
      
      // Add audio file paths to the story object
      // These paths are relative to the assets directory for use in the Flutter app
      story.audio_ar_male = `data/audio/${maleAudioFileName}`;
      story.audio_ar_female = `data/audio/${femaleAudioFileName}`;
      
      // Remove any old single audio reference if it exists
      if (story.audio_ar) {
        delete story.audio_ar;
      }
      
      // Update the story in the original data
      storiesData.stories[originalIndex] = story;
    }
    
    // Write the updated JSON back to the file
    await writeFileAsync(storiesFilePath, JSON.stringify(storiesData, null, 2), 'utf8');
    console.log('Updated stories JSON with Arabic audio file paths for male and female voices');
    
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
  .then(() => console.log('Arabic audio generation complete for both male and female voices'))
  .catch(err => console.error('Error:', err.message || err));

/**
 * Note: To run this script, you need to:
 * 1. Sign up for a PlayHT account and get your API credentials
 * 2. Replace the API credentials if needed
 * 3. Run the script with: node generate_audio.js
 * 
 * The script will:
 * - Generate Arabic audio files (male and female voices) for the first two stories
 * - Save the files to the assets/data/audio directory
 * - Update the JSON file with paths to these audio files
 */