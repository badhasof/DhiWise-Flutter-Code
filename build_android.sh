#!/bin/bash
set -e

echo "Cleaning the Flutter project..."
flutter clean

echo "Getting dependencies..."
flutter pub get

echo "Cleaning Android build..."
cd android
./gradlew clean
cd ..

echo "Building Android App Bundle with memory optimizations..."
export GRADLE_OPTS="-Xmx6g -XX:MaxMetaspaceSize=3g -XX:+HeapDumpOnOutOfMemoryError -Dfile.encoding=UTF-8 -XX:+UseParallelGC"
flutter build appbundle --release

echo "Build completed successfully!" 