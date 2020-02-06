
function [newKs,Kt] = KCA(Xs,Xt,kpar,lrank)
% kernel correlation alignment
% 
% Xs: d X ns
% Xt: d X nt

if kpar == 0 % linear kernel
    kernel1 = {'linear',kpar}; 
    kernel2 = {'linear',kpar};
else
    kernel1 = {'gauss',kpar};   % kernel type and kernel parameter for data set 1
    kernel2 = {'gauss',kpar};   % kernel type and kernel parameter for data set 2
end
        
[Ks,Kt] = conKernelMatrix(Xs',Xt',kernel1,kernel2,lrank);

% construct covariance matrix
reg = 1E-5; % regularization
Css = cov(Ks)+reg*eye(size(Ks,2));
Ctt = cov(Kt)+reg*eye(size(Kt,2));

% correlation alignment
[u,s,v] = svd(Css);
Cs = u*s^(-0.5)*v';
[u,s,v] = svd(Ctt);
Ct = u*s^0.5*v';
newKs = Ks*Cs*Ct;

