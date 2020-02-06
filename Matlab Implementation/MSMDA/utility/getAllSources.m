function [ allsource ] = getAllSources( tp )
all_file=dir(tp);
file_num=length(all_file);
datasets={'NASA','SOFTLAB','ReLink','AEEEM','PROMISE'};
allsources={};
for i=1:5
    n=0;
    ad={};
    for j=1:file_num-2
        target_file=all_file(j+2).name;
        load([tp,target_file]);
        source_data = [project.data';project.label'];
        source_name = project.name;
        source_from = project.belong;
        if strcmp(source_from,datasets{1,i})~=1
            n=n+1;
            ad{n,1}=source_data;
            ad{n,2}=source_name;
        end
    end
    allsource{i,1}=ad;
    allsource{i,2}=datasets{1,i};
end