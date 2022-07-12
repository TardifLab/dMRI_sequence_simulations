% -_-_-_-_-_-_-_-_-_-_-_-_-_-_-seq_sim_decay_generator-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
%
% Description: generates signal decay from time point vectors for a spin-echo sequence
%
% Input:
%
%     params:    structure with sequence parameters:
%     
%         params.time_acquisition: time vector of samples (ms) [Ntime,1]
%
%         params.T1:   T1 of tissue (ms)
%     
%         params.T2:   T2 of tissue (ms)
%     
%         params.T2s:  T2* of tissue (ms)
%     
%         params.TR:   sequnece repetition time in (ms)
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

function full_decay=seq_sim_decay_generator(params)

% >>>>>>>>>> calculate steady-state signal amplitude <<<<<<<<<<

Mss=(1-exp(-params.TR/params.T1));

% >>>>>>>>>> calculate exponential time constant and amplitude after refocusing pulse <<<<<<<<<<

amp_pre_ref=Mss*exp(-(params.TE/2)/params.T2s);
t_pre_ref=params.TE/2;
amp_post_ref=Mss*exp(-params.TE/params.T2);
t_post_ref=params.TE;
amp_rising=exp((t_post_ref*log(amp_pre_ref)-t_pre_ref*log(amp_post_ref))/(t_post_ref-t_pre_ref));
t_rising=t_pre_ref/(log(amp_pre_ref/amp_rising));

% >>>>>>>>>> find pre- and post-TE time points <<<<<<<<<<

time_pre_TE=params.time_acquisition(params.time_acquisition<params.TE);
time_post_TE=params.time_acquisition(params.time_acquisition>=params.TE);

% >>>>>>>>>> calculate signal decay for pre- and post-TE times <<<<<<<<<<

decay_pre_TE=amp_rising*exp(time_pre_TE./t_rising);
decay_post_TE=Mss*exp(-params.TE/params.T2)*exp(-(time_post_TE-params.TE)./params.T2s);

full_decay=[decay_pre_TE(:);decay_post_TE(:)];