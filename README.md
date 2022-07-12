# Simulation of diffusion MRI sequences and PSF analysis
This MATLAB code simulates dMRI sequences with EPI and spiral trajectories and characterizes PSF to measure image quality.
## Requirements

* To generate spiral trajectories, Brian Hargreaves implementation is needed which can be found here: [mrsrl.stanford.edu/~brian/vdspiral/](http://mrsrl.stanford.edu/~brian/vdspiral/)

* 2D PSF analysis and image reconstruction requires a GPU.

* For image reconstruction, expanded signal model implementation is needed that can be found here: [github.com/TardifLab/ESM_image_reconstruction](https://github.com/TardifLab/ESM_image_reconstruction)

### PSF analysis
#### Effective resolution
Impacts of single-shot readout trajectories on spatial resolution is measured using Full Width at Half Maximum (FWHM) calculated in phase-encode direction (PE). Follow steps in ***example_FWHM.m*** to learn how to use the code for FWHM calculation.
#### Specificity and sharpening factor
Accuracy of dMRI images is measured by characterizing 2D PSF of a sequence. Follow ***example_PSF_2D.m*** for definition of specificity and sharpening factor. GPU is needed for using this code.
### Phantom simulation
A brain phantom and coil sensitivity map are available to simulate full image reconstruction pipeline on image quality. ***example_phantom_sim.m*** shows how to use the code. GPU is needed for using this code.
### SNR analysis
Implementation of multiple replica method (Robson et al., 2008) to measure SNR of MRI scans. ***example_multiple_replice_recon.m*** includes steps to reconstruct multiple replicas. GPU is needed for image reconstruction.


**For any question about the code please contact: [sajjad.feizollah@mail.mcgill.ca](mailto:sajjad.feizollah@mail.mcgill.ca)**
