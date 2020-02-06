function measure = con_CLSUP(data,rdm,target,ratio)
% normalize target data
[Xl,Yl,Xu,Yu] = normN2_target(target,rdm,ratio);

% Perform PCA for target data
Xt = [Xl,Xu];
Ctt = Xt*Xt'/size(Xt,2);
[u,s] = eig(Ctt);
[~,sidx] = sort(diag(s),'descend');
u = u(:,sidx);

k = rank(s);
u = u(:,1:k);
Xl = u'*Xl;
Xu = u'*Xu;

Xl = Xl*diag(1./sqrt(sum(Xl.^2)));
Xu = Xu*diag(1./sqrt(sum(Xu.^2)));

source=data;
% normalize source data
[Xs,Ys] = normN2_source(source);
Xs = Xs*diag(1./sqrt(sum(Xs.^2)));

[P,~] = CLSUP(Xs,Ys,Xl,Yl);
pXs = P'*Xs;
pXs = pXs*diag(1./sqrt(sum(pXs.^2)));

% LR calssifier
% using the transformed source data and train target data to train the
% classification model !
model = train([Ys,Yl]',sparse([pXs,Xl]'),'-s 0 -c 1 -B -1 -q'); % num * fec
[~, ~, prob_estimates] = predict(Yu',sparse(Xu'),model,'-b 1');
score = prob_estimates(:,1)'; 
mea = performanceMeasure(Yu,score);
    
measure = mea;
end


