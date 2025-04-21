% -_-_-_-_-_-_-_-_-_-_-_-_-_-_-cg_sph_harmonics-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
%
% Description: 
% -----------
% 
% Calculates spherical harmonics basis functions up to the 3rd order.
%
% Inputs:
% ------
%
%    x: meshgridded values of x- [Nx*Nx,1]
%    y: meshgridded values of y- [Ny*Ny,1]
%    z: meshgridded values of z- [Nz*Nz,1]
%
% Outputs:
% -------
% 
%    H: spherical harmonics basis functions [16,N*N]
%
% Article: Feizollah and Tardif (2022)
% -------
%
% Sajjad Feizollah, July 2022
% -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-

function H=cg_sph_harmonics(x,y,z)

h(1,:,:)=ones(length(y),length(x)); % 0th order

h(2,:,:)=x; %1st order
h(3,:,:)=y;
h(4,:,:)=z;

h(5,:,:)=x.*y;  %2nd order
h(6,:,:)=z.*y;
h(7,:,:)=3*(z.^2)-((x.^2)+(y.^2)+(z.^2));
h(8,:,:)=x.*z;
h(9,:,:)=(x.^2)-(y.^2);

h(10,:,:)=3*y.*(x.^2)-(y.^3);       %3rd order
h(11,:,:)=x.*y.*z;
h(12,:,:)=(5*(z.^2)-((x.^2)+(y.^2)+(z.^2))).*y;
h(13,:,:)=5*(z.^3)-3*z.*((x.^2)+(y.^2)+(z.^2));
h(14,:,:)=(5*(z.^2)-((x.^2)+(y.^2)+(z.^2))).*x;
h(15,:,:)=(x.^2).*z-(y.^2).*z;
h(16,:,:)=(x.^3)-3*x.*(y.^2);

for k=1:16
    tmp=squeeze(h(k,:,:));
    H(k,:)=tmp(:);
end
