% -_-_-_-_-_-_-_-_-_-_-_-_-_-_-snr_calc_noise_cov_mat-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
%
% Description:
% -----------
% 
% Calculates noise covariance matrix from measured noise during a scan.
%
% Inputs:
% ------
%
%    noise: measured noise during scan [Nnoise,Ncoil]
% 
% Outputs:
% -------
% 
%    cov_mat: noise covariance matrix [Ncoils,Ncoils]
% 
% Article: Feizollah and Tardif (2022)
% -------
%
% Sajjad Feizollah, July 2022
% -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-

function cov_mat=snr_calc_noise_cov_mat(noise)

noise=reshape(noise,[size(noise,1)*size(noise,2),size(noise,3)]);

N=length(noise);

cov_mat=noise.'*conj(noise)*(1/2/N);