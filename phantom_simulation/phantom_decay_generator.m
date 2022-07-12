% -_-_-_-_-_-_-_-_-_-_-_-_-_-_-phantom_decay_generator-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
%
% Description:
% -----------
% Generates signal decay from time vector and tissue
% relaxation times for a spin-echo sequence.
%
% Input:
%
%     time: time vector of samples (ms) [Ntime,1]
%
%     T1:   T1 of tissue (ms)
%     
%     T2:   T2 of tissue (ms)
%     
%     T2s:  T2* of tissue (ms)
%     
%     TR:   sequnece repetition time in (ms)
% 
% Output:
% 
%    signal decay:     generated signal decay   [Ntime,1]
% 
%
% Article: Feizollah and Tardif (2022)
%
% Sajjad Feizollah, July 2022
% -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-

function full_decay=phantom_decay_generator(TR,TE,T1,T2,T2s,time)

% >>>>>>>>>> calculate steady-state signal amplitude <<<<<<<<<<

Mss=(1-exp(-TR/T1));

% >>>>>>>>>> calculate exponential time constant and amplitude after refocusing pulse <<<<<<<<<<

amp_pre_ref=Mss*exp(-(TE/2)/T2s);
t_pre_ref=TE/2;
amp_post_ref=Mss*exp(-TE/T2);
t_post_ref=TE;
amp_rising=exp((t_post_ref*log(amp_pre_ref)-t_pre_ref*log(amp_post_ref))/(t_post_ref-t_pre_ref));
t_rising=t_pre_ref/(log(amp_pre_ref/amp_rising));

% >>>>>>>>>> find pre- and post-TE time points <<<<<<<<<<

time_pre_TE=time_acquisition(time<TE);
time_post_TE=time_acquisition(time>=TE);

% >>>>>>>>>> calculate signal decay for pre- and post-TE times <<<<<<<<<<

decay_pre_TE=amp_rising*exp(time_pre_TE./t_rising);
decay_post_TE=Mss*exp(-TE/T2)*exp(-(time_post_TE-TE)./T2s);

full_decay=[decay_pre_TE(:);decay_post_TE(:)];
