#!/bin/sh
# Shell script to forward xcode build settings to the ruby script

PATH="`dirname \"$0\"`"
/usr/local/opt/ruby/bin/ruby "${PATH}/environmentbuild.rb" --project_dir "${PROJECT_DIR}" --infoplist_file "${INFOPLIST_FILE}" --configuration "${CONFIGURATION}" --environment $* > "${PATH}/.__environment.log"
