#!/bin/sh
# Shell script to forward xcode build settings to the ruby script
export PATH
RUBY_PATH=~/.rvm/bin/ruby-rvm-env
if [ ! -L $RUBY_PATH ]; then
  RUBY_PATH=/usr/local/rvm/bin/ruby-rvm-env
  if [ ! -L $RUBY_PATH ]; then
    RUBY_PATH=ruby
  fi
fi
MYPATH="`dirname \"$0\"`"
VAR="${RUBY_PATH} \"${MYPATH}/environmentbuild.rb\" --project_dir \"${PROJECT_DIR}\" --target \"${TARGET_NAME}\" --infoplist_file \"${INFOPLIST_FILE}\" --configuration \"${CONFIGURATION}\" --environment $1 > \"${MYPATH}/.__environment.log\""
eval $VAR
