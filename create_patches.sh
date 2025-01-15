#!/bin/bash

# This script expects the following parameter:
# 	the path to a (MODIFIED) colmap source directory for wich a set of patches should be computed 

if [ $# -lt 1 ] || [ $# -gt 3 ]; then
    echo "Script expects beteen 1 and 3 parameters, but ${#} provided!" >&2
    echo "Usage: $0 <path_to_MODIFIED_colmap_source> <overwrite_flag> <reset_index_changes>"
    echo "The last parameters <overwrite_flag> and <reset_index_changes> are optional."
    exit 2
fi

original_dp=$PWD

modified_colmap_source_dp=$1
overwrite_patch_file=${2:-1}   # Set 1 as default parameter
reset_index_changes=${3:-1}    # Set 1 as default parameter

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

    performed_git_restore=0

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
                performed_git_restore=1
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
    return $performed_git_restore
}


create_patch() {
    local source_fp=$1
    local patch_fn=$2
    local patch_fp="$patch_dp/$patch_fn"
    if [ "$overwrite_patch_file" -eq 1 ] || [ ! -f "$patch_fp" ]; then
        git diff "$source_fp" > "$patch_fp"
        if [ $reset_index_changes == 1 ]; then
            reset_file_if_only_index_changes $patch_fp
            # Get return value of reset_file_if_only_index_changes
            performed_git_restore=$?
        else
            performed_git_restore=0
        fi
        if [ $performed_git_restore == 0 ]; then
            echo "Running: git diff \"$source_fp\" > \"$patch_fp\""
        fi
    fi
}

encode_path_as_filename() {
    local filepath="$1"
    echo "${filepath//\//__}"
}

decode_filename_as_path() {
    local filename="$1"
    echo "${filename//__/\/}"
}

git_diff_files=$(git diff --name-only)

for file_path in $git_diff_files; do
  # Process each file (e.g., print its name or perform some action)
  echo "File with changes: $file_path"
  file_path_encoded=$(encode_path_as_filename $file_path)
  patch_file_name="${file_path_encoded}.patch"
  create_patch $file_path $patch_file_name
done

cd $original_dp
