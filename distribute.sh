#!/bin/bash

# Script to distribute the app to Firebase App Distribution
# Usage: ./distribute.sh [android|ios|both] [release_notes]

# Default values
PLATFORM="both"
RELEASE_NOTES="New test build"
export WORKSPACE_DIR=$(pwd)

# Parse arguments
if [ "$1" != "" ]; then
  PLATFORM=$1
fi

if [ "$2" != "" ]; then
  RELEASE_NOTES=$2
fi

# Set up environment variables
export RELEASE_NOTES="$RELEASE_NOTES"

# Install Ruby dependencies
bundle install

# Distribute for Android
if [ "$PLATFORM" = "android" ] || [ "$PLATFORM" = "both" ]; then
  echo "Distributing Android app..."
  cd android && bundle exec fastlane firebase
fi

# Distribute for iOS
if [ "$PLATFORM" = "ios" ] || [ "$PLATFORM" = "both" ]; then
  echo "Distributing iOS app..."
  cd ios && bundle exec fastlane firebase
fi

echo "Distribution complete!"
