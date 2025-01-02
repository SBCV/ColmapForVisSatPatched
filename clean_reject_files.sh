#!/bin/bash

# This script expects the following parameter:
# 	- the path to the colmap source directory where the reject files will be deleted

if [ $# -lt 1 ] || [ $# -gt 1 ]; then
    echo "Script expects 1 parameter, but ${#} provided!" >&2
    echo "Usage: $0 <path_to_colmap_source>"
    exit 2
fi

COLMAP_TARGET_DP=$1
cd $COLMAP_TARGET_DP

# Delete previous reject files
find . -name \*.rej | xargs rm
