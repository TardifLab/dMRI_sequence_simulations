% -_-_-_-_-_-_-_-_-_-_-_-_-_-_-psf_specificity_sharpenning_pipe-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
%
% Description: 
% -----------
% 
% function for simulating dMRI sequences and calculating
% 2-D PSF. Specificity and sharpenning are measured using 2D PSFs:
% 
%                     |int(main lobe in a nominal voxel size)|
%       specificity= ------------------------------------------
%                                |int(side lobes)|
%
%                           |int(negative side lobes)|
%             sharpenning= ----------------------------
%                           |int(positive side lobes)| 
%
% Inputs:
% ------
%
%    params:	structure with sequence parameters:
%
%       params.traj_type:   type of trajectoy:
%                           - 'ep' for EPI
%                           - 'sp' for spiral
%
%       params.B0:	main magnetic field strength (B0) in (T):
%                   - 3
%                   - 7
%
%       params.tissue:	type of tissue:
%                       - 'WM' for white matter
%                       - 'GM' for grey matter
%
%       params.R:	acceleration factor
%
%       params.PF:	partial Fourier factor (PF=1 is full Fourier)
%
%       params.BWpp:	bandwidth-per-pixel in (Hz)
%
%       params.b_value:	b-value of diffusion encoding in (s/m^2)
%
%       params.G_max:	maximum gradient amplitude for diffusion gradients in (T/m)
%
%       params.RF_exc_dur:	duration of excitation RF pulse in (ms)
%
%       params.RF_refoc_dur:  duration of refocusing RF pulse in (ms)
%
%       params.TR:	sequence repetition time in (ms)
%
%       params.fov:	Field of View in (m)
%
% Outputs:
% -------
% 
%     results:  structure with calculated parameters and sequence
%              settings
% 
%        results.traj_type:	type of trajectoy
%
%        results.B0:	main magnetic field strength (params.B0) in (T)
%
%        results.tissue:	type of params.tissue
%
%        results.R:	acceleration factor
%
%        results.fov:	Field of View in (m)
% 
%        results.N:	grid size
% 
%        results.BWpp:  bandwidth-per-pixel used for generated trajectory in (Hz)
% 
%        results.Res:	vector of simulated resolutions (mm) [Nres,1]
% 
%        results.specificity:   calculated specificity as described [Nres,1]
% 
%        results.sharpenning:   calculated sharpenning as defiened [Nres,1]
% 
% 
%
% Article: Feizollah and Tardif (2022)
% -------
%
% Sajjad Feizollah, July 2022
% -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-

function results=psf_specificity_sharpenning_pipe(params)

n=1;
res=params.res_max;

while(res<=params.res_min+params.res_steps)
    
    % >>>>>>>>>> simulate sequences <<<<<<<<<<
    
    params.res=res;
    params=seq_sim_main(params);
    
    % >>>>>>>>>> calculates specificity and sharpenning <<<<<<<<<<
    
    params=psf_2D_IDFT_gpu(params);     
    [results.specificity(n),results.sharpenning(n)]=psf_2D_analysis(params);
    
    results.Res(n)=res*1000;
    n=n+1;
    res=res+params.res_steps;
end

results.tissue_type=params.tissue;
results.BWpp=params.BWpp;
results.fov=params.fov;
results.N=params.N;
results.R=params.R;
results.PF=params.PF;
results.B0=params.B0;
results.label=params.label;