% -_-_-_-_-_-_-_-_-_-_-_-_-_-_-psf_2D_IDFT_gpu-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
%
% Description: 
% -----------
% 
% Calculates 2D inverse discrete Fourier transform (IDFT) using GPU to reconstruct 2D PSF.
% 
%   **IMPORTANT: max_numel is selected based on GPU memory to
%   balance between maximum number of matrix size and load on a GPU. It is
%   different for every GPU, so please modify to achieve maximum
%   performance. It is when the maximum power is drawn by the GPU. The value here
%   tested for RTX3090 and Tesla V100.**
%
% Inputs:
% ------
%
%    params:    structure with sequence parameters:
%
%       params.traj_type:   type of trajectoy:
%                          - 'ep' for EPI
%                          - 'sp' for spiral
% 
%       params.kloc: trajectory points in (rad/m)   [Nk,2]
% 
%       params.kdata: k-space samples   [Nk,1]
%
%       params.fov:        Field of View in (m)
% 
%       params.N:   grid size
%
% Outputs:
% -------
% 
%   adds calculated PSF to params:
% 
%       params.psf: reconstructed PSF [N,N]
% 
%
% Article: Feizollah and Tardif (2022)
% -------
%
% Sajjad Feizollah, July 2022
% -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-

function params=psf_2D_IDFT_gpu(params)

max_numel=0.15e9;   % optimum number of matrix size for GPU

% >>>>>>>>>> prepare data for recon <<<<<<<<<<

if(params.traj_type=="sp")
    dcf=cg_dcf_spiral(params.kloc)/params.N/params.N;
else
    dcf=ones(length(params.kloc),1)/params.N/params.N;
end

Nk=length(params.kloc);
kdata=gpuArray(dcf.*params.kdata/params.N/params.N);
kloc=gpuArray(-1i*params.kloc.');

[x,y,z]=meshgrid((-.5:1/params.N:.5-1/params.N)*params.fov,...
    (-.5:1/params.N:.5-1/params.N)*params.fov,0);

h=gpuArray(sph_harmonics(x,-y,z).');
h=h(:,2:3);

% >>>>>>>>>> find number of multiplication blocks <<<<<<<<<<

if(params.N*params.N*Nk<=max_numel)
    L_block=[0,Nk];
    N_block=1;
else
    L_block=round(max_numel/params.N/params.N);
    N_block=floor(Nk/L_block)+1;
    L_block=[0,L_block*ones(1,N_block-1),rem(Nk,L_block)];
end

% >>>>>>>>>> calculates IDFT <<<<<<<<<<

psf=gpuArray(zeros(params.N*params.N,1));
for k=1:N_block
    indx=((k-1)*L_block(k)+1:(k-1)*L_block(k)+L_block(k+1));
    EH=exp(h*kloc(:,indx));
    im_temp=EH*kdata(indx,:);
    psf=psf+im_temp;
end
psf=reshape(psf,[params.N params.N]);
params.psf=gather(psf);
