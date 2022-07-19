# Simulation of diffusion MRI sequences and PSF analysis
This MATLAB code simulates dMRI sequences with echo planar imaging (EPI) and spiral trajectories and characterizes the resulting point spread function (PSF).
If it found useful for you please reference the following publication: Feizollah, S., Tardif, L. C. (2022). High-resolution diffusion-weighted imaging at 7 Tesla: single-shot readout trajectories and their impact on signal-to-noise ratio, spatial resolution and accuracy. [http://arxiv.org/abs/2207.07778](http://arxiv.org/abs/2207.07778)
## Requirements

* The spiral trajectories are generated using Brian Hargreaves’ code, which can be found here: [mrsrl.stanford.edu/~brian/vdspiral/](http://mrsrl.stanford.edu/~brian/vdspiral/)

* The 2D PSF analysis and image reconstruction requires a GPU.

* The images are reconstructed using the expanded signal model, which can be found here: [github.com/TardifLab/ESM_image_reconstruction](https://github.com/TardifLab/ESM_image_reconstruction)

### PSF analysis
#### Effective resolution
The effective resolution of single-shot readout trajectories is measured using the Full Width at Half Maximum (FWHM) in phase-encode direction (PE). Follow steps in ***example_FWHM.m*** to learn how to use the code for FWHM calculation.
#### Specificity and sharpening factor
The accuracy of spatial encoding is further characterized by measuring the specificity and sharpening factor of the 2D PSF. Follow ***example_PSF_2D.m*** for the definitions of specificity and sharpening factor.
### Phantom simulation
A digital brain phantom and coil sensitivity maps are available to simulate the image reconstruction pipeline and evaluate its impact on image quality. See ***example_phantom_sim.m*** for an example on how to use the code.
### SNR analysis
Implementation of the multiple replica method [(Robson et al., 2008)](https://doi.org/10.1002/mrm.21728) to measure SNR of MRI scans using raw k-space data and noise measurements. ***example_multiple_replice_recon.m*** includes the steps to reconstruct the multiple replicas.


**For any question about the code please contact: [sajjad.feizollah@mail.mcgill.ca](mailto:sajjad.feizollah@mail.mcgill.ca)**
