function [ rankedData ] = FeatureRanking( data,data_label,feature_num )
% obtain the defect and non-defect data
defectData=data(:,find(data_label==1));
non_defectData=data(:,find(data_label==0));
% Number of nearest neighbors
n1=size(defectData,2);
n2=size(non_defectData,2);
fn=size(defectData,1);
k=floor(n2/n1);
W=zeros(1,fn);
for i=1:n1
    ed=[];
    for j=1:n2
        ed(j)=norm(defectData(:,i)-non_defectData(:,j));
    end
    [~,orig_idx]=sort(ed);
    temp_idx=(1:n2);
    neigbour_idx=temp_idx(orig_idx(1:k));

    for j=1:k
        diff=[];
        for l=1:fn
          diff(l)=abs(defectData(l,i)-non_defectData(l,neigbour_idx(j)));
        end
        [~,b]=sort(diff);
        for l=1:fn
          W(b(l))=W(b(l))+l;
        end
    end
end
[~,c]=sort(W,'descend');
rankedData=data(c(1:feature_num),:);
end

