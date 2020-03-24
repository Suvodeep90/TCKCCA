clc
clear
addpath('Tools/liblinear/');
addpath('Tools/')
addpath('CTKCCA/utility/');

target_path='DS2/';
all_target_file=dir(target_path);
target_file_num=length(all_target_file);

%save path
save_path = 'CTKCCA/output/';
if ~exist(save_path) 
    mkdir(save_path)
end

% conduct the experiment
Rep = 20; % runs
ratio = 0.1; % the ratio of training target data

for i=1:target_file_num-2
    target_file=all_target_file(i+2).name;
    % load source project
    load([target_path,target_file]);
    source_project=project;
    %disp(source_project)
    
    for j=1:target_file_num-2
        target_file=all_target_file(j+2).name;
        % load target project
        load([target_path,target_file]);
        target_project=project;
        %disp(target_project)
        
        result = [];detail_result=[];
        
        if ~strcmp(source_project.belong,target_project.belong)
           % predict A source-> A target
           sd=[source_project.data';source_project.label'];
           td=[target_project.data';target_project.label'];
%            disp(size(source_project.data))
%            disp(size(target_project.data))
           for loop = 1:Rep
                measure=CTKCCA(sd,target_project.randomidx(loop,:),td,ratio);
                result = [result; measure];
           end
           
           detail_result = result;
           savepath=[save_path,source_project.name,'_to_',target_project.name,'.mat'];
           save(savepath,'detail_result')
        end
    end
end
disp('done !')