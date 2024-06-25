#!/bin/zsh

function get_packages {
  if ! command -v fvm &> /dev/null
  then
    flutter pub get
  else
    fvm flutter pub get
  fi
}

function codegen_build {
  if ! command -v fvm &> /dev/null
  then
    flutter packages pub run build_runner build --delete-conflicting-outputs
  else
    fvm flutter packages pub run build_runner build --delete-conflicting-outputs
  fi
}

function copy_files_to_tmp_dir {
  FILE=$1

  ORIGINAL_DIR_NAME=$(dirname $FILE) # get file directory
  ORIGINAL_DIR_NAME=${ORIGINAL_DIR_NAME:1} # remove '.' at the beginning

  # Find index of /lib/ in file path
  t=$ORIGINAL_DIR_NAME
  searchstring="/lib/"
  rest=${t#*$searchstring}
  index=$(( ${#t} - ${#rest} - ${#searchstring} ))

  # Only leave the module name
  ORIGINAL_DIR_NAME=${ORIGINAL_DIR_NAME:1:$index-1}
  CODEGEN_DIR_NAME=codegen_tmp/lib/$ORIGINAL_DIR_NAME

  [ ! -d $CODEGEN_DIR_NAME ] && echo "Copying $ORIGINAL_DIR_NAME..." && mkdir -p $CODEGEN_DIR_NAME && cp -r $ORIGINAL_DIR_NAME/lib $CODEGEN_DIR_NAME/lib
}

function copy_file_to_dst_dir {
  FILE=$1

  # CODEGEN_DIR_NAME: codegen_tmp/lib/<real path>
  CODEGEN_DIR_NAME=$(dirname $FILE) # get file directory
  ORIGINAL_DIR_NAME=${CODEGEN_DIR_NAME:16} # remove 'codegen_tmp/lib/' at the beginning

  cp $FILE $ORIGINAL_DIR_NAME
}

echo ----------------------------------------
echo "CODE GENERATION: BUILD"
echo ----------------------------------------

grep --exclude-dir={'.symlinks','.fvm','codegen_config'} --include="*.dart" -r -i -l "part '.*\.g\.dart';" . | \
while read file ; do copy_files_to_tmp_dir $file ; done


cp "codegen_config/pubspec.yaml" "codegen_tmp"

(cd codegen_tmp && get_packages && codegen_build)

grep --exclude-dir={'.symlinks','.fvm','codegen_config'} --include="*.g.dart" -r -i -l "" codegen_tmp | \
while read file ; do copy_file_to_dst_dir $file ; done

rm -rf codegen_tmp

echo ----------------------------------------
echo "CODE GENERATION: BUILD -- DONE"
echo ----------------------------------------
