# shellcheck shell=bash

tmp_test() {

  local name
  name=''
  [ -n "$1" ] && name="_$1"
  if [ -d "/tmp/test${name}" ]
  then
    cd    "/tmp/test${name}" || cd ~ || cd /
  else
    mkdir "/tmp/test${name}" || return
    cd    "/tmp/test${name}" || cd ~ || cd /
  fi

}

temp_test() {

  local name
  name=''
  [ -n "$1" ] && name="_$1"
  if [ -d "$HOME/temp/test${name}" ]
  then
    cd    "$HOME/temp/test${name}" || cd ~ || cd /
  else
    mkdir "$HOME/temp/test${name}" || return
    cd    "$HOME/temp/test${name}" || cd ~ || cd /
  fi

}