#!/bin/zsh

# ./build.sh -apk => android
# ./build.sh -ipa => ios
# ./build.sh -all => ios && android

ipa=false
apk=false
apkRelease=false
all=false

while getopts "aibr" opt; do
    case "${opt}" in
    a) apk=true;;
    i) ipa=true;;
    b) all=true;;
    r) apkRelease=true;;
    esac
done

if "$ipa" = true
then
./scripts/build_debug_ipa.sh
fi

if "$apk" = true
then
./scripts/build_debug_apk.sh
fi

if "$apkRelease" = true
then
./scripts/build_release_apk.sh
fi

if "$all" = true
then
./scripts/build_debug_ipa.sh
./scripts/build_debug_apk.sh
fi