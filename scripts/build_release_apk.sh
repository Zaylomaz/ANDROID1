#!/bin/zsh

split=false

while getopts "s" opt; do
    case "${opt}" in
    s) split=true;;
    esac
done

cd app/

if ! command -v fvm &> /dev/null
then
  if "$split" = true
  then
    flutter build apk \
    --release \
    --flavor=prodapk \
    --no-tree-shake-icons \
    --split-per-abi \
    --target=lib/main_prod.dart
  else
    flutter build apk \
    --release \
    --flavor=prodapk \
    --no-tree-shake-icons \
    --target=lib/main_prod.dart
  fi
else
  if "$split" = true
  then
    fvm flutter build apk \
    --release \
    --flavor=prodapk \
    --no-tree-shake-icons \
    --split-per-abi \
    --target=lib/main_prod.dart
  else
    fvm flutter build apk \
    --release \
    --flavor=prodapk \
    --no-tree-shake-icons \
    --target=lib/main_prod.dart
  fi
fi