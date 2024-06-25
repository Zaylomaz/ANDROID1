#!/bin/zsh
split=false

while getopts "s" opt; do
    case "${opt}" in
    s) split=true;;
    esac
done

cd app/

if "$split" = true
  then
    if ! command -v fvm &> /dev/null
    then
      flutter build apk \
      --release \
      --flavor=dev \
      --no-tree-shake-icons \
      --split-per-abi \
      --target=lib/main_dev.dart
    else
      fvm flutter build apk \
      --release \
      --flavor=dev \
      --no-tree-shake-icons \
      --split-per-abi \
      --target=lib/main_dev.dart
    fi
else
  if ! command -v fvm &> /dev/null
  then
    flutter build apk \
    --release \
    --flavor=dev \
    --no-tree-shake-icons \
    --target=lib/main_dev.dart
  else
    fvm flutter build apk \
    --release \
    --flavor=dev \
    --no-tree-shake-icons \
    --target=lib/main_dev.dart
  fi
fi