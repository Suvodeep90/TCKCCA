function measure = CPDP_IFS(data,rdm,target,ratio)

% normalize target data
[~,~,Xu,Yu] = preprocess_target(target,rdm,ratio);

measure = [];auc = [];

source = data;
[Xs,Ys] = preprocess_source(source);
    
XsDCV = [];
for ns=1:size(Xs,2)
    XsDCV = [XsDCV, getDCV(Xs(:,ns))];
end
    
XuDCV = [];
for nut=1:size(Xu,2)
    XuDCV = [XuDCV, getDCV(Xu(:,nut))];
end
    
XsDCV = zscore(XsDCV,0,2);
XuDCV = zscore(XuDCV,0,2);
    
% LR begin
model = train(Ys', sparse(XsDCV'),'-s 0 -c 1 -B -1 -q'); % num * fec 
[predict_label, ~, prob_estimates] = predict(Yu', sparse(XuDCV'), model, '-b 1');
h = predict_label';
mea = performanceMeasure(Yu,h);
% LR end

measure=mea;
end