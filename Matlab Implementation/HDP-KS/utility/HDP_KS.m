function [measure] = HDP_KS(data,name,sm,rdm,target,ratio,selection_method,fs_ratio)
% preprocess target data
[~,~,Xt,Yt] = preprocess_target(target,rdm,ratio);

source_metric = sm;
source_data = data;
source_name = name;

% feature selection for source data
r=fs_ratio;
source_data=featureSelection(source_data,source_name,source_metric,selection_method,r);
% preprocess source data
[Xs,Ys] =  preprocess_source(source_data);
   
% matching metric
[train_new,test_new] = matchingMetric(Xs,Xt);
       
if ~isempty(train_new)
    train_new = zscore(train_new,0,2);
    test_new = zscore(test_new,0,2);
    % LR
    model = train(Ys', sparse(train_new'),'-s 0 -c 1 -B -1 -q'); % num * fec
    [~, ~, prob_estimates] = predict(Yt', sparse(test_new'), model, '-b 1');
    score = prob_estimates(:,1)'; 
    mea = performanceMeasure(Yt,score);
else
    mea = zeros(1,16);
end
measure = mea;
end