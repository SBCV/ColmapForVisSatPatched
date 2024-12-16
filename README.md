# Colmap For VisSat Patched
This repository uses ```git patch``` to implement [ColmapForVisSat](https://github.com/Kai-46/ColmapForVisSat). Since ```ColmapForVisSat``` is a full copy of [Colmap](https://github.com/colmap/colmap), it is difficult to maintain. By relying on ```git apply <patch>``` this repository offers a simpler approach to incorporate the latest changes of the original ```Colmap``` library.

## Compatibility

**In contrast to the original ColmapForVisSat library, this repository supports CUDA 11.**

## Apply a set of satellite specific patch files to the original Colmap repository
Define two (temporary) variables storing the repository locations on disk:
```
PathToColmapForVisSatPatched="path/to/ColmapForVisSatPatched"
PathToColmapToBePatched="path/to/ColmapToBePatched"
```
Clone the repositories:
```
git clone https://github.com/SBCV/ColmapForVisSatPatched.git $PathToColmapForVisSatPatched
git clone https://github.com/colmap/colmap.git $PathToColmapToBePatched
```
Checkout the Colmap version compatible to the current patch files with:
```
cd $PathToColmapToBePatched
# Current patch files are created for 6c3e002faf2359af37180fec868e7b3b790a4fec (2022-04-01 17:11:34 +0000)
git checkout 6c3e002faf2359af37180fec868e7b3b790a4fec
```
Ensure that `apply_patches.sh` has execute permissions (`ls -l $PathToColmapForVisSatPatched/apply_patches.sh`) - for example by running:
```
chmod +x $PathToColmapForVisSatPatched/apply_patches.sh
```
Finally, apply the satellite specific patches with:
```
$PathToColmapForVisSatPatched/apply_patches.sh $PathToColmapToBePatched
```
Note: Do NOT run `apply_patches.sh` with `sh $PathToColmapForVisSatPatched/apply_patches.sh` - this will not produce the required results! Do not worry about type warnings (e.g. ```warning: src/base/camera.cc has type 100644, expected 100755```).


## Build the patched Colmap repository
- Run ```sudo apt-get install libmetis-dev```
- If anaconda/miniconda is installed, make sure to run ```conda deactivate``` before running ```cmake```.
- Follow the [official install insctructions of Colmap for Linux](https://colmap.github.io/install.html#linux).

## For contributors/developers: Create a set of new patch files for the latest Colmap version
If you want to create patch files for a more recent Colmap version, you may want to use the following approach:

First define some (temporary) environment variables:
```
PathToColmapForVisSatPatched="/path/to/ColmapForVisSatPatched"
PathToColmapLatest="path/to/ColmapLatest"
```
Clone the repositories:
```
git clone https://github.com/SBCV/ColmapForVisSatPatched.git $PathToColmapForVisSatPatched
git clone https://github.com/colmap/colmap.git $PathToColmapLatest
cd $PathToColmapLatest
```
If desired checkout a specific commit - for example:
```
git checkout 31df46c6c82bbdcaddbca180bc220d2eab9a1b5e
```
Try to apply the patches (this will probably not succeed, but it will show for which files the application of the corresponding patch failed).
```
$PathToColmapForVisSatPatched/apply_patches.sh $PathToColmapLatest
```
Example error:
```
error: patch failed: src/base/cost_functions.h:267
error: src/base/cost_functions.h: patch does not apply
```

Use Github or [PatchViewer](https://megatops.github.io/PatchViewer/) to view the corresponding patch file (e.g. [src__base__cost_functions.h.patch](https://github.com/SBCV/ColmapForVisSatPatched/blob/main/patches/src__base__cost_functions.h.patch)) - it will highlight the required changes. Copy the desired changes (i.e. the green parts) to corresponding place in the source code in `$PathToColmapLatest`! (e.g. [cost_functions.h](https://github.com/colmap/colmap/blob/dev/src/base/cost_functions.h))

Open `$PathToColmapForVisSatPatched/create_patches.sh` and comment out all lines `git diff ...` for which the application of the patch worked in the previous run.

Run the modified `create_patches.sh` script. It will create a new set of patches in `$PathToColmapForVisSatPatched/patches` overwriting previously outdated patches.
```
$PathToColmapForVisSatPatched/create_patches.sh $PathToColmapLatest
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
