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
        git apply $OPTIONS "$PATCH_DP/$patch"

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
    ".gitignore.patch"
    "CMakeLists.txt.patch"
    "README.md.patch"
    "scripts__python__build.py.patch"
    "src__base__camera.cc.patch"
    "src__base__camera_models.h.patch"
    "src__base__cost_functions.h.patch"
    "src__base__database_cache.h.patch"
    "src__base__reconstruction.cc.patch"
    "src__base__reconstruction.h.patch"

    "src__controllers__bundle_adjustment.cc.patch"
    "src__ui__bundle_adjustment_widget.cc.patch"

    "src__exe__colmap.cc.patch"
    "src__exe__sfm.cc.patch"
    "src__exe__sfm.h.patch"

    "src__feature__sift.cc.patch"

    "src__mvs__depth_map.cc.patch"
    "src__mvs__depth_map.h.patch"
    "src__mvs__fusion.cc.patch"
    "src__mvs__fusion.h.patch"
    "src__mvs__image.cc.patch"
    "src__mvs__image.h.patch"
    "src__mvs__model.cc.patch"
    "src__mvs__model.h.patch"
    "src__mvs__patch_match.cc.patch"
    "src__mvs__patch_match.h.patch"
    "src__mvs__patch_match_cuda.cu.patch"
    "src__mvs__patch_match_cuda.h.patch"
    "src__mvs__workspace.cc.patch"
    "src__mvs__workspace.h.patch"

    "src__optim__bundle_adjustment.cc.patch"
    "src__optim__bundle_adjustment.h.patch"
    "src__sfm__incremental_mapper.cc.patch"
    "src__util__option_manager.cc.patch"
)


for COMMIT_SHA in $COMMIT_LIST;
do
    echo ""
    echo "---------------------------------------------------------------------"
    echo "-------- $COMMIT_SHA --------"
    echo "-------------- ($(git show -s --format=%ci $COMMIT_SHA)) --------------"
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
