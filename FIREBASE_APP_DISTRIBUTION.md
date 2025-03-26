# Firebase App Distribution Setup

This document provides instructions on how to distribute your Flutter app to testers using Firebase App Distribution.

## Configuration

The project is already configured with the following Firebase App IDs:

- **iOS App ID**: 1:861015223952:ios:1cc6655b81382d9470b215
- **Android App ID**: 1:861015223952:android:8f19174c4bd6a72870b215

## Prerequisites for Distribution

1. **Bundler and Fastlane**:
   ```bash
   sudo gem install bundler
   bundle install
   ```

2. **iOS Setup**:
   - You'll need:
     - An Apple Developer account
     - A valid provisioning profile
     - Update the Apple ID and Team ID in `ios/fastlane/Appfile`

3. **Android Setup**:
   - Make sure you have:
     - Java JDK installed
     - Gradle properly configured

## Distributing Your App

### Using the Distribution Script

The easiest way to distribute your app is using the provided script:

```bash
# Make the script executable
chmod +x distribute.sh

# Distribute to both platforms
./distribute.sh

# Distribute only to Android
./distribute.sh android

# Distribute only to iOS
./distribute.sh ios

# Distribute with custom release notes
./distribute.sh both "Fixed login issue and improved performance"
```

### Manual Distribution

If you prefer to distribute manually:

#### For Android:

```bash
cd android
bundle exec fastlane firebase
```

#### For iOS:

```bash
cd ios
bundle exec fastlane firebase
```

## Adding Testers

1. Go to the Firebase Console at [https://console.firebase.google.com/](https://console.firebase.google.com/)
2. Select your project: "linguax-9b060"
3. Navigate to App Distribution in the left sidebar
4. Click on "Testers & Groups"
5. Create a group called "testers" (or use the existing one)
6. Add your testers' email addresses

## Testing the App

When you distribute a new build:

1. Testers will receive an email from Firebase with a link to download the app
2. They'll need to follow the instructions in the email to install the app
3. For iOS, they'll need to register their device first

## Troubleshooting

### iOS Distribution Issues:

- **Build Fails**: Check Xcode for errors, ensure certificates and provisioning profiles are valid
- **Distribution Fails**: Verify Apple ID and Team ID in the Appfile
- **Testers Can't Install**: Make sure their device UDID is registered in your Apple Developer account

### Android Distribution Issues:

- **Build Fails**: Check Gradle files for errors
- **Distribution Fails**: Verify Firebase project and app ID
- **Testers Can't Install**: Make sure they've accepted the invitation and are using the correct Google account

## Resources

- [Firebase App Distribution Documentation](https://firebase.google.com/docs/app-distribution)
- [Fastlane Documentation](https://docs.fastlane.tools/) 