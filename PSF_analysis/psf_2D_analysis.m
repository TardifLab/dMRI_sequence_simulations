% -_-_-_-_-_-_-_-_-_-_-_-_-_-_-psf_2D_analysis-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
%
% Description:
% -----------
%
% Calculates specificity and sharpening of PSF defiened as:
%
%                     |int(main lobe in a nominal voxel size)|
%       specificity= ------------------------------------------
%                                |int(side lobes)|
%
%                           |int(negative side lobes)|
%             sharpening= ----------------------------
%                           |int(positive side lobes)|
%
% Inputs:
% ------
%
%    params:    structure with sequence parameters:
%
%       param.psf:  2-D PSF [N,N]
% 
%       param.N:    grid size
% 
%       params.R:         acceleration factor
%
%       params.fov:        Field of View in (m)
%
% Outputs:
% -------
%
%   specificity: specificity as defined
%
%   sharpening: sharpening as defiend
%
%
% Article: Feizollah and Tardif (2022)
% -------
%
% Sajjad Feizollah, July 2022
% -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-

function [specificity,sharpening]= psf_2D_analysis(params)

fov=params.fov*1e3;
res=params.res*1e3;

start_idx=ceil(params.N/2-params.N/params.R/2);
end_idx=ceil(params.N/2+params.N/params.R/2);

axis=(-fov/2):(fov/params.N):(fov/2-fov/params.N);

psf=params.psf(start_idx:end_idx,start_idx:end_idx);
psf=psf./max(abs(psf(:)));
x_new=axis(start_idx:end_idx);
[x,y]=meshgrid(x_new,x_new);

axis_window=-round(fov/res/params.R/4)*res-res/2:res/64:round(fov/res/params.R/4)*res+res/2;
[X,Y]=meshgrid(axis_window,axis_window);
psf_interp=interp2(x,y,psf,X,Y,'spline').';

indx_center=find(round(axis_window,2)==round(res/2,2)|round(axis_window,2)==-round(res/2,2));
nom_main_lobe=psf_interp;
nom_main_lobe(:,indx_center(2):end)=0;
nom_main_lobe(:,1:indx_center(1))=0;
nom_main_lobe(indx_center(2):end,:)=0;
nom_main_lobe(1:indx_center(1),:)=0;

nom_side_lobe=psf_interp;
nom_side_lobe(indx_center(1):indx_center(2),indx_center(1):indx_center(2))=0;
int_nom_main_lobe=abs(sum(nom_main_lobe(:)))*(Y(2)-Y(1));
int_nom_side_lobe=abs(sum(nom_side_lobe(:)))*(Y(2)-Y(1));

int_nom_side_lobe_neg=abs(sum(nom_side_lobe(nom_side_lobe<0)))*(Y(2)-Y(1));
int_nom_side_lobe_pos=abs(sum(nom_side_lobe(nom_side_lobe>=0)))*(Y(2)-Y(1));


specificity=int_nom_main_lobe./int_nom_side_lobe;
sharpening=int_nom_side_lobe_neg./int_nom_side_lobe_pos;
