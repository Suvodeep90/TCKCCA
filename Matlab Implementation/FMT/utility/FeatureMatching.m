function [ newSource, newTarget ] = FeatureMatching( sourceData,targetData,sidx,tidx )
% random
% preprocessing
n=length(sidx);
nsourceData=sourceData(:,sidx);
ntargetData=targetData(:,tidx);
n1=size(nsourceData,1);
n2=size(ntargetData,1);
Diffs=zeros(n1,n2);
% Caculate the diffs between source features and target features 
for i=1:n1
    source_ith_feature=nsourceData(i,:);
    [ai,~]=sort(source_ith_feature);
    for j=1:n2
        target_jth_feature=ntargetData(j,:);
        [aj,~]=sort(target_jth_feature);
        %plot((1:n),ai,(1:n),aj);
        Diffs(i,j)=trapz((1:n),abs(ai-aj));
    end
end
match=zeros(1,n1);
flag=zeros(1,n2);
matched_result=Strategy2(Diffs);
newSource=[];newTarget=[];
for i=1:length(matched_result)
    if matched_result(i)~=0
        t_s=sourceData(i,:);
        t_t=targetData(matched_result(i),:);
        newSource=[newSource;t_s];
        newTarget=[newTarget;t_t];
    end
end
end

