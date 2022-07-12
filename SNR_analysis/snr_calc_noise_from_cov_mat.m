% -_-_-_-_-_-_-_-_-_-_-_-_-_-_-snr_calc_noise_from_cov_mat-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
%
% Description:
% -----------
% 
% Generates correlated noise usking noise covariance matrix of coils.
%
% Inputs:
% ------
%
%    cov_mat: noise covariance matrix [Nnoise,Ncoil]
% 
%    dim: dimension of generated noise [Nk,Ncoils,Ncontrasnt,Nslice]
% 
% Outputs:
% -------
% 
%    cor_noise: generated correlated noise [Nk,Ncoils,Ncontrasnt,Nslice]
% 
% Article: Feizollah and Tardif (2022)
% -------
%
% Sajjad Feizollah, July 2022
% -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-

function cor_noise=snr_calc_noise_from_cov_mat(cov_mat,dim)

if(length(dim)<3)
    dim(3)=1;
    dim(4)=1;
end

cor_noise=zeros(dim);

for k=1:dim(3)
    for i=1:dim(4)
        uncor_noise=randn(dim(1),dim(2))+1i*randn(dim(1),dim(2));
        cor_noise(:,:,k,i)=(sqrt(cov_mat)*uncor_noise.').';
    end
end
