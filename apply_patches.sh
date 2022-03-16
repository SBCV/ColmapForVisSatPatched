#!/bin/bash

# This script expects the following parameter:
# 	the path to the colmap source directory wich will be modified using a set of patches 

if [ $# -lt 1 ] || [ $# -gt 1 ]; then
    echo "Script expects 1 parameter, but ${#} provided!" >&2
    echo "Usage: $0 <path_to_colmap_source>"
    exit 2
fi

export COLMAP_TARGET_DP=$1

# Go to the directory where the script is located
cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd
export SH_FILE_DP=$PWD
export PATCH_DP="${SH_FILE_DP}/patches"
export ADDITIONAL_DP="${SH_FILE_DP}/additional_files"

cd $COLMAP_TARGET_DP
export OPTIONS=""	#"--reject"
git apply $OPTIONS "${PATCH_DP}/.gitignore.patch"
git apply $OPTIONS "${PATCH_DP}/CMakeLists.txt.patch"
git apply $OPTIONS "${PATCH_DP}/README.md.patch"
git apply $OPTIONS "${PATCH_DP}/scripts__python__build.py.patch"
git apply $OPTIONS "${PATCH_DP}/src__base__camera.cc.patch"
git apply $OPTIONS "${PATCH_DP}/src__base__camera_models.h.patch"
git apply $OPTIONS "${PATCH_DP}/src__base__cost_functions.h.patch"
git apply $OPTIONS "${PATCH_DP}/src__base__database_cache.h.patch"
git apply $OPTIONS "${PATCH_DP}/src__base__reconstruction.cc.patch"
git apply $OPTIONS "${PATCH_DP}/src__base__reconstruction.h.patch"

git apply $OPTIONS "${PATCH_DP}/src__controllers__bundle_adjustment.cc.patch"
git apply $OPTIONS "${PATCH_DP}/src__ui__bundle_adjustment_widget.cc.patch"

git apply $OPTIONS "${PATCH_DP}/src__exe__colmap.cc.patch"
git apply $OPTIONS "${PATCH_DP}/src__exe__sfm.cc.patch"

git apply $OPTIONS "${PATCH_DP}/src__feature__sift.cc.patch"

git apply $OPTIONS "${PATCH_DP}/src__mvs__depth_map.cc.patch"
git apply $OPTIONS "${PATCH_DP}/src__mvs__depth_map.h.patch"
git apply $OPTIONS "${PATCH_DP}/src__mvs__fusion.cc.patch"
git apply $OPTIONS "${PATCH_DP}/src__mvs__fusion.h.patch"
git apply $OPTIONS "${PATCH_DP}/src__mvs__image.cc.patch"
git apply $OPTIONS "${PATCH_DP}/src__mvs__image.h.patch"
git apply $OPTIONS "${PATCH_DP}/src__mvs__model.cc.patch"
git apply $OPTIONS "${PATCH_DP}/src__mvs__model.h.patch"
git apply $OPTIONS "${PATCH_DP}/src__mvs__patch_match.cc.patch"
git apply $OPTIONS "${PATCH_DP}/src__mvs__patch_match.h.patch"
git apply $OPTIONS "${PATCH_DP}/src__mvs__patch_match_cuda.cu.patch"
git apply $OPTIONS "${PATCH_DP}/src__mvs__patch_match_cuda.h.patch"
git apply $OPTIONS "${PATCH_DP}/src__mvs__workspace.cc.patch"
git apply $OPTIONS "${PATCH_DP}/src__mvs__workspace.h.patch"

git apply $OPTIONS "${PATCH_DP}/src__optim__bundle_adjustment.cc.patch"
git apply $OPTIONS "${PATCH_DP}/src__optim__bundle_adjustment.h.patch"
git apply $OPTIONS "${PATCH_DP}/src__sfm__incremental_mapper.cc.patch"
git apply $OPTIONS "${PATCH_DP}/src__util__option_manager.cc.patch"

# Copy additional files
cp "${ADDITIONAL_DP}/install_without_sudo.sh" "${COLMAP_TARGET_DP}/install_without_sudo.sh"
mkdir "${COLMAP_TARGET_DP}/ubuntu_scripts"
cp "${ADDITIONAL_DP}/ubuntu1804_build_colmap.sh" "${COLMAP_TARGET_DP}/ubuntu_scripts/ubuntu1804_build_colmap.sh"
cp "${ADDITIONAL_DP}/ubuntu1804_install_colmap.sh" "${COLMAP_TARGET_DP}/ubuntu_scripts/ubuntu1804_install_colmap.sh"
cp "${ADDITIONAL_DP}/ubuntu1804_install_dependencies.sh" "${COLMAP_TARGET_DP}/ubuntu_scripts/ubuntu1804_install_dependencies.sh"
cp "${ADDITIONAL_DP}/ubuntu1804_make_eclipse.sh" "${COLMAP_TARGET_DP}/ubuntu_scripts/ubuntu1804_make_eclipse.sh"
