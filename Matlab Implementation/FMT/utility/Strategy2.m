% Strategy 2
function [ matched_result ] = Strategy2( diffs )
% Preparing
n_sf=size(diffs,1);
n_tf=size(diffs,2);
flag=zeros(1,n_tf);
flag_detail=zeros(1,n_tf);
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
                break;
            else
                break;
            end
        end
    end
end
matched_result=match_re;
end

