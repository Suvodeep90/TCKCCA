function [Ws,Wt,s] = eigDecomposition(Css,Ctt,Cst)

Cts = Cst';

% % --- Calcualte Wx and r --- 
a = Css\Cst;
b = a/Ctt*Cts;
[Ws,r] = eig(b);

r = sqrt(real(r));
[s, dd_site] = sort(real(diag(r)),'descend');
Ws = Ws(:,dd_site);

% --- Calcualte Wy  --- 
Wt = Ctt\Cts*Ws;
Wt = Wt./repmat(sqrt(sum(abs(Wt).^2)),size(Wt,1),1); % Normalize Wy
