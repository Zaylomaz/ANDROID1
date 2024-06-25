#!/bin/bash

output=$(dart format . -o none)
errors=""

check_output_line() {
  if [[ -z "$1" ]]; then
    return
  fi

  case "$1" in
  Formatted*) ;;
  *lib/src/intl/localizations.dart) ;;
  *.g.dart) ;;
  *)
    errors="${errors}WRONG FORMATTING: $1\n"
    ;;
  esac
}

while read -r line; do check_output_line "$line"; done <<EOF
$output
EOF

if [[ -z "$errors" ]]; then
  exit 0
else
  echo -e "$errors"
  exit 1
fi
