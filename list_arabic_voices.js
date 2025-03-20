const PlayHT = require('playht');

// Initialize PlayHT with your credentials
PlayHT.init({
  userId: 'o89zFo5DFBdxa4w7qyegbwV1ZPF3',
  apiKey: 'ak-4c0056e0f44d47d88244294e68dded22',
});

async function listArabicVoices() {
  try {
    console.log('Fetching voices from PlayHT API...');
    
    // Get all available voices
    const voices = await PlayHT.listVoices();
    
    console.log(`Total voices available: ${voices.length}`);
    
    // Filter for Arabic voices
    const arabicVoices = voices.filter(voice => {
      // Check for Arabic in the voice name, language field, or language tags
      const hasArabicName = voice.name && voice.name.toLowerCase().includes('arab');
      const hasArabicLanguage = voice.language && voice.language.toLowerCase().includes('arab');
      const hasArabicTags = voice.languageTags && voice.languageTags.some(tag => 
        tag.toLowerCase().includes('arab') || tag.toLowerCase() === 'ar'
      );
      
      return hasArabicName || hasArabicLanguage || hasArabicTags;
    });
    
    console.log(`Found ${arabicVoices.length} voices that support Arabic:\n`);
    
    // Display the Arabic voices with their details
    arabicVoices.forEach((voice, index) => {
      console.log(`[${index + 1}] ${voice.name || 'Unnamed Voice'}`);
      console.log(`   ID: ${voice.id}`);
      console.log(`   Engine: ${voice.engine}`);
      console.log(`   Gender: ${voice.gender || 'Unknown'}`);
      console.log(`   Language: ${voice.language || 'Not specified'}`);
      console.log(`   Sample: ${voice.sample || 'No sample available'}`);
      console.log(`   Language Tags: ${voice.languageTags ? voice.languageTags.join(', ') : 'None'}`);
      console.log('');
    });
    
    // Also log voices with s3:// prefix that work with Play3.0-mini
    console.log('\nVoices with s3:// prefix (compatible with Play3.0-mini):');
    const s3Voices = voices.filter(voice => voice.id && voice.id.startsWith('s3://'));
    s3Voices.slice(0, 10).forEach((voice, index) => {
      console.log(`[${index + 1}] ${voice.name || 'Unnamed Voice'}`);
      console.log(`   ID: ${voice.id}`);
      console.log(`   Engine: ${voice.engine}`);
      console.log('');
    });
    
    return { arabicVoices, s3Voices };
  } catch (error) {
    console.error('Error fetching voices:', error.message || error);
    console.error('Error details:', error);
    throw error;
  }
}

// Run the function
listArabicVoices()
  .then(() => console.log('Voice listing complete'))
  .catch(err => console.error('Error:', err.message || err)); 