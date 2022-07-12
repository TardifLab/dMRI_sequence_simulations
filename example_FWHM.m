% -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_example_FWHM-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
%
% Description: 
% -----------
% 
% Example code for simulating dMRI sequences and calculating 1-D PSF and 
% Full Width at Half Maximum (FWHM) in the phase encode (PE) direction
% for sequences with EPI, partial Fourier EPI (PF-EPI), and spiral trajectories.
% 
% toolbox/code requirements:
% -------------------------
% 
% for generating spiral trajectories Brian Hargreaves implementation is needed from
% here: mrsrl.stanford.edu/~brian/vdspiral/
% 
% Article: Feizollah and Tardif (2022)
% -------
%
% Sajjad Feizollah, July 2022
% -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-

clear
clc

% >>>>>>>>>> set sequence parameters <<<<<<<<<<

params.TR=5000; % repetition time (ms)
params.fov=0.256;    %Field of View (m)
params.G_max=73e-3; % maximum gradient amplitude for diffusion encoding (T/m)
params.RF_exc_dur=5.126; % RF excitation pulse duration (ms)
params.RF_refoc_dur=10.24;   %RF refocusing pulse duration (ms)

% >>>>>>>>>> set simulation parameters <<<<<<<<<<

params.res_max=0.6e-3; % maximum resolution for simulation in (m)
params.res_min=1.8e-3; % minimum resolution for simulation in (m)
params.res_steps=0.1e-3;   %resolution steps for simulation in (m)
params.N=4096;   % grid size for simulation

% >>>>>>>>>> trajectory and diffusion parameters for simulation <<<<<<<<<<

R=[2,3,4];  % acceleration factor
PF=[1,6/8]; % partial Fourier factor (PF=1 is full k-space sampling)
BW=1384;    % bandwidth-per-pixel (Hz)
b_value=2000*1e6;    % b-value (s/m^2)

% >>>>>>>>>> calculate FWHM in PE direction for EPI and PF-EPI <<<<<<<<<<

for n=1:length(b_value)
    for i=1:length(R)
        for j=1:length(PF)
            for k=1:length(BW)
                params.traj_type='ep';
                params.R=R(i);
                params.PF=PF(j);
                params.BWpp=BW(k);
                params.b_value=b_value(n);
                
                params.B0=3;
                params.tissue='WM';
                epi_wm_3T{i,j,k,n}=psf_FWHM_pipe(params);
                params.B0=3;
                params.tissue='GM';
                epi_gm_3T{i,j,k,n}=psf_FWHM_pipe(params);
                params.B0=7;
                params.tissue='WM';
                epi_wm_7T{i,j,k,n}=psf_FWHM_pipe(params);
                params.B0=7;
                params.tissue='GM';
                epi_gm_7T{i,j,k,n}=psf_FWHM_pipe(params);
            end
        end
    end
end

% >>>>>>>>>> calculate FWHM in PE direction for spiral <<<<<<<<<<

R=[4,5,6];  % change acceleration factor for spiral
params.BWpp=1e6; % change to total bandwidth that is sampling rate

for n=1:length(b_value)
    for i=1:length(R)
        params.traj_type='sp';
        params.R=R(i);
        params.PF=1;
        params.b_value=b_value(n);
        
        params.B0=3;
        params.tissue='WM';
        sp_wm_3T{n,i}=psf_FWHM_pipe(params);
        params.B0=3;
        params.tissue='GM';
        sp_gm_3T{n,i}=psf_FWHM_pipe(params);
        params.B0=7;
        params.tissue='WM';
        sp_wm_7T{n,i}=psf_FWHM_pipe(params);
        params.B0=7;
        params.tissue='GM';
        sp_gm_7T{n,i}=psf_FWHM_pipe(params);
    end
end

% >>>>>>>>>> plot results <<<<<<<<<<

plot_results(epi_wm_3T{:,:,:,:},sp_wm_3T{:,:})
disp('press any key....');pause;clc

plot_results(epi_gm_3T{:,:,:,:},sp_gm_3T{:,:})
disp('press any key....');pause;clc

plot_results(epi_wm_7T{:,:,:,:},sp_wm_7T{:,:})
disp('press any key....');pause;clc

plot_results(epi_gm_7T{:,:,:,:},sp_gm_7T{:,:})
