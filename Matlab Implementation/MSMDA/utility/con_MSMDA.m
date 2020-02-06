function [measure] = con_MSMDA(data,rdm,target,ratio)
% MSMDA

% normalize target data
[Xl,Yl,Xu,Yu] = normN2_target(target,rdm,ratio);
Xl = Xl*diag(1./sqrt(sum(Xl.^2)));
Xu = Xu*diag(1./sqrt(sum(Xu.^2)));

% split training target data Xl into training data Xltr and validation data Xlva
nl = length(Yl);
nlt = ceil(nl/2);

rng('default')
ridx = randperm(nl);
Xltr = Xl(:,ridx(1:nlt));
Yltr = Yl(ridx(1:nlt));
Xlva = Xl(:,ridx(nlt+1:nl));
Ylva = Yl(ridx(nlt+1:nl));

Xl = [Xltr,Xlva];
Yl = [Yltr,Ylva];

% set predefined variables
options = [];
options.Xu = Xu;
options.Yu = Yu;
options.Xl = Xl;
options.Yl = Yl;

options.Xltr = Xltr; 
options.Yltr = Yltr;
options.Xlva = Xlva; 
options.Ylva = Ylva;

options.doTraining = 1; % training
options.Ws = [];

% for differnt predcition combination
v = size(data,1);

% % for CPDP, delete target project from source data 
% for i=1:v
%     source = data{i,1};
%     if size(source,2)==size(target,2)
%         target_i=i;
%         break;
%     end
% end
% data(target_i,:)=[];
% v = v-1;

mea = [];
for i=1:v
    source = data{i,1};
    % normalize source data
    [Xs,Ys] = normN2_source(source);
    Xs = Xs*diag(1./sqrt(sum(Xs.^2)));
    % evaluation
    mea = [mea; MDA(Xs,Ys,options)];
end
% sort the sources accroding to the performance measure 
g_measure = mea(:,2);
if sum(g_measure == 0)
    [smea,idx] = sortrows(mea,-3);
else
    [smea,idx] = sortrows(mea,[-2,-1]);
end
th = smea(1,2);

% realignment the multiple sources
sdata = data(idx,:);

% perform multiple source MDA
measure = MSMDA(sdata,options,th);
end