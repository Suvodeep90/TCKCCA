function [Ps,Pt,S,lambda1,lambda2] = CCA(Xs,Xt)

[ds,ns] = size(Xs);
[dt,nt] = size(Xt);

[lambda1,lambda2]=tuneRe(Xs,Xt);

Css = 1/ns*(Xs*Xs') + lambda1*eye(ds);
Ctt = 1/nt*(Xt*Xt') + lambda2*eye(dt);

W = ones(ns,nt);
Cst =Xs*W*Xt';

% eigvalue decomposition
[Ps,Pt,S] = eigDecomposition(Css,Ctt,Cst);