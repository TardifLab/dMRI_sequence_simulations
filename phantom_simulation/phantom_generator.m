% -_-_-_-_-_-_-_-_-_-_-_-_-_-_-phantom_generator-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
%
% Description:
% -----------
% Generates a digital brain phantom with WM, GM, and CFS
% compartments.
%
% Input:
% -----
%
%     N: matrix size for phantom
% 
% Output:
% ------
% 
%    GM:    grey matter image [N,N]
% 
%    WM:    white matter image [N,N]
% 
%    CSF:   CSF image [N,N]
% 
%    mask:  brain mask to use for recon [N,N]
% 
%
% Article: Feizollah and Tardif (2022)
% -------
%
% Sajjad Feizollah, July 2022
% -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-

function [GM,WM,CSF,mask]=phantom_generator(N)

load('Phantom','phan');

tmp=imresize(phan,[200,180]);
phan=zeros(250);
phan(21:220,41:220)=tmp;
phan=imresize(phan,[N,N]);
phan(phan<1)=0;

T1=double(phan);
T1(phan>100)=1200;
T1(phan>70&phan<=100)=2000;
T1(phan<=70&phan>0)=4400;

GM=logical(T1==2000);
WM=logical(T1==1200);
CSF=logical(T1==4400);

mask=GM|WM|CSF;
