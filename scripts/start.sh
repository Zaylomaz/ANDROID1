#!/bin/zsh

# ./start.sh => get_packages && codegen_build only
# ./start.sh -f => full update

full=false

while getopts "f" opt; do
    case "${opt}" in
        f) full=true;;
    esac
done

if "$full" = true
then
./scripts/flutter_clean.sh
fi

./scripts/flutter_pub_get.sh
./scripts/codegen_build.sh

if "$full" = true
then
cd app/ios/
rm Podfile.lock
pod install
fi