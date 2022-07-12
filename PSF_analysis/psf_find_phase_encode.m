% -_-_-_-_-_-_-_-_-_-_-_-_-_-_-psf_find_phase_encode-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
%
% Description: 
% -----------
% 
% extract trajectory points along phase-encode (PE) direction by finding zero
% crossings.
%
% Inputs:
% -----
% 
%     kloc: trajectory points in (rad/m) [Nkloc,2]
% 
%     type: type of trajectoy:
%           - 'ep' for EPI
%           - 'sp' for spiral
% 
% Outputs:
% -------
%       
%    index: indices of trajectory points along PE direction [N_PE,1]
%
% Article: Feizollah and Tardif (2022)
% -------
% 
% Sajjad Feizollah, July 2022
% -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-

function index=psf_find_phase_encode(kloc,type)

% >>>>>>>>>> find zero crossings in spiral when trajectory changes from positive to negative <<<<<<<<<<

if(type=="sp")
    index=find((kloc(2:end,1).*kloc(1:end-1,1))<0);
    
% >>>>>>>>>> find zero crossings in EPI by finding zeros on PE direction <<<<<<<<<<

elseif(type=="ep")
    index=find(kloc(:,1)==0);
end