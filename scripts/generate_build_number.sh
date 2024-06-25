#!/bin/bash

ipa=false
apk=false

while getopts "ai" opt; do
    case "${opt}" in
    a) apk=true;;
    i) ipa=true;;
    esac
done

if "$ipa" = true
then
app_build_number=$(date '+%y%m%d%H%M')
fi

if "$apk" = true
then
app_build_number=$(date '+%m%d%H%M')
fi



echo -ne "$app_build_number"