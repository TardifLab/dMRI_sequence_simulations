% -_-_-_-_-_-_-_-_-_-_-_-_-_-_-psf_1D_IDFT-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
%
% Description: 
% -----------
% 
% Calculates 1-D inverse discrete Fourier transform using explicit matrix
% multiplication.
%
% Inputs:
% -----
% 
%     kloc: trajectory points in (rad/m) [Nkloc,2]
% 
%     kdata: k-space samples at kloc points [Nkloc,1]
% 
%     N:    grid size
% 
%     fov:   Field of View in (m)
% 
% Outputs:
% -------
%       
%    I: calculated inverse discrete Fourier transform of kdata [N,1]
%
% Article: Feizollah and Tardif (2022)
% -------
% 
% Sajjad Feizollah, July 2022
% -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-

function I=psf_1D_IDFT(kloc,kdata,N,fov)

kdata=kdata/length(kloc);
kloc=1i*kloc.';

x=fov*(-.5:1/N:.5-1/N);

EH=exp(x(:)*kloc);
I=EH*kdata;
