#!/bin/bash

# Standalone install script for copying files

set -e

base_dir="${BASE_DIR:-$PWD}"
prefix="${XDG_DATA_HOME:-$HOME/.local/share}"
krunner_dbusdir="$prefix/krunner/dbusplugins"
services_dir="$prefix/dbus-1/services/"

mkdir -p $krunner_dbusdir
mkdir -p $services_dir

cp ssh-runner.desktop $krunner_dbusdir
sed "s|%{BASE_DIR}|$base_dir|" com.selfcoders.ssh-runner.service > $services_dir/com.selfcoders.ssh-runner.service

kquitapp6 krunner
