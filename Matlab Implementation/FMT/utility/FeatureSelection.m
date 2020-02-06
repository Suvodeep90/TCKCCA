function [ selected_data ] = FeatureSelection( DataFile,DataFilename,DataMetric )

dataFilepath= ['..\..\DATASET\codeOfProcess\arff30\',DataFilename,'.arff'];
if exist(dataFilepath)
    % load the arff file
    fileReader = javaObject('java.io.FileReader', dataFilepath);
    ds = javaObject('weka.core.Instances', fileReader);
    ds.setClassIndex(ds.numAttributes() - 1);
else
    [xs,ys] =  preprocess_source(DataFile);
    ds=matlab2weka(DataFilename,DataMetric,xs',ys');
end

% correlation-based feature selection (CFS), weka implementation
eval=javaObject('weka.attributeSelection.CfsSubsetEval');
search=javaObject('weka.attributeSelection.BestFirst');
eval.buildEvaluator(ds);

% obtain the indexes of selected attributes
attrIndex = search.search(eval, ds);
attrIndex = attrIndex+1;

% obtain selected data according to the attrIndex
selected_data=DataFile([attrIndex',end],:);
end

