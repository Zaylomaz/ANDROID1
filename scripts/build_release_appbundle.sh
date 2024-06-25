#!/bin/zsh

cd app/

if ! command -v fvm &> /dev/null
then
  flutter build appbundle --flavor=prod -t lib/main_prod_market.dart
else
  fvm flutter build appbundle --flavor=prod -t lib/main_prod_market.dart
fi