# ColmapForVisSat Patches
This repository uses ```git patch``` to implement [ColmapForVisSat](https://github.com/Kai-46/ColmapForVisSat).

Since ```ColmapForVisSat``` is a full copy of [Colmap](https://github.com/colmap/colmap), it is difficult to maintain. By relying on ```git apply <patch>``` this repository offers a simpler approach to incorporate the latest changes of the original ```Colmap``` library.

Different ```patched Colmap``` versions (mimicking ```ColmapForVisSat```) can be found [here](https://github.com/SBCV/colmap) - check the individual branches.

## Compatibility

**In contrast to the original ColmapForVisSat library, this repository supports CUDA 11.**

## Apply a set of satellite specific patch files to the original Colmap repository
Define two (temporary) variables storing the repository locations on disk:
```
PathToColmapForVisSatPatches="path/to/ColmapForVisSatPatches"
PathToColmapToBePatched="path/to/ColmapToBePatched"
```
Clone the repositories:
```
git clone https://github.com/SBCV/ColmapForVisSatPatches.git $PathToColmapForVisSatPatches
git clone https://github.com/colmap/colmap.git $PathToColmapToBePatched
```
Ensure that `apply_patches.sh` has execute permissions (`ls -l $PathToColmapForVisSatPatches/apply_patches.sh`). For example, by running:
```
chmod +x $PathToColmapForVisSatPatches/apply_patches.sh
```

Before you apply the patches, ensure that the Colmap repository is up-to-date and the `main` branch is active. (Note: the `apply_patches.sh` script will add new branches in the `Colmap` repository as needed).
```
cd $PathToColmapToBePatched
git reset --hard HEAD
git switch main
git pull
```
Finally, apply the satellite specific patches with the following command. Possible values for `<modes>` are `reject` and `3way`.
```
$PathToColmapForVisSatPatches/apply_patches.sh <mode> $PathToColmapToBePatched <colmap-commit-hash>
```
For instance:
```
# Current patch files are created for d3c8d5d457569ff93804a61d1be45f18e5b43d27 (2023-02-18 08:39:04 +0000)
$PathToColmapForVisSatPatches/apply_patches.sh reject $PathToColmapToBePatched d3c8d5d457569ff93804a61d1be45f18e5b43d27
```
Note: Do NOT run `apply_patches.sh` with `sh $PathToColmapForVisSatPatches/apply_patches.sh` - this will not produce the required results! Do not worry about type warnings (e.g. ```warning: src/base/camera.cc has type 100644, expected 100755```).


## Build the patched Colmap repository
- Run ```sudo apt-get install libmetis-dev```
- If anaconda/miniconda is installed, make sure to run ```conda deactivate``` before running ```cmake```.
- Follow the [official install insctructions of Colmap for Linux](https://colmap.github.io/install.html#linux).

## For contributors/developers: Create a set of new patch files for the latest Colmap version
If you want to create patch files for a more recent Colmap version, you may want to use the following approach:

First define some (temporary) environment variables:
```
PathToColmapForVisSatPatches="/path/to/ColmapForVisSatPatches"
PathToColmapLatest="path/to/ColmapLatest"
```
Clone the repositories:
```
git clone https://github.com/SBCV/ColmapForVisSatPatches.git $PathToColmapForVisSatPatches
git clone https://github.com/colmap/colmap.git $PathToColmapLatest
cd $PathToColmapLatest
```
If desired checkout a specific commit - for example:
```
git checkout 31df46c6c82bbdcaddbca180bc220d2eab9a1b5e
```
Try to apply the patches (this will probably not succeed, but it will show for which files the application of the corresponding patch failed).
```
$PathToColmapForVisSatPatches/apply_patches.sh $PathToColmapLatest
```
Example error:
```
error: patch failed: src/base/cost_functions.h:267
error: src/base/cost_functions.h: patch does not apply
```

Use Github or [PatchViewer](https://megatops.github.io/PatchViewer/) to view the corresponding patch file (e.g. [src__base__cost_functions.h.patch](https://github.com/SBCV/ColmapForVisSatPatches/blob/main/patches/src__base__cost_functions.h.patch)) - it will highlight the required changes. Copy the desired changes (i.e. the green parts) to corresponding place in the source code in `$PathToColmapLatest`! (e.g. [cost_functions.h](https://github.com/colmap/colmap/blob/dev/src/base/cost_functions.h))

Open `$PathToColmapForVisSatPatches/create_patches.sh` and comment out all lines `git diff ...` for which the application of the patch worked in the previous run.

Run the modified `create_patches.sh` script. It will create a new set of patches in `$PathToColmapForVisSatPatches/patches` overwriting previously outdated patches.
```
$PathToColmapForVisSatPatches/create_patches.sh $PathToColmapLatest
```

## For contributors/developers: Handle rejected hunks
See [this link](https://stackoverflow.com/questions/17879746/how-do-i-apply-rejected-hunks-after-fixing-them/26810251#26810251) for more information to apply rejected hunks.

#### Option 1

Run the apply script with `git_apply --reject` to obtain a set of reject files with an overview of the conflicting hunks. 

#### Option 2 (Recommended)

Use the apply script with the `git_apply --3way` to write conflict markers into the affected files. For each conflicting hunk the script adds the code from the file to be patched between `<<<<<<< ours` and `=======`, and the code from the patch file between `=======` and `>>>>>>> theirs`. IMPORTANT: because 3-way merging uses a common base file for merging, the content between `=======` and `>>>>>>> theirs` MIGHT DIFFER from the actual hunk in the patch file (for example, this part might contain also context lines of the original hunk). With the conflict markers one can use the 3-way view of `VSCode` or `Meld` to merge the results. 

##### Option 2a: `VSCode` (Recommended)

In `VSCode` open the file with the conflict markers, and click on the bottom right on `Resolve in Merge Editor`. In the `Merge Editor` the top left pane (`incomming`) represents the content of the `patch` file and the top right (`current`) represents the file that should be patched (i.e. the current commit of the vanilla colmap repository). The bottom pane shows the current state of the merged result. Click on the toolbar of the bottom pane on `X Conflicts Remaining` to jump to the next conflict (relative to the current selected line). Important: non-matching hunk contexts ARE SHOWN AS SEPARATE conflicts. This is a huge advantage compared to the plain conflict markers and to the visualization in `meld`.

##### Option 2b: `meld`

In case of `meld`, start `meld`, click on `version control view` and navigate to the `colmap` repository and select the conflicting file. The `remote` file (left side) corresponds to the `patch` and the `base` file (right side) corresponds to changes of the file that should be patched.  

## For contributors/developers: Create a Colmap branch
```
cd $PathToColmapLatest
git switch -c vissat_<patches-commit-hash>
```

## Non-trivial conversion notes

### Inconsistencies
- ```src/base/reconstruction.cc```  -->  ```Reconstruction::Normalize()``` -->  ```if (translation_applied && scale_applied) {```
  - add
    - ```const Eigen::Vector3d mean_coord = std::get<2>(bound);```
    - ```const Eigen::Vector3d translation = mean_coord;```

- ```src/controllers/bundle_adjustment.cc``` --> ```void BundleAdjustmentController::Run() {``` -->
  - can not uncomment ```reconstruction_->Normalize();```, since line does not exist.
  - => uncomment ```reconstruction_->Normalize();``` in ```src/ui/bundle_adjustment_widget.cc```
  - keep ```reconstruction_->Normalize();``` in ```src/sfm/incremental_mapper.cc```, since these are not touched in the adapted colmap version

### Obsolete ? (TODO)
```
- src/base/reconstruction.cc  -->  void Reconstruction::WriteCamerasText() -->  file << std::setprecision(PRECISION);
- src/base/reconstruction.cc  -->  void Reconstruction::WriteCamerasText() -->  line << std::setprecision(PRECISION);
- src/base/reconstruction.cc  -->  void Reconstruction::WriteImagesText() -->  file << std::setprecision(PRECISION);
- src/base/reconstruction.cc  -->  void Reconstruction::WriteImagesText() -->  line << std::setprecision(PRECISION);
- src/base/reconstruction.cc  -->  void Reconstruction::WritePoints3DText() -->  file << std::setprecision(PRECISION);
- src/base/reconstruction.cc  -->  void Reconstruction::WritePoints3DText() -->  line << std::setprecision(PRECISION);
- src/mvs/math.h
```

### Questionable Changes (TODO)
- ```src/mvs/patch_match_cuda.cu``` --> Deleted ```return``` in line 181/385
