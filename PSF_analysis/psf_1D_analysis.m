% -_-_-_-_-_-_-_-_-_-_-_-_-_-_-psf_1D_analysis-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
%
% Description: 
% -----------
% 
% Calculates PSF in phase-encode (PE) direction and measures FWHM as the 
% effective resolution.
%
% Inputs:
% -----
% 
%     params:    structure with sequence parameters:
%     
%         params.traj_type:   type of trajectoy:
%                             - 'ep' for EPI
%                             - 'sp' for spiral
%     
%         params.kloc: trajectory points in (rad/m)   [Nk,2]
% 
%         params.kdata: k-space samples   [Nk,1]
% 
%         params.kloc_PF:   trajectory points of PF part in (rad/m)  
%
%         params.N: grid size of image
% 
%         params.fov:  Field of View in (m)
% 
%         params.R:     acceleration factor
% 
% Outputs:
% -------
%       
%     FWHM: measured FWHM of PSF
%    
%     psf:  calculated PSF in PE direction [N,1]
% 
%     kloc_phase:   k-space points in PE direction in (rad/m) [Nk,1]
% 
%     kdata_phase:  k-space samples in PE direction [Nk,1]
% 
%     kloc_phase_PF:    trajectory points in PE direction for PF part in (rad/m) [Nk_PF,1]
% 
%     kdata_phase_PF: k-space samples in PE direction for PF part [Nk_PF,1]
%
% Article: Feizollah and Tardif (2022)
% -------
% 
% Sajjad Feizollah, July 2022
% -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-

function [FWHM,psf,kloc_phase,kdata_phase,kloc_phase_PF,kdata_phase_PF]=psf_1D_analysis(params)

% >>>>>>>>>> extract PE direction trajectory and k-space data points <<<<<<<<<<

index_phase_enc=psf_find_phase_encode(params.kloc,params.traj_type);
kloc_phase=params.kloc(index_phase_enc,2);
kdata_phase=params.kdata(index_phase_enc);
[kloc_phase,index_sort]=sort(kloc_phase);
kdata_phase=kdata_phase(index_sort);

% >>>>>>>>>> if PF trajecory exists fills out missing part using conjugate symetry feature <<<<<<<<<<

kloc_phase_PF=[];
kdata_phase_PF=[];
if(~isempty(params.kloc_PF))
    index_phase_enc_PF=psf_find_phase_encode(params.kloc_PF,params.traj_type);
    N_PF=length(index_phase_enc_PF);
    kloc_phase_PF=params.kloc_PF(index_phase_enc_PF,2);
    kdata_phase_PF=kdata_phase(N_PF:-1:1);
    kdata_phase=[kdata_phase;kdata_phase(N_PF:-1:1)];
    kloc_phase=[kloc_phase;sort(kloc_phase_PF)];
end

% >>>>>>>>>> calculate PSF using IDFT <<<<<<<<<<

psf=psf_1D_IDFT(kloc_phase,kdata_phase,params.N,params.fov);

% >>>>>>>>>> calculate FWHM <<<<<<<<<<

x=(-params.fov*1e3/2):(params.fov*1e3/params.N):(params.fov*1e3/2-params.fov*1e3/params.N);
FWHM=psf_FWHM_calc(real(psf),x,params.R);
