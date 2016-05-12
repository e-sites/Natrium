#!/bin/sh
# Shell script to forward xcode build settings to the ruby script
export PATH

MYPATH="`dirname \"$0\"`"
ruby "${MYPATH}/environmentbuild.rb" --project_dir "${PROJECT_DIR}"\
  --infoplist_file "${INFOPLIST_FILE}"\
  --configuration "${CONFIGURATION}"\
  --environment $* > "${MYPATH}/.__environment.log"
