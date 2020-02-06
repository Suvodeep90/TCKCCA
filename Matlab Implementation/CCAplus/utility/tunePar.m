function [k,bestmeasure] = tunePar(Ps,Pt,d,Xs,Ys,Xu,Yu)
measure = [];
for i=1:d
    pXs = Ps(:,1:i)'*Xs;
    pXu = Pt(:,1:i)'*Xu;
    
    pXs = pXs*diag(1./sqrt(sum(pXs.^2)));
    pXu = pXu*diag(1./sqrt(sum(pXu.^2)));
    
    pXs = real(pXs);
    pXu = real(pXu);
        
    pXs = zscore(pXs,0,2);pXu = zscore(pXu,0,2);
    
    model = train(Ys',sparse(pXs'),'-s 0 -c 1 -B -1 -q');
    [~, ~, prob_estimates] = predict(Yu',sparse(pXu'),model,'-b 1');
    score = prob_estimates(:,1)'; 

    mea = performanceMeasure(Yu,score);
    measure = [measure; mea];
end
idx = find(max(measure(:,10)) == measure(:,10)); % bal
k = idx(end);
bestmeasure = measure(k,:);
end