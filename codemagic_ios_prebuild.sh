#!/bin/bash
set -e

echo "Cleaning up any previous build files..."
rm -rf ios/Pods ios/Podfile.lock ios/.symlinks ios/Flutter/Flutter.podspec

echo "Updating CocoaPods repo..."
pod repo update

echo "Installing pods with repo update..."
cd ios
pod install --repo-update

echo "iOS dependencies installed successfully!" 