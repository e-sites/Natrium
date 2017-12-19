#!/bin/sh

VERSION=`sh get_version.sh`
FILE="Res/Natrium.json"
LINE="\"${VERSION}\": \"https://github.com/e-sites/Natrium/raw/${VERSION}/Res/Natrium.framework.zip\""
GREP=`grep -rl "${LINE}" ${FILE}`
if [[ "$GREP" == "" ]]; then
  CONTENTS=`cat $FILE | tail -n +2`
  CONTENTS="{\n  $LINE,\n$CONTENTS"
  echo "$CONTENTS" > $FILE
fi
