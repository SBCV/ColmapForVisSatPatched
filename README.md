# ColmapForVisSatPatched
This repository uses ```git patch``` to implement [ColmapForVisSat](https://github.com/Kai-46/ColmapForVisSat). Since ```ColmapForVisSat``` is a full copy of [Colmap](https://github.com/colmap/colmap), it is difficult to maintain. By relying on ```git apply <patch>``` this repository offers a simpler approach to incorporate the latest changes of the original ```Colmap``` library.

## Compatibility

**In contrast to the original ColmapForVisSat library, this repository supports CUDA 11.**

## Apply a set of patches to the original Colmap repository
```
git clone https://github.com/SBCV/ColmapForVisSatPatched.git /path/to/ColmapForVisSatPatched
git clone https://github.com/colmap/colmap path/to/ColmapToBePatched
cd path/to/ColmapToBePatched
# Current patch files are created for 31df46c6c82bbdcaddbca180bc220d2eab9a1b5e (Mar 5, 2022)
git checkout 31df46c6c82bbdcaddbca180bc220d2eab9a1b5e
/path/to/ColmapForVisSatPatched/apply_patches.sh path/to/ColmapToBePatched
```

Do not worry about type warnings (e.g. ```warning: src/base/camera.cc has type 100644, expected 100755```).


## Build patched Colmap repository
- Run ```sudo apt-get install libmetis-dev```
- If anaconda/miniconda is installed, make sure to run ```conda deactivate``` before running ```cmake```.
- Follow the [official install insctructions for linux](https://colmap.github.io/install.html#linux).

## Create a set of patches from a modified Colmap repository
```
git clone https://github.com/SBCV/ColmapForVisSatPatched.git /path/to/ColmapForVisSatPatched
git clone https://github.com/colmap/colmap path/to/ColmapWithModifications
cd path/to/ColmapWithModifications
git checkout 31df46c6c82bbdcaddbca180bc220d2eab9a1b5e
<make modifications>
/path/to/ColmapForVisSatPatched/create_patches.sh path/to/ColmapWithModifications
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
