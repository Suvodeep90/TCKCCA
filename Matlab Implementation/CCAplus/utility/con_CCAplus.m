function measure = con_CCAplus( data,rdm,target,ratio,sp_coind,tp_coind )
%% construct UMR
dt=size(target,1)-1;
nt=size(target,2);
ds=size(data,1)-1;
ns=size(data,2);
dc=size(sp_coind,2);

source_common=data(sp_coind,:);
temp1=data;
temp1(sp_coind,:)=[];
source_only=temp1;

target_common=target(tp_coind,:);
temp2=target;
temp2(tp_coind,:)=[];
target_only=temp2;

source_umr=[source_common;source_only(1:end-1,:);zeros(dt-dc,ns);source_only(end,:)];
target_umr=[target_common;zeros(ds-dc,nt);target_only(1:end-1,:);target_only(end,:)];

% splite target data to %90 test data and 10% training target data
[Xtl,Ytl,Xtu,Ytu]=normN2_target(target_umr,rdm,ratio);
Xtu = Xtu*diag(1./sqrt(sum(Xtu.^2)));

[Xs,Ys]=normN2_source(source_umr);
Xs = Xs*diag(1./sqrt(sum(Xs.^2)));

[Ps,Pt,eigValue,~,~] = CCA(Xs,Xtu);
d = rank(diag(eigValue));

[k,~] = tunePar(Ps,Pt,d,Xs,Ys,Xtl,Ytl);

pXs = Ps(:,1:k)'*Xs;pXtu = Pt(:,1:k)'*Xtu;

pXs = pXs*diag(1./sqrt(sum(pXs.^2)));
pXtu = pXtu*diag(1./sqrt(sum(pXtu.^2))); 
    
pXs = real(pXs);pXtu = real(pXtu);

% LR begin
model = train(Ys', sparse(pXs'),'-s 0 -c 1 -B -1 -q'); % num * fec
[~, ~, prob_estimates] = predict(Ytu', sparse(pXtu'), model, '-b 1');
score = prob_estimates(:,1)';
mea = performanceMeasure(Ytu,score);
% LR end

measure=mea;
end
