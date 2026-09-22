#!/bin/bash
set -e

echo "=== AegiSyn AI: Vercel Deployment Pipeline ==="

# Check if Flutter SDK is already available in the build environment
if ! command -v flutter &> /dev/null
then
    echo ">> Flutter SDK not detected. Cloning Flutter stable branch..."
    git clone https://github.com/flutter/flutter.git -b stable --depth 1 $HOME/flutter
    export PATH="$PATH:$HOME/flutter/bin"
else
    echo ">> Using existing Flutter installation from PATH"
fi

flutter --version

echo ">> Enabling Flutter Web..."
flutter config --enable-web

echo ">> Resolving dependencies..."
flutter pub get

echo ">> Building AegiSyn AI Flutter Web Release..."
flutter build web --release

echo ">> Build completed successfully! Artifacts placed in build/web"
