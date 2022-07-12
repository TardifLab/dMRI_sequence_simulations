% -_-_-_-_-_-_-_-_-_-_-_-_-_-_-psf_FWHM_pipe-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
%
% Description: 
% -----------
% 
% Function for simulating dMRI sequences and calculating
% 1-D PSF and Full Width at Half Maximum (FWHM) in the phase encode
% direction. Readout trajectory can be EPI, partial Fourier (PF) EPI and spiral.
%
% Inputs:
% ------
%
%    params:    structure with sequence parameters:
%
%       params.traj_type:   type of trajectoy:
%                          - 'ep' for EPI
%                          - 'sp' for spiral
%
%       params.B0:        main magnetic field strength (B0) in (T):
%                           - 3
%                           - 7
%
%       params.tissue:     type of tissue:
%                          - 'WM' for white matter
%                          - 'GM' for grey matter
%
%       params.R:         acceleration factor
%
%       params.PF:        partial Fourier factor (PF=1 is full Fourier)
%
%       params.BWpp:       bandwidth-per-pixel in (Hz)
%
%       params.b_value:      b-value of diffusion encoding in (s/m^2)
%
%       params.G_max:       maximum gradient amplitude for diffusion gradients in (T/m)
%
%       params.RF_exc_dur:   duration of excitation RF pulse in (ms)
%
%       params.RF_refoc_dur:  duration of refocusing RF pulse in (ms)
%
%       params.TR:        sequence repetition time in (ms)
%
%       params.fov:        Field of View in (m)
%
% Outputs:
% -------
% 
%     results:  structure with calculated parameters and sequence
%              settings
% 
%        results.traj_type:   type of trajectoy:
%                          - 'ep' for EPI
%                          - 'sp' for spiral
%
%        results.B0:        main magnetic field strength (params.B0) in (T):
%                           - 3
%                           - 7
%
%        results.tissue:     type of params.tissue:
%                          - 'WM' for white matter
%                          - 'GM' for grey matter
%
%        results.R:         acceleration factor
%
%        results.PSF:       PSF of a single resolution [N,1]
%
%        results.fov:        Field of View in (m)
% 
%        results.N:    grid size
% 
%        results.TE:    the echo time vector (ms)
% 
%        results.Res:    vector of simulated resolutions (mm) [Nres,1]
% 
%        results.FWHM:   FWHMs for simulated PSFs [Nres,1]
% 
%        results.readout_dur:    readout duration for trajectories (ms) [Nres,1]
% 
%        results.kloc_phase: trajectory points in PE directions (rad/m) [Nk,1]
% 
%        results.kloc_phase_PF: partial Fourier part of trajectory (rad/m)  [Nk,1]
% 
%        results.kdata_phase: k-space data in the PE direction  [Nk,1]
% 
%        results.kdata_phase_PF:  k-space data of partial Fourier part of trajectory  [Nk,1]
% 
%
% Article: Feizollah and Tardif (2022)
% -------
%
% Sajjad Feizollah, July 2022
% -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-

function results=psf_FWHM_pipe(params)

n=1;
res=params.res_max;

while(res<=params.res_min+params.res_steps)
    
    % >>>>>>>>>> simulate sequences <<<<<<<<<<
    
    params.res=res;
    params=seq_sim_main(params);
    
    % >>>>>>>>>> generate k-space samples <<<<<<<<<<

    params.kdata=seq_sim_decay_generator(params);

    % >>>>>>>>>> calculate PSF and FWHM <<<<<<<<<<
    
    [results.FWHM(n),results.psf(:,n),kloc_phase,kdata_phase,kloc_phase_PF,kdata_phase_PF]=...
        psf_1D_analysis(params);
    
    % >>>>>>>>>> save resutls in results <<<<<<<<<<
    
    results.Res(n)=res*1000;
    results.TE(n)=params.TE;
    results.mat_size(n)=ceil(params.fov/params.res);
    results.readout_dur(n)=params.readout_dur;
    
    % >>>>>>>>>> save kloc and kdata for res=1mm for visualization <<<<<<<<<<
    
    if(~(logical(round(100000*(res-0.001)))))
        results.kdata_phase=kdata_phase;
        results.kloc_phase=kloc_phase;
        results.kloc_phase_PF=kloc_phase_PF;
        results.kdata_phase_PF=kdata_phase_PF;
        results.PSF=results.psf(:,n);
    end
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
