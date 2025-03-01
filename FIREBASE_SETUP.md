# Firebase Setup Instructions

This document provides instructions on how to set up Firebase for your Flutter application.

## Prerequisites

- [Flutter](https://flutter.dev/docs/get-started/install) installed on your machine
- [Firebase account](https://firebase.google.com/)
- [Node.js](https://nodejs.org/) installed on your machine

## Step 1: Install Required Tools

1. Install the Firebase CLI:
   ```bash
   npm install -g firebase-tools
   ```

2. Log in to Firebase:
   ```bash
   firebase login
   ```

3. Install the FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```

## Step 2: Create a Firebase Project

1. Go to the [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter a project name and follow the setup wizard
4. Once the project is created, you're ready to configure your Flutter app

## Step 3: Configure Your Flutter App with Firebase

1. Run the following command in your project directory:
   ```bash
   flutterfire configure
   ```

2. Select your Firebase project from the list
3. Select the platforms you want to support (iOS, Android, Web, etc.)
4. The CLI will generate the necessary configuration files for each platform

## Step 4: Enable Authentication Methods

1. Go to the [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Go to "Authentication" in the left sidebar
4. Click on "Sign-in method"
5. Enable the authentication methods you want to use:
   - Email/Password
   - Google
   - Facebook
   - Apple

### For Google Sign-In:
- No additional setup is required if you used the FlutterFire CLI

### For Facebook Sign-In:
1. Create a Facebook Developer account if you don't have one
2. Create a new app in the Facebook Developer Console
3. Add the Facebook Login product to your app
4. Configure your app settings with your iOS and Android package names
5. Copy the App ID and App Secret to the Firebase Console

## Step 5: Update Your Code

The app is already set up to use Firebase Authentication. Once you've completed the steps above, the authentication should work without any additional code changes.

## Troubleshooting

If you encounter any issues:

1. Make sure you've followed all the steps above
2. Check the console logs for any error messages
3. Verify that your Firebase project is properly configured
4. Ensure that the authentication methods you're using are enabled in the Firebase Console

## Additional Resources

- [FlutterFire Documentation](https://firebase.flutter.dev/docs/overview)
- [Firebase Authentication Documentation](https://firebase.google.com/docs/auth)
- [Google Sign-In for Flutter](https://pub.dev/packages/google_sign_in)
- [Facebook Login for Flutter](https://pub.dev/packages/flutter_facebook_auth) 