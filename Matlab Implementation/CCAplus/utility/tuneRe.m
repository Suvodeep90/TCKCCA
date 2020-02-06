function [ lam1,lam2 ] = tuneRe( sd,td )

[dss,nss] = size(sd);
[dtt,ntt] = size(td);

if nss>=ntt
    n_less=ntt;
else
    n_less=nss;
end
lam1_inter=linspace(0.001,1,5);
lam2_inter=linspace(0.001,1,5);
[X,Y] = meshgrid(lam1_inter,lam2_inter);
XX=X(:);YY=Y(:);
score_max=-inf;
for ii=1:length(XX)
    lam1_curr=XX(ii);
    lam2_curr=YY(ii);
    vec1=[];
    vec2=[];
    for kk=1:n_less
        sd_temp=sd;
        td_temp=td;
        sd_one=sd_temp(:,kk);
        td_one=td_temp(:,kk);
        sd_temp(:,kk)=[];
        td_temp(:,kk)=[];
        C_ss = 1/(nss-1)*(sd_temp*sd_temp') + lam1_curr*eye(dss);
        C_tt = 1/(ntt-1)*(td_temp*td_temp') + lam2_curr*eye(dtt);
        ww = ones(nss-1,ntt-1);
        C_st =sd_temp*ww*td_temp';
        % eigvalue decomposition
        [P_s,P_t,~] = eigDecomposition(C_ss,C_tt,C_st);
        P_s=real(P_s);
        P_t=real(P_t);
        vec1=[vec1;P_s(:,1)'*sd_one];
        vec2=[vec2;P_t(:,1)'*td_one];            
    end
    score_cur=corr(vec1,vec2);
    if score_cur>score_max
        lam1=lam1_curr;
        lam2=lam2_curr;
        score_max=score_cur;
    end
end
end