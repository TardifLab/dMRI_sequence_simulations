% -_-_-_-_-_-_-_-_-_-_-_-_-_-_-snr_multi_replica_pipe-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
%
% Description:
% -----------
% 
% Gets raw data of a scan in ISMRMRD format, coil sensitivity maps, B0
% nonuniformity, and mask. Calculates noise covariance matrix, adds
% noise to the raw k-space data, and reconstructs multiple images. Results will be
% used in SNR calculation for multiple replica method (Robson et al., 2008).
%
% Requirements:
%
% Image reconstruction code is needed that can be found here:
% github.com/TardifLab/ESM_image_reconstruction
%
% Inputs:
% ------
%
%    data_adrs: location of ISMRMRD file that contains raw data, trajectory,
%               noise data and header
%
%    map_adrs:  location of a .mat file containing coil sensitivity map, B0
%               nonuniformity map, and mask for image recon
%
%    Nreplica: number of replicas
%
%    nIter: number of itterations for Conjugate Gradient (CG)
% 
% Outputs:
% -------
% 
%    im: reconstructed images [Nx,Ny,Nz,Naquisition,Nreplica]
% 
% Article: Feizollah and Tardif (2022)
% -------
%
% Sajjad Feizollah, July 2022
% -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-

function im=snr_multi_replica_pipe(data_adrs,map_adrs,Nreplica,nIter)

fprintf('Loading data...')
[kdata,kloc,header,noise]=cg_ismrmrd_sort(data_adrs);
fprintf('Finished\n')

N=header.hdr.encoding.reconSpace.matrixSize.x;

[b0_init,sens_init,mask_init,header.maps]=cg_load_maps(map_adrs);

[sens,b0,mask]=cg_maps_interpolate(b0_init,sens_init,mask_init,header);

mask=imresize(mask,[N,N]);
sens=imresize(sens,[N,N]);
b0=imresize(b0,[N,N]);

data.kloc=kloc;
data.header=header;
data.sens=sens;
data.b0=b0;
data.mask=mask;

for k=1:Nreplica
    disp("replica: "+num2str(k)+"/"+num2str(Nreplica));
    data.kdata=snr_add_noise(kdata,noise);
    tmp=cg_recon_main_gpu(data,nIter,false);
    im(:,:,:,:,k)=tmp(:,:,:,end,:);
end
