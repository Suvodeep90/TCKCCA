function [ new_train, new_test ] = checkvar( trainset, trainlabel, testset )
%CHECKVAR 此处显示有关此函数的摘要
%   此处显示详细说明
posind = find(trainlabel == 1);
negind = find(trainlabel == 0);

pos_trainset = trainset(posind,:);
neg_trainset = trainset(negind,:);
pos_trainset_std = std(pos_trainset,0,1);
neg_trainset_std = std(neg_trainset,0,1);

zero_std_pos = find(pos_trainset_std == 0);
zero_std_neg = find(neg_trainset_std == 0);
zero_std = union(zero_std_pos,zero_std_neg);

new_train = trainset;
new_train(:,zero_std)=[];
new_test = testset;
new_test(:,zero_std)=[];
end

