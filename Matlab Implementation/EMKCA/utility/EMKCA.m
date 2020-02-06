function measure = EMKCA(data,Xt,Yt,lrank)

% '0' denotes "linear kernel"
kpar = [2^-4 2^-3 2^-2 2^-1 1 2 2^2 2^3 2^4 0];
temp_mea=[];
% one source to one target
for i=1:1
    source = data;
    % normalize source data
    [Xs,Ys] = normN2_source(source);
       
    prelabel = [];
    w = [];
    len = length(kpar);
    for j=1:len
        [nXs,nXt] = KCA(Xs,Xt,kpar(j),lrank);
        nXs = real(nXs); nXt = real(nXt);
        nXs = nXs*diag(1./sqrt(sum(nXs.^2))); nXs(isnan(nXs)) = 0;
        nXt = nXt*diag(1./sqrt(sum(nXt.^2))); nXt(isnan(nXt)) = 0;
        
        dist = pdist2(nXs, nXt);
        d = mean(mean(dist));
        w = [w, 1.0/d];
        
        % LR calssifier
        model = train(Ys',sparse(nXs),'-s 0 -c 1 -B -1 -q'); % num * fec
        [predict_label, ~, ~] = predict(Yt',sparse(nXt),model,'-b 1');
        prelabel = [prelabel; predict_label'];  
    end
    
    w = w/sum(w); % weighted ensemble
    ss = w*prelabel;
    
    mea = performanceMeasure(Yt,ss);
    temp_mea = [temp_mea; mea];
end
measure = temp_mea;
end
