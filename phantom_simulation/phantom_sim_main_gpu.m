% -_-_-_-_-_-_-_-_-_-_-_-_-_-_-phantom_sim_main_gpu-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
%
% Description:
% -----------
%
% Simulates data acquisition of a digital brain phantom with three WM, GM, 
% and CSF compartments. The digital phantom and coil sensitivity maps are 
% loaded from 'phantom.mat' and 'phantom_sens.mat'.
% 
% **Generating k-space data requires a GPU**
%
% Inputs:
% ------
%
%       N: phantom matrix size
%
%       kloc: trajectory points in (rad/m) [Nk,3]
%
%       time:  time vector of kloc samples in (ms) [Nk,1]
%
%       TR:   sequnece repetition time in (ms)
%
%       fov:  Field of View in (m)
% 
%       TE: echo time (ms)
%
% Outputs:
% -------
% 
%       kdata: k-space samples  [Nk,Ncoil]
%
%       sens:  coil sensitivity maps used for simulation [N,N,Ncoil]
%
%       mask:  mask for image recon  [N,N];
%
% Article: Feizollah and Tardif (2022)
% -------
%
% Sajjad Feizollah, July 2022
% -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-

function [kdata,sens,mask]=phantom_sim_main_gpu(kloc,time,TR,TE,N,fov)

% >>>>>>>>>> load WM, GM, and CSF <<<<<<<<<<

[GM,WM,CSF,mask]=phantom_generator(N);

load("phantom_sens.mat",'sens');
Ncoil=32;
sens=imresize(sens,[N,N]);
sens=reshape(sens,[N*N,Ncoil]);

if(length(size(kloc))<16)
    kloc_temp=zeros(length(kloc),16);
    kloc_temp(:,2:3)=kloc(:,1:2);
    kloc=kloc_temp;
end

Nk=length(kloc);
GM=gpuArray(single(GM));
WM=gpuArray(single(WM));
CSF=gpuArray(single(CSF));

% >>>>>>>>>> generate signal decay for tissues <<<<<<<<<<
% T1, T2, and T2* for GM, WM are set from:
% Cox and Gowland, 2010;
% Peters et al., 2007;
% Rooney et al., 2007;
% Wansapura et al., 1999

decay_signal_wm=phantom_signal_decay(TR,TE,1200,47,26.8,time);
decay_signal_gm=phantom_signal_decay(TR,TE,2000,47,33.2,time);
decay_signal_csf=phantom_signal_decay(TR,TE,4400,1000,1000,time);

decay_signal_wm=gpuArray(reshape(decay_signal_wm,[1,1,length(time)]));
decay_signal_gm=gpuArray(reshape(decay_signal_gm,[1,1,length(time)]));
decay_signal_csf=gpuArray(reshape(decay_signal_csf,[1,1,length(time)]));

[x,y,z]=meshgrid((-.5:1/N:.5-1/N)*fov,(-.5:1/N:.5-1/N)*fov,0);
h=gpuArray(sph_harmonics(x,-y,z).');

kloc=gpuArray(1i*kloc);

% >>>>>>>>>> find number of optimum processing blocks for GPU<<<<<<<<<<

max_numel=0.15e9;
if(N*N*Nk<=max_numel)
    L_block=[0,Nk];
    N_block=1;
else
    L_block=round(max_numel/N/N);
    N_block=floor(Nk/L_block)+1;
    L_block=[0,L_block*ones(1,N_block-1),rem(Nk,L_block)];
end

% >>>>>>>>>> generate k-space for all channels <<<<<<<<<<

kdata=[];
for k=1:N_block
    indx=((k-1)*L_block(k)+1:(k-1)*L_block(k)+L_block(k+1));
    img_wm=0.55*WM.*decay_signal_wm(1,1,indx);  % proton density of WM=0.55
    img_gm=0.85*GM.*decay_signal_gm(1,1,indx);  % proton density of GM=0.85
    img_csf=CSF.*decay_signal_csf(1,1,indx);    %proton density of CSF=1
    decay_img=img_wm+img_gm+img_csf;
    decay_img=reshape(decay_img,[N*N,length(indx)])';
    E=exp(kloc(indx,:)*h.');
    kdata_tmp=zeros(length(indx),Ncoil);
    for i=1:Ncoil
        kdata_tmp(:,i)=sum(E.*(sens(:,i).'.*decay_img),2);
    end
    kdata=[kdata;kdata_tmp];
end

kdata=gather(kdata/N);
sens=reshape(sens,[N,N,Ncoil]);
