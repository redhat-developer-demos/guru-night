#!/bin/bash
set -e

_CURR_DIR="$( cd "$(dirname "$0")" ; pwd -P )"

export CONFIGS_DIR="$_CURR_DIR/../config"
export WORK_DIR="$_CURR_DIR/../work"
