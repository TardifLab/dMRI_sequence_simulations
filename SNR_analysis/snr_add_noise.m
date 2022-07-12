% -_-_-_-_-_-_-_-_-_-_-_-_-_-_-snr_add_noise-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
%
% Description:
% -----------
% 
% Adds correlated noise with coil channels to raw k-space data using noise covariance matrix.
%
% Inputs:
% ------
%
%    kdata: k-space raw data [Nk,Ncoils,Ncontrast,Nslice]
% 
%    noise: measured noise during scan [Nnoise,Ncoil]
% 
% Outputs:
% -------
% 
%    kdata_new: k-space data with added noise [Nk,Ncoils,Ncontrast,Nslice]
% 
% Article: Feizollah and Tardif (2022)
% -------
%
% Sajjad Feizollah, July 2022
% -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-

function kdata_new=snr_add_noise(kdata,noise)

noise_cov_mat=snr_calc_noise_cov_mat(noise);

noise_new=snr_calc_noise_from_cov_mat(noise_cov_mat,size(kdata));

kdata_new=kdata+noise_new;
