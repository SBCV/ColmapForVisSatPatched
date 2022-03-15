#!/bin/bash

# This script expects the following parameter:
# 	the path to a (MODIFIED) colmap version for wich a set of patches should be computed 

if [ $# -lt 1 ] || [ $# -gt 1 ]; then
    echo "Script expects 1 parameter, but ${#} provided!" >&2
    echo "Usage: $0 <path_to_MODIFIED_colmap_source>"
    exit 2
fi

export ORIGINAL_DP=$PWD

export MODIFIED_COLMAP_SOURCE_DP=$1
echo "Reading colmap from: $MODIFIED_COLMAP_SOURCE_DP"

# Go to the directory where the script is located
cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd
export SH_FILE_DP=$PWD
export PATCH_DP="${SH_FILE_DP}/patches"

echo "Creating patch files in: $PATCH_DP"

cd $MODIFIED_COLMAP_SOURCE_DP

# Since the following files are not part of colmap, we copy these files (instead of using git diff).
#  - install_without_sudo.sh
#  - ubuntu_scripts/ubuntu1804_build_colmap.sh
#  - ubuntu_scripts/ubuntu1804_install_colmap.sh
#  - ubuntu_scripts/ubuntu1804_install_dependencies.sh
#  - ubuntu_scripts/ubuntu1804_make_eclipse.sh

git diff .gitignore > "${PATCH_DP}/.gitignore.patch"
git diff CMakeLists.txt > "${PATCH_DP}/CMakeLists.txt.patch"
git diff README.md > "${PATCH_DP}/README.md.patch"
git diff scripts/python/build.py > "${PATCH_DP}/scripts__python__build.py.patch"

git diff src/base/camera.cc > "${PATCH_DP}/src__base__camera.cc.patch"
git diff src/base/camera_models.h > "${PATCH_DP}/src__base__camera_models.h.patch"
git diff src/base/cost_functions.h > "${PATCH_DP}/src__base__cost_functions.h.patch"
git diff src/base/database_cache.h > "${PATCH_DP}/src__base__database_cache.h.patch"
git diff src/base/reconstruction.cc > "${PATCH_DP}/src__base__reconstruction.cc.patch"
git diff src/base/reconstruction.h > "${PATCH_DP}/src__base__reconstruction.h.patch"

git diff src/controllers/bundle_adjustment.cc > "${PATCH_DP}/src__controllers__bundle_adjustment.cc.patch"

# src/base/colmap.cc has been reorganized into src/base/colmap.cc, src/base/sfm.cc, ...
git diff src/exe/colmap.cc > "${PATCH_DP}/src__exe__colmap.cc.patch"
git diff src/exe/sfm.cc > "${PATCH_DP}/src__exe__sfm.cc.patch"

git diff src/feature/sift.cc > "${PATCH_DP}/src__feature__sift.cc.patch"

git diff src/mvs/depth_map.cc > "${PATCH_DP}/src__mvs__depth_map.cc.patch"
git diff src/mvs/depth_map.h > "${PATCH_DP}/src__mvs__depth_map.h.patch"
git diff src/mvs/fusion.cc > "${PATCH_DP}/src__mvs__fusion.cc.patch"
git diff src/mvs/fusion.h > "${PATCH_DP}/src__mvs__fusion.h.patch"
git diff src/mvs/image.cc > "${PATCH_DP}/src__mvs__image.cc.patch"
git diff src/mvs/image.h > "${PATCH_DP}/src__mvs__image.h.patch"
# src/mvs/mat.h has no actual changes
git diff src/mvs/model.cc > "${PATCH_DP}/src__mvs__model.cc.patch"
git diff src/mvs/model.h > "${PATCH_DP}/src__mvs__model.h.patch"
git diff src/mvs/patch_match.cc > "${PATCH_DP}/src__mvs__patch_match.cc.patch"
git diff src/mvs/patch_match.h > "${PATCH_DP}/src__mvs__patch_match.h.patch"
git diff src/mvs/patch_match_cuda.cu > "${PATCH_DP}/src__mvs__patch_match_cuda.cu.patch"
git diff src/mvs/patch_match_cuda.h > "${PATCH_DP}/src__mvs__patch_match_cuda.h.patch"
git diff src/mvs/workspace.cc > "${PATCH_DP}/src__mvs__workspace.cc.patch"
git diff src/mvs/workspace.h > "${PATCH_DP}/src__mvs__workspace.h.patch"

git diff src/optim/bundle_adjustment.cc > "${PATCH_DP}/src__optim__bundle_adjustment.cc.patch"
git diff src/optim/bundle_adjustment.h > "${PATCH_DP}/src__optim__bundle_adjustment.h.patch"

git diff src/sfm/incremental_mapper.cc > "${PATCH_DP}/src__sfm__incremental_mapper.cc.patch"

git diff src/util/option_manager.cc > "${PATCH_DP}/src__util__option_manager.cc.patch"

cd $ORIGINAL_DP