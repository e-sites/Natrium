#!/bin/sh
# Shell script to forward xcode build settings to the ruby script
export PATH

ruby "./environmentbuild.rb" --project_dir "${PROJECT_DIR}" --infoplist_file "${INFOPLIST_FILE}" --configuration "${CONFIGURATION}" --environment $* > "./.__environment.log"
