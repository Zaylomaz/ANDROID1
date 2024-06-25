#!/bin/zsh

APP_VERSION_NAME="$(bash ./scripts/generate_version_name.sh)"
APP_BUILD_NUMBER="$(bash ./scripts/generate_build_number.sh -i)"

cd app/

if ! command -v fvm &> /dev/null
then
  flutter build ipa \
    --release \
    --flavor dev \
    --no-sound-null-safety \
    --obfuscate \
    --split-debug-info \
    --export-method ad-hoc \
    --build-number=$APP_BUILD_NUMBER \
    --build-name=$APP_VERSION_NAME \
    --target=lib/main_dev.dart
else
  fvm flutter build ipa \
  --release \
  --flavor dev \
  --no-sound-null-safety \
  --obfuscate \
  --split-debug-info \
  --export-method ad-hoc \
  --build-number=$APP_BUILD_NUMBER \
  --build-name=$APP_VERSION_NAME \
  --target=lib/main_dev.dart
fi