function [P,k] = CLSUP(Xs,Ys,Xl,Yl)

% Set predefined variables
[ds,ns] = size(Xs);
[dt,nt] = size(Xl);

% Set cost for defective and defect-free instances
defNumS = length(find(Ys==1));
nodefNumS = length(find(Ys==0));
defNumL = length(find(Yl==1));
nodefNumL = length(find(Yl==0));
%cost = [1 (nodefNumS+nodefNumL)/(defNumS+defNumL)];
cost = [1 1];
% conditional distributions MMD
A = zeros(ns,ns);
B = zeros(ns,nt);
label_idx = unique(Ys);
C = length(label_idx);
for c = 1:C
    if label_idx(c) == 1
        i = 1;
    else
        i = 2;
    end
    
    ncs = length(find(Ys==label_idx(c)));
    A(Ys==label_idx(c),Ys==label_idx(c)) = cost(i)/ncs^2;
    
    ncl = length(find(Yl==label_idx(c)));
    B(Ys==label_idx(c),Yl==label_idx(c)) = cost(i)/(ncs*ncl);
end
A = A/norm(A,'fro');
B = B/norm(B,'fro');

% regularizer term
I = eye(ds,ds);

% label and structure-preserving
tempslabel = Ys;
tempslabel(tempslabel==0) = 2;
options = [];
options.NeighborMode = 'Supervised';
options.gnd = tempslabel';
options.bLDA = 1;

Ws = constructW(Xs',options);
Ws = full(Ws);
D = sum(Ws,2);
L = diag(D)-Ws;

% obtain P
alpha = 1; % regularizer parameter
lambda = 0.5; % regularizer parameter

BB = Xs*B*Xl';
% note from chw
k = rank(BB);
%k=0;
P = (Xs*(A+alpha*L)*Xs'+lambda*I) \ BB;
