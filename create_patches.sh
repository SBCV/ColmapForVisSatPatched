#!/bin/bash

# This script expects the following parameter:
# 	the path to a (MODIFIED) colmap source directory for wich a set of patches should be computed 

if [ $# -lt 1 ] || [ $# -gt 2 ]; then
    echo "Script expects 1 or 2 parameters, but ${#} provided!" >&2
    echo "Usage: $0 <path_to_MODIFIED_colmap_source> <overwrite_flag>"
    echo "The last parameter <overwrite_flag> is optional."
    exit 2
fi

original_dp=$PWD

modified_colmap_source_dp=$1
overwrite_patch_file=${2:-1}   # Set 1 as default parameter

echo "Reading colmap from: $modified_colmap_source_dp"

# Go to the directory where the script is located
cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd
sh_file_dp=$PWD
patch_dp="${sh_file_dp}/patches"

echo "Creating patch files in: $patch_dp"

cd $modified_colmap_source_dp
git branch

reset_file_if_only_index_changes() {
    local patch_fp=$1
    # Switch to the repository with the patch files, and check
    # if there are substantial changes in the patch file
    cd $sh_file_dp

    # shortstat_result=$(git diff --shortstat $patch_fp)
    numstat_result=$(git diff --numstat $patch_fp)

    # If numstat_result is empty, the file is up-to-date and there is nothing to restore.
    if [ -n "$numstat_result" ]; then
        read -r num_added_lines num_deleted_lines fn <<< "$numstat_result"

        if [ $num_added_lines == 1 ] && [ $num_deleted_lines == 1 ]; then
            local diff_output=$(git diff -- "$patch_fp")
            # printf "%s\n" "$diff_output"

            # Check for lines that start with "+index"" or "-index"
            local added_index_lines=$(echo "$diff_output" | grep '^+index')
            local removed_index_lines=$(echo "$diff_output" | grep '^-index')
            local num_added_index_lines=$(echo "$added_index_lines" | wc -l)
            local num_removed_index_lines=$(echo "$removed_index_lines" | wc -l)

            if [ $num_added_index_lines == 1 ] && [ $num_removed_index_lines == 1 ]; then
                # echo "Only index lines have changed in $patch_fp"
                git restore $patch_fp
            else
                echo "ERROR: SINGLE CHANGE (BUT NOT INDEX LINE) in $patch_fp"
                exit
            fi
        # else
        #     echo "Actual changes in $patch_fp"
        fi
    fi

    # Switch back to the previous directory (i.e. the colmap git repository)
    cd $modified_colmap_source_dp
}


create_patch() {
    local source_fp=$1
    local patch_fn=$2
    local patch_fp="$patch_dp/$patch_fn"
    if [ "$overwrite_patch_file" -eq 1 ] || [ ! -f "$patch_fp" ]; then
        git diff "$source_fp" > "$patch_fp"
        reset_file_if_only_index_changes $patch_fp
    fi
}

create_patch src/base/camera.cc "src__base__camera.cc.patch"
create_patch src/base/camera_models.h "src__base__camera_models.h.patch"
create_patch src/base/cost_functions.h "src__base__cost_functions.h.patch"
create_patch src/base/database_cache.h "src__base__database_cache.h.patch"
create_patch src/base/reconstruction.cc "src__base__reconstruction.cc.patch"
create_patch src/base/reconstruction.h "src__base__reconstruction.h.patch"

create_patch src/controllers/bundle_adjustment.cc "src__controllers__bundle_adjustment.cc.patch"
# Normalization has been moved from src/controllers/bundle_adjustment.cc to src/ui/bundle_adjustment_widget.cc
create_patch src/ui/bundle_adjustment_widget.cc "src__ui__bundle_adjustment_widget.cc.patch"

# src/base/colmap.cc has been reorganized into src/base/colmap.cc, src/base/sfm.cc, ...
create_patch src/exe/colmap.cc "src__exe__colmap.cc.patch"
create_patch src/exe/sfm.cc "src__exe__sfm.cc.patch"
create_patch src/exe/sfm.h "src__exe__sfm.h.patch"

create_patch src/feature/sift.cc "src__feature__sift.cc.patch"

create_patch src/mvs/depth_map.cc "src__mvs__depth_map.cc.patch"
create_patch src/mvs/depth_map.h "src__mvs__depth_map.h.patch"
create_patch src/mvs/fusion.cc "src__mvs__fusion.cc.patch"
create_patch src/mvs/fusion.h "src__mvs__fusion.h.patch"
create_patch src/mvs/image.cc "src__mvs__image.cc.patch"
create_patch src/mvs/image.h "src__mvs__image.h.patch"
# src/mvs/mat.h has no actual changes
create_patch src/mvs/model.cc "src__mvs__model.cc.patch"
create_patch src/mvs/model.h "src__mvs__model.h.patch"
create_patch src/mvs/patch_match.cc "src__mvs__patch_match.cc.patch"
create_patch src/mvs/patch_match.h "src__mvs__patch_match.h.patch"
create_patch src/mvs/patch_match_cuda.cu "src__mvs__patch_match_cuda.cu.patch"
create_patch src/mvs/patch_match_cuda.h "src__mvs__patch_match_cuda.h.patch"
create_patch src/mvs/workspace.h "src__mvs__workspace.h.patch"

create_patch src/optim/bundle_adjustment.cc "src__optim__bundle_adjustment.cc.patch"
create_patch src/optim/bundle_adjustment.h "src__optim__bundle_adjustment.h.patch"

create_patch src/sfm/incremental_mapper.cc "src__sfm__incremental_mapper.cc.patch"

create_patch src/util/option_manager.cc "src__util__option_manager.cc.patch"

cd $original_dp
