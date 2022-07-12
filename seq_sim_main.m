% -_-_-_-_-_-_-_-_-_-_-_-_-_-_-seq_sim_main-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
%
% Description:
% -----------
% 
% function for simulating spin-echo Stejskal Tanner diffusion sequences.
%
% Inputs:
% ------
%
%     params:    structure with sequence parameters:
%     
%         params.traj_type:   type of trajectoy:
%                             - 'ep' for EPI
%                             - 'sp' for spiral
% 
%         params.B0:        main magnetic field strength (B0) in (T):
%                           - 3
%                           - 7
%
%         params.tissue:     type of tissue:
%                            - 'WM' for white matter
%                            - 'GM' for grey matter
%     
%         params.R:     acceleration factor
%     
%         params.PF:        partial Fourier factor (0-1) (params.PF=1 is full Fourier)
%     
%         params.BWpp:       bandwidth-per-pixel in (Hz)
%     
%         params.b_value:      b-value of diffusion (s/m^2)
%     
%         params.G_max:       maximum gradient amplitude for diffusion gradients in (T/m).
%     
%         params.RF_exc_dur:   duration of excitation RF pulse in (ms)
%     
%         params.RF_refoc_dur:  duration of refocusing RF pulse in (ms)
%     
%         params.T1:   T1 of tissue (ms)
%     
%         params.T2:   T2 of tissue (ms)
%     
%         params.T2s:  T2* of tissue (ms)
%     
%         params.TR:   sequnece repetition time in (ms)
%     
%         params.fov:  Field of View in (m)
% 
%         params.res:  image resolution in (m)
% 
% Outputs:
% -------
% 
%    params:   adds outputs to params:
% 
%         params.kloc: trajectory points in (rad/m) [Nk,3]
% 
%         params.kdata: k-space samples  [Nk,1]
% 
%         params.readout_dur:   duration of readout in (ms)
% 
%         params.label: readout type (Spiral, EPI, PF-EPI)
% 
%         params.TE:    the echo time in (ms)
% 
%         params.time_acquisition:  time vector of kloc samples in (ms) [Nk,1]
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

function params=seq_sim_main(params)

% >>>>>>>>>> define relaxation times <<<<<<<<<<

% T1, T2, T2* in (ms) used from:

% Cox and Gowland, 2010
% Peters et al., 2007
% Rooney et al., 2007
% Wansapura et al., 1999

params.T1_7T_wm=1200;
params.T1_7T_gm=2000;
params.T1_3T_wm=800;
params.T1_3T_gm=1300;
params.T2_3T_wm=79.6;
params.T2_3T_gm=72;
params.T2_7T_wm=47;
params.T2_7T_gm=47;
params.T2s_7T_wm=26.8;
params.T2s_7T_gm=33.2;
params.T2s_3T_gm=66;
params.T2s_3T_wm=53.2;

% >>>>>>>>>> set relaxation times based on tissue and field strength <<<<<<<<<<

if(params.B0==3&&params.tissue=="WM")
    params.T1=params.T1_3T_wm;
    params.T2=params.T2_3T_wm;
    params.T2s=params.T2s_3T_wm;
elseif(params.B0==3&&params.tissue=="GM")
    params.T1=params.T1_3T_gm;
    params.T2=params.T2_3T_gm;
    params.T2s=params.T2s_3T_gm;
elseif(params.B0==7&&params.tissue=="WM")
    params.T1=params.T1_7T_wm;
    params.T2=params.T2_7T_wm;
    params.T2s=params.T2s_7T_wm;
elseif(params.B0==7&&params.tissue=="GM")
    params.T1=params.T1_7T_gm;
    params.T2=params.T2_7T_gm;
    params.T2s=params.T2s_7T_gm;
else
    error('relaxation parameters not defined....')
end
gamma=267.522e6;    % gyromagnetic ratio in (rad/s/T)

mat_size=ceil(params.fov/params.res);  % nominal matrix size
BW=params.BWpp*mat_size;    % total bandwidth

% >>>>>>>>>> generate spiral trajectory <<<<<<<<<<

if(params.traj_type=="sp")
        
    params.kloc=seq_sim_spiral_generator(params.R,params.res,params.fov);
    
    % >>>>>>>>>> calculate diffusion-encoding duration <<<<<<<<<<
    
    C=[2/3*gamma^2*params.G_max^2,gamma^2*params.G_max^2*(params.RF_refoc_dur*1e-3),0,-params.b_value];
    root=roots(C);
    pre_readout=ceil(root(find(real(root)>0))*1000+params.RF_refoc_dur/2)+ceil(params.RF_exc_dur/2);
    
    params.TE=2*pre_readout;
    sample_time=1e-3;
    params.time_acquisition=params.TE+(0:sample_time:length(params.kloc)*sample_time-sample_time)';
    
    params.readout_dur=length(params.kloc)*sample_time;
    params.label=strcat('Spiral');
    params.kloc_PF=[];
    
% >>>>>>>>>> generate EPI trajectory <<<<<<<<<<
    
elseif(params.traj_type=="ep")
    
    [params.kloc,params.time_acquisition,dur_to_TE,~,params.kloc_PF,~]=...
        seq_sim_EPI_generator(params.fov,ceil(params.fov/params.res),params.R,params.PF,BW);
    
    % >>>>>>>>>> calculate diffusion-encoding duration <<<<<<<<<<
            
    C=[2/3*gamma^2*params.G_max^2,gamma^2*params.G_max^2*(params.RF_refoc_dur*1e-3+dur_to_TE*1e-3),0,-params.b_value];
    root=roots(C);
    pre_readout=root(find(real(root)>0))*1000+params.RF_refoc_dur/2+ceil(params.RF_exc_dur/2);
    pre_readout_new=ceil(pre_readout)-(dur_to_TE-floor(dur_to_TE));
    params.TE=2*(dur_to_TE+pre_readout_new);
    
    acq_start_time=params.TE-dur_to_TE;
    
    params.label=strcat('EPI');
    if(params.PF~=1)
        params.label=strcat('PF-EPI');
    end
    params.readout_dur=params.time_acquisition(end);
    params.time_acquisition=params.time_acquisition+acq_start_time;
end