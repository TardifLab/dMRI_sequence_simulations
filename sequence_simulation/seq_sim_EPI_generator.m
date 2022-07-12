% -_-_-_-_-_-_-_-_-_-_-_-_-_-_-seq_sim_EPI_generator-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
%
% Description: 
% -----------
% 
%   generates EPI trajectory with similar timing of trajectoy used in Siemens sequences
%
% Inputs:
% ------
% 
%     fov: Field of View in (m)
% 
%     N: matrix size
%
%     R: acceleration factor
% 
%     PF: partial Fourier factor (0-1) (PF=1 is full Fourier)
% 
%     BW: full bandwidth (N*bandwidth-per-pixel) in (Hz)
%
% 
% Outputs:
% -------
% 
%    kloc: trajectory points in (rad/m) [Nkloc,2]
% 
%    time_sample: time vector of trajectory points in (ms) [Nk,1]
% 
%    time_to_TE:  duration between start of readout to TE (ms)
% 
%    sampling_rate: sampling rate of trajectory in (ms)
% 
%    kloc_PF:   trajectory points of partial Fourier part in (rad/m) [Nk_PF,2]
% 
%    time_sample_PF: time vector of kloc_PF in (ms) [Nk_PF,1]
%       
% Article: Feizollah and Tardif (2022)
% -------
% 
% Sajjad Feizollah, July 2022
% -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-

function [kloc,time_sample,time_to_TE,sampling_rate,kloc_PF,time_sample_PF]...
    =seq_sim_EPI_generator(fov,N,R,PF,BW)

gamma=42.577478518e6;   % gyromagnetic ratio in (Hz/T)
res=fov/N;
kmax=1/res;
sampling_rate=1/BW; % sampling rate
Gmax=kmax/(gamma*N*sampling_rate);  % maximum gradient amplitude
ramp_time=Gmax/200*1e+3; %   ramp duration
sampling_rate=sampling_rate*1e3;

% >>>>>>>>>> generate samples in phase- and frequency-encode directions <<<<<<<<<<

traj_phase=0;
while(traj_phase(end)<1/res/2)
    traj_phase(1,end+1)=traj_phase(1,end)+R/fov;
end
traj_freq=0;
while(traj_freq(end)<1/res/2-1/fov)
    traj_freq(end+1,1)=traj_freq(end,1)+1/fov;
end
traj_phase=[-traj_phase(end:-1:1),traj_phase(2:end-1)];
traj_freq=[-traj_freq(end:-1:1,1);traj_freq(2:end,1)];
kloc=traj_freq+1i*traj_phase;
kloc(:,1:2:end)=kloc(end:-1:1,1:2:end);

if(PF~=1)
    kloc_PF=kloc(:,1:ceil((1-PF)*size(kloc,2))-1);
    kloc=kloc(:,ceil((1-PF)*size(kloc,2)):end);
else
    kloc_PF=[];
end

N_freq=size(kloc,1);
kloc=kloc(:)*2*pi;
kloc_PF=kloc_PF(:)*2*pi;
kloc=[-real(kloc),-imag(kloc)];
kloc_PF=[-real(kloc_PF),-imag(kloc_PF)];

% >>>>>>>>>> generate time points of trajectory <<<<<<<<<<

time_sample=zeros(length(kloc),1);
for k=2:length(kloc)
    time_sample(k)=time_sample(k-1)+sampling_rate;
    if(rem(k,N_freq)==1)
        time_sample(k)=time_sample(k)+ramp_time;
    end
end

time_sample_PF=zeros(length(kloc_PF),1);
for k=2:length(kloc_PF)
    time_sample_PF(k)=time_sample_PF(k-1)+sampling_rate;
    if(rem(k,N_freq)==1)
        time_sample_PF(k)=time_sample_PF(k)+ramp_time;
    end
end

% >>>>>>>>>> find duration from start of readout to TE <<<<<<<<<<

time_to_TE=time_sample(find((kloc(:,1)==0)&(kloc(:,2)==0)));