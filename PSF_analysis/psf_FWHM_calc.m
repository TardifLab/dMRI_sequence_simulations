% -_-_-_-_-_-_-_-_-_-_-_-_-_-_-psf_FWHM_calc-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
%
% Description: 
% -----------
% 
% calculates Full Width at Half Maximum (FWHM) of a PSF.
%
% Inputs:
% -----
% 
%     psf: 1-D PSF [N,1]
% 
%     axis: 1-D vector of axis [N,1]
% 
%     R:  acceleration factor
% 
% Outputs:
% -------
%       
%    FWHM: calculated FWHM
%
% Article: Feizollah and Tardif (2022)
% -------
% 
% Sajjad Feizollah, July 2022
% -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-

function FWHM=psf_FWHM_calc(psf,axis,R)

% >>>>>>>>>> normalize PSF and extract central peak <<<<<<<<<<

Ncenter=floor(length(psf)/2)+1;
psf_norm=psf(Ncenter-floor(Ncenter/R):Ncenter+floor(Ncenter/R));
psf_norm=real(psf_norm)/max(real(psf_norm));
axis=axis(Ncenter-floor(Ncenter/R):Ncenter+floor(Ncenter/R));

% >>>>>>>>>> calculate FWHM using 1-D interpolation <<<<<<<<<<

I=find((psf_norm>0.4)&(psf_norm<1));
FWHM=2*abs(interp1(psf_norm(I(1:length(I)/2)),axis(I(1:length(I)/2)),0.5));