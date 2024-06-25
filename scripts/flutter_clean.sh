#!/bin/zsh

echo '*=======*'
echo 'CLEAN ALL'
echo '*=======*'
if ! command -v fvm &> /dev/null
then
  find . -name "pubspec.yaml" -not -path "./codegen_config/flutter/*" -execdir sh -c 'rm -rf .dart_tool; rm -rf build; rm -f pubspec.lock; flutter clean .' \;
else
  find . -name "pubspec.yaml" -not -path "./codegen_config/flutter/*" -execdir sh -c 'rm -rf .dart_tool; rm -rf build; rm -f pubspec.lock; fvm flutter clean .' \;
fi
