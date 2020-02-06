function measure = FMT( data,name,sm,rdm,target_data,ratio)
% preprocess target data
[Xt,Yt,~,~] = preprocess_target(target_data,rdm,ratio);
source_metric = sm;
source_data = data;
source_name = name;
% feature selection for source data
source_data = FeatureSelection(source_data,source_name,source_metric);
% normalize source data
[Xs,Ys] = preprocess_source(source_data);
% check the num of instances
sn=size(Xs,2);tn=size(Xt,2);
if sn>200 && tn>200
    N=200;
else
    if sn>tn
        N=ceil(tn*0.9);
    else
        N=ceil(sn*0.9);
    end
end
% check the num of selected features
sfn=size(Xs,1);tfn=size(Xt,1);
if sfn>tfn
   % select the same number of features as in the target project
   Xs=FeatureRanking(Xs,Ys,size(Xt,1));
end
temp_mea=[];
% repeat sampling 100 times
zXs=zscore(Xs,0,2);
zXt=zscore(Xt,0,2);
for j=1:50
    % set the num of selected samples
    sri = randperm(sn); tri = randperm(tn);
    nsri = sri(1:N);ntri=tri(1:N);
    [new_Xs,new_Xt]=FeatureMatching(zXs,zXt,nsri,ntri);
    if ~isempty(new_Xs) && ~isempty(new_Xt)
        train_new=new_Xs;test_new=new_Xt;        
        % LR begin
        model = train(Ys', sparse(train_new'),'-s 0 -c 1 -B -1 -q'); % num * fec
        [~, ~, prob_estimates] = predict(Yt', sparse(test_new'), model, '-b 1');
        score = prob_estimates(:,1)';
        mea = performanceMeasure(Yt,score);
        % LR end
        temp_mea=[temp_mea; mea];
    end    
end
measure = mean(temp_mea);
end

