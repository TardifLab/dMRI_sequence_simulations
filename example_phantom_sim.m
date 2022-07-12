% -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_example_phantom_sim-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
%
% Description: 
% -----------
% 
% Example code for simulation of acuqisition and image reconstruction of a 
% digital brain phantom to show T2* effects on image quality.
% 
% Requirements:
% ------------
% 
% For generating spiral trajectories Brian Hargreaves implementation is needed from
% here: mrsrl.stanford.edu/~brian/vdspiral/
% 
% For image reconstruction, expanded signal model implementation is needed
% that can be found at: github.com/TardifLab/ESM_image_reconstruction
% 
% **Requires a GPU to simulate image acquisition**
%
% Article: Feizollah and Tardif (2022)
% -------
%
% Sajjad Feizollah, July 2022
% -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-

clear
clc

% >>>>>>>>>> set simulation parameters <<<<<<<<<<

params.TR=5000; % repetition time (ms)
params.fov=0.256;    % Field of View (m)
params.TE=50;   % echo time
params.slice=1; % number of slices
params.Nphantom=512; %phantom matrix size
params.N=256;   % image recon matrix size
params.res=params.fov/params.N; %image resolution

% >>>>>>>>>> trajectory and diffusion parameters for simulation <<<<<<<<<<

R=[2,3];  % acceleration factor
PF=[1,6/8]; % partial Fourier factor (PF=1 is full k-space sampling)
BW=1384;    % bandwidth-per-pixel (Hz)

% >>>>>>>>>> calculate FWHM in PE direction for EPI and PF-EPI <<<<<<<<<<

for i=1:length(R)
    for j=1:length(PF)
        for k=1:length(BW)
            params.traj_type='ep';
            params.R=R(i);
            params.PF=PF(j);
            params.BWpp=BW(k);
            params.b_value=b_value(n);
            epi_wm_7T(:,:,i,j,k)=phantom_sim_pipe(params);
        end
    end
end

% >>>>>>>>>> calculate FWHM in PE direction for spiral <<<<<<<<<<

R=[4,5];  % change acceleration factor for spiral
params.BWpp=1e6; % change to total bandwidth that is sampling rate

for i=1:length(R)
    params.traj_type='sp';
    params.R=R(i);
    params.PF=1;
    params.b_value=b_value(n);
    sp_wm_7T(:,:,i)=phantom_sim_pipe(params);
end
