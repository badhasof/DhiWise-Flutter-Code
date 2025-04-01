#!/bin/bash
set -e

echo "Preparing Android build environment..."

# Clean up any previous build files
echo "Cleaning up previous builds..."
flutter clean

# Update dependencies
echo "Getting dependencies..."
flutter pub get

# Clean Android build
echo "Cleaning Android build..."
cd android
./gradlew clean
cd ..

# Set environment variables for Gradle
echo "Setting up memory optimizations..."
export GRADLE_OPTS="-Xmx6g -XX:MaxMetaspaceSize=3g -XX:+HeapDumpOnOutOfMemoryError -Dfile.encoding=UTF-8 -XX:+UseParallelGC"

# Additional environment variables for Codemagic
echo "export GRADLE_OPTS=\"-Xmx6g -XX:MaxMetaspaceSize=3g -XX:+HeapDumpOnOutOfMemoryError -Dfile.encoding=UTF-8 -XX:+UseParallelGC\"" >> $CM_ENV

echo "Android build environment prepared successfully!" 