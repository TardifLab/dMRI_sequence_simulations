% -_-_-_-_-_-_-_-_-_-_-_-_-_-_-phantom_sim_pipe-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
%
% Description:
% -----------
% 
% Simulates a dMRI sequence and acqusition of a digital brain phantom. Then
% reconstructs simulated k-space with the expanded signal model
% reconstruction.
% 
% Requirements:
% ------------
%
% Image reconstruction code is available at: 
% github.com/TardifLab/ESM_image_reconstruction
% 
% **Generating k-space data requires a GPU**
% 
% Inputs:
% ------
%
%    params:    structure with sequence parameters:
% 
%       params.R:         acceleration factor
%
%       params.PF:        partial Fourier factor (PF=1 is full Fourier)
%
%       params.BWpp:       bandwidth-per-pixel in (Hz)
%
%       params.TR:        sequence repetition time in (ms)
%
%       params.fov:        Field of View in (m)
% 
%       params.N:  matrix size for image reconstruction
% 
%       params.Nphantom:   oversampled grid size for phantom acquisition simulation
% 
% Outputs:
% -------
% 
%    im: reconstructed phantom image [N,N]
% 
% Article: Feizollah and Tardif (2022)
% -------
%
% Sajjad Feizollah, July 2022
% -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-

function im=phantom_sim_pipe(params)

% >>>>>>>>>> generate trajectory an time vector <<<<<<<<<<

if(params.traj_type=="sp")
    
    kloc=spiral_generator_Hargreaves(params.R,params.fov/params.N,params.fov);
    data.kloc=zeros(length(kloc),16);
    data.kloc(:,2:3)=kloc;
    time=params.TE+(0:1e-3:length(kloc)*1e-3)';
    data.header.hdr.encoding.trajectory="spiral";
elseif(params.traj_type=="ep")
    [kloc,TE_add,~,~,time]=EPI_generator(params.fov,params.N,params.R,params.PF,params.N*params.BWpp);
    time=time+params.TE-TE_add;
    data.kloc=zeros(length(kloc),16);
    data.kloc(:,2:3)=kloc;
    data.header.hdr.encoding.trajectory="EPI";
end

% >>>>>>>>>> generate phantom and simulate acquisition <<<<<<<<<<

[data.kdata,data.sens,data.mask]=phantom_sim_main(kloc,time,params.TR,params.TE,params.Nphantom,params.fov);

% >>>>>>>>>> prepare data form image recon of simulated phantom <<<<<<<<<<

data.header.hdr.encoding.reconSpace.matrixSize.x=params.N;
data.header.hdr.encoding.reconSpace.fieldOfView_mm.x=params.fov*1e3;
data.header.idx.slice=0;
data.header.position=[0;0;0];
data.header.time=time*1e-3;
data.mask=round(data.mask);
data.mask=imresize(data.mask,[params.N,params.N]);
data.b0=zeros(params.N);
data.b0=imresize(data.b0,[params.N,params.N]);
data.sens=imresize(data.sens,[params.N,params.N]);
data.sens=reshape(data.sens,[params.N,params.N,params.slice,32]);

im=cg_recon_main_gpu(data,14,true);

im=im(:,:,:,end);
