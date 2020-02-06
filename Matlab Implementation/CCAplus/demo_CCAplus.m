clc
clear
addpath('..\Tools\liblinear\');
addpath('..\Tools\')
addpath('.\utility\');
defineCommonIndex

target_path='..\DS2\';
all_target_file=dir(target_path);
target_file_num=length(all_target_file);

save_path = '.\output\';
if ~exist(save_path) 
    mkdir(save_path)
end

Rep=20;
ratio = 0.1; % use 10% labeled target data

for i=1:target_file_num-2
    target_file=all_target_file(i+2).name;
    % load source project
    load([target_path,target_file]);
    source_project=project;
    
    for j=1:target_file_num-2
        target_file=all_target_file(j+2).name;
        % load target project
        load([target_path,target_file]);
        target_project=project;
        
        result = [];detail_result=[];
        par_result = [];detail_par_result=[];
        
        if ~strcmp(source_project.belong,target_project.belong)
           sp_common_ind = [source_project.belong,'_',target_project.belong];
           tp_common_ind = [target_project.belong,'_',source_project.belong];
           % predict A source-> A target
           sd=[source_project.data';source_project.label'];
           td=[target_project.data';target_project.label'];
            % recommend using parfor
            for loop = 1:Rep
                measure = con_CCAplus(sd,target_project.randomidx(loop,:),td,ratio,common_index(sp_common_ind),common_index(tp_common_ind));
                result = [result; measure];
            end
           detail_result = result;
           savepath=[save_path,source_project.name,'_to_',target_project.name,'.mat'];
           save(savepath,'detail_result')
        end
    end
end
disp('done !')