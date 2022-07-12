% -_-_-_-_-_-_-_-_-_-_-_-_-_-_-example_multi_replica_recon-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
%
% Description: 
% -----------
% 
% Example code for multi replica method to calculate SNR of a scan.
% Sample data is available at:
% 
% Requirements:
% ------------
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

data_adrs='';
map_adrs='';

im_replicas=snr_multi_replica_pipe(data_adrs,map_adrs,100,8)
