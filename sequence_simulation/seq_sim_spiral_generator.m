% -_-_-_-_-_-_-_-_-_-_-_-_-_-_-seq_sim_spiral_generator-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
%
% Description: 
% -----------
% 
% Generates spiral trajectory using Brian Hargreaves code
% available at: mrsrl.stanford.edu/~brian/vdspiral/
%
% Inputs:
% ------
% 
%     Nint: number of interleaves
%
%     res:  resolution in (m)
%
%     fov: Field of View in (m)
% 
% Outputs:
% -------
% 
%    kloc: trajectory points in (rad/m) [Nkloc,3]
% 
%    g: trajectory gradient waveforms in (T/m) [Nk,3]
% 
%    s: derivative of gradient waveforms (T/m/s) [Nk,3]
%       
% Article: Feizollah and Tardif (2022)
% -------
% 
% Sajjad Feizollah, July 2022
% -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-

function [kloc,g,s]=seq_sim_spiral_generator(Nint,res,fov)

smax = 160;	 % maximum gradient slew rate in (T/m/s)
gmax = 0.03;	 % maximum gradient amplitude in (T/m)
t = 1e-6;	 % trajectory sampling rate (s)

smax=smax*100;  % convert slew rate to (G/cm/s)
gmax=gmax*100;  % convert gradient amplitude to (G/cm)
fov = fov*100; 	% convert FOV to (cm)
res = res*1000; % convert resolution to (mm)
rmax = 5/res;   % maximum k-space range in (1/cm);

[kloc,g,s,~,~,~] = vds(smax,gmax,t,Nint,fov,rmax);

kloc=kloc*2*pi*100; % convert to (rad/m)
g=[real(g)',imag(g)',zeros(length(g),1)]/100; % convert to (T/m)
kloc=[real(kloc)',imag(kloc)'];
s=[real(s)',imag(s)',zeros(length(s),1)]/100; % convert to (T/m/s)
