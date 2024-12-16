#!/bin/bash

# This script expects the following parameter:
# 	- the path to the colmap source directory wich will be modified using a set of patches
#   - the commit SHA-1 hash of the colmap version compatible to the patch files
#   - the commit SHA-1 hash or "latest" of the colmap version we would like to update the patch files (optional)

if [ $# -lt 2 ] || [ $# -gt 3 ]; then
    echo "Script expects between 2 and 3 parameters, but ${#} provided!" >&2
    echo "Usage: $0 <path_to_colmap_source> <colmap_compatible_commit_hash> <colmap_target_commit_hash>"
    echo "The last parameter <colmap_target_hash> is optional."
    exit 2
fi

COLMAP_TARGET_DP=$1
COLMAP_COMPATIBLE_COMMIT_HASH=$2
COLMAP_TARGET_COMMIT_HASH=${3:-"HEAD"} # "${3:=default}"

MAIN_BRANCH="main"
VISSAT_BRANCH="vissat"

# Go to the directory where the script is located
cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd
SH_FILE_DP=$PWD
PATCH_DP="${SH_FILE_DP}/patches"

cd $COLMAP_TARGET_DP

# Delete previous reject files
# find . -name \*.rej | xargs rm

echo "Colmap compatible commit hash: $COLMAP_COMPATIBLE_COMMIT_HASH"
echo "Colmap target commit hash: $COLMAP_TARGET_COMMIT_HASH"

# Ensure we are on the MAIN_BRANCH before running rev-list
git switch --force $MAIN_BRANCH >/dev/null 2>&1

# Get a list of all commits from $COLMAP_COMPATIBLE_COMMIT_HASH to $COLMAP_TARGET_COMMIT_HASH
COMMIT_LIST=$(git rev-list --reverse $COLMAP_COMPATIBLE_COMMIT_HASH^..$COLMAP_TARGET_COMMIT_HASH)
COMMIT_LIST_LENGTH=$(git rev-list --count $COLMAP_COMPATIBLE_COMMIT_HASH^..$COLMAP_TARGET_COMMIT_HASH)
echo "Number commits from compatible to target commit: $COMMIT_LIST_LENGTH"
# for COMMIT_SHA in $COMMIT_LIST
# do
#     echo $COMMIT_SHA
# done

apply_patches() {
    # Options:
    #  "-v"         Verbose (useful for debugging, shows why applying patch failed)
    #  "--reject"   Creation of *.rej files (hunks that failed to apply) 
    OPTIONS="--reject"

    # Loop through each patch file
    for patch in "$@";
    do
        git apply $OPTIONS "$patch"

        # Check the exit status of git apply
        if [ $? -ne 0 ]; then
            # Return 1 if patch fails
            echo "Failed to apply patch: $patch"
            return 1
        fi
    done

    echo "All patches applied successfully."
    return 0
}

patches=(
    "${PATCH_DP}/.gitignore.patch"
    "${PATCH_DP}/CMakeLists.txt.patch"
    "${PATCH_DP}/README.md.patch"
    "${PATCH_DP}/scripts__python__build.py.patch"
    "${PATCH_DP}/src__base__camera.cc.patch"
    "${PATCH_DP}/src__base__camera_models.h.patch"
    "${PATCH_DP}/src__base__cost_functions.h.patch"
    "${PATCH_DP}/src__base__database_cache.h.patch"
    "${PATCH_DP}/src__base__reconstruction.cc.patch"
    "${PATCH_DP}/src__base__reconstruction.h.patch"

    "${PATCH_DP}/src__controllers__bundle_adjustment.cc.patch"
    "${PATCH_DP}/src__ui__bundle_adjustment_widget.cc.patch"

    "${PATCH_DP}/src__exe__colmap.cc.patch"
    "${PATCH_DP}/src__exe__sfm.cc.patch"
    "${PATCH_DP}/src__exe__sfm.h.patch"

    "${PATCH_DP}/src__feature__sift.cc.patch"

    "${PATCH_DP}/src__mvs__depth_map.cc.patch"
    "${PATCH_DP}/src__mvs__depth_map.h.patch"
    "${PATCH_DP}/src__mvs__fusion.cc.patch"
    "${PATCH_DP}/src__mvs__fusion.h.patch"
    "${PATCH_DP}/src__mvs__image.cc.patch"
    "${PATCH_DP}/src__mvs__image.h.patch"
    "${PATCH_DP}/src__mvs__model.cc.patch"
    "${PATCH_DP}/src__mvs__model.h.patch"
    "${PATCH_DP}/src__mvs__patch_match.cc.patch"
    "${PATCH_DP}/src__mvs__patch_match.h.patch"
    "${PATCH_DP}/src__mvs__patch_match_cuda.cu.patch"
    "${PATCH_DP}/src__mvs__patch_match_cuda.h.patch"
    "${PATCH_DP}/src__mvs__workspace.cc.patch"
    "${PATCH_DP}/src__mvs__workspace.h.patch"

    "${PATCH_DP}/src__optim__bundle_adjustment.cc.patch"
    "${PATCH_DP}/src__optim__bundle_adjustment.h.patch"
    "${PATCH_DP}/src__sfm__incremental_mapper.cc.patch"
    "${PATCH_DP}/src__util__option_manager.cc.patch"
)


for COMMIT_SHA in $COMMIT_LIST;
do
    echo ""
    echo "---------------------------------------------------------------------"
    echo "-------- Processing $COMMIT_SHA --------"
    echo "---------------------------------------------------------------------"
    echo ""
    git switch --force $MAIN_BRANCH >/dev/null 2>&1
    # Delete outdated local $VISSAT_BRANCH (if exists)
    if [ -n "$(git branch --list vissat)" ]; then
        git branch --force --delete $VISSAT_BRANCH >/dev/null
    fi
    # Order of "--force" and "--create" can not be swapped
    git switch --force --create $VISSAT_BRANCH $COMMIT_SHA
    echo "Set head to commit with hash $(git rev-parse HEAD)"

    apply_patches "${patches[@]}"

    if [ $? -ne 0 ]; then
        echo "apply_patches failed for commit: $COMMIT_SHA"
        echo "---------------------------------------------------------------------"
        echo "-------- Status --------"
        echo "---------------------------------------------------------------------"
        git status
        # Exit the loop
        break
    fi
done
