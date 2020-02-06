% Strategy 1
function [ matched_result ] = Strategy1( diffs )
% Preparing
% num of source feature
n_sf=size(diffs,1);
% num of target feature
n_tf=size(diffs,2);
% sign the matched target feature
flag=zeros(1,n_tf);
% sign which target feature matches the target feature
flag_detail=zeros(1,n_tf);
% record the matched target feature for the source feature
match_re=zeros(1,n_sf);

for i=1:n_sf
[a,b]=sort(diffs(i,:));
sortedDis{i}=b;
sortedDisss{i}=a;
end
% Competing
for i=1:n_sf
ti=i;
while 1
    bestDisId=sortedDis{ti}(1);
    if ~flag(bestDisId)
        match_re(ti)=bestDisId;
        flag(bestDisId)=1;
        flag_detail(bestDisId)=ti;
        break;
    else
        d1=diffs(flag_detail(bestDisId),bestDisId);
        d2=diffs(ti,bestDisId);
        if d1>d2
            temp=flag_detail(bestDisId);
            match_re(temp)=0;
            flag_detail(bestDisId)=ti;
            match_re(ti)=bestDisId;
            sortedDis{ti}(1)=[];
            break;
            % give up the loser, go on the next
        else
            sortedDis{ti}(1)=[];
            % give up the loser, go on the next
            break;
        end
    end
end
end
matched_result=match_re;
end

