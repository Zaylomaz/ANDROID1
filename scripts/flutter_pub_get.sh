#!/bin/zsh

echo '*==========*'
echo 'GET PACKAGES'
echo '*==========*'
if ! command -v fvm &> /dev/null
then
  find . -name "pubspec.yaml" -not -path "./codegen_config/flutter/*"  -execdir sh -c 'flutter pub get' \;
else
  find . -name "pubspec.yaml" -not -path "./codegen_config/flutter/*" -execdir sh -c 'fvm flutter pub get' \;
fi
