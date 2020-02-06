clc
clear
addpath('..\Tools\liblinear\');
addpath('..\Tools\')
addpath('.\utility\');

target_path='..\DS2\';
all_target_file=dir(target_path);
target_file_num=length(all_target_file);

%save path
save_path = '.\output\';
if ~exist(save_path) 
    mkdir(save_path)
end

% conduct the experiment
Rep = 20; % runs
ratio = 0.1; % the ratio of training target data

all_sources = getAllSources(target_path);

for j=1:target_file_num-2
    target_file=all_target_file(j+2).name;
    % load target project
    load([target_path,target_file]);
    target_project = project;
    result = [];detail_result=[];
        
    for k=1:size(all_sources,1)
        if strcmp(all_sources{k,2},target_project.belong)==1
            source_data = all_sources{k,1};
            break;
        end
    end
    % predict multi sources -> A target
    td=[target_project.data';target_project.label'];
           
    for loop = 1:Rep
        measure = con_MSMDA(source_data,target_project.randomidx(loop,:),td,ratio);
        result = [result; measure];
    end
    detail_result = result;
    savepath=[save_path,'multi_to_',target_project.name,'.mat'];
    save(savepath,'detail_result');
end
disp('done !')