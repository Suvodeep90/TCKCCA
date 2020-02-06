function [DCV] = getDCV(vector)
% compute the 16 distributional characteristics of a sample or feature 
%  mode, median, mean, harmonic mean, minimum, maximum, range, variation
%  ratio, first quaritle, third quartile, interquartile range, variance,
%  standard devariation, coefficient of variation, skewness, kurtosis
% 
%  ASE2012_an investigation on the feasibility of cross-project defect
%  prediction -- Table 7
% 
% vector: n X 1

DCV = zeros(16,1);
DCV(1) = mode(vector); % the value that occurs most frequently in a population
DCV(2) = median(vector);
DCV(3) = mean(vector);

temp = 1./vector; % Harmonic Mean: the reciprocal of the arithmetic mean of the reciprocals
temp(isinf(temp)) = 0;
DCV(4) = 1/mean(temp);

DCV(5) = min(vector);
DCV(6) = max(vector);
DCV(7) = DCV(6)-DCV(5); % range: the deviation of the Minimum to the Maximum

DCV(8) = length(find(vector~= DCV(1)))/length(vector);  % Variation Ratio: the proportion of cases that are not the mode

DCV(9) = quantile(vector,0.25); % First Quartile or prctile(x,25)
DCV(10) = quantile(vector,0.75); % Third Quartile or prctile(x,75)
DCV(11) = DCV(10)-DCV(9); % Interquartile Range: the deviation of the First Quartile to the Third Quartile

DCV(12) = var(vector);
DCV(13) = std(vector); 

DCV(14) = std(vector)/mean(vector); % Coefficient of Variation: the ratio of the Standard Deviation to the Mean

% Skewness: a measure of the asymmetry of a population
temp = vector-repmat(mean(vector),length(vector),1);
DCV(15) = sum(power(temp,3))/ (power(std(vector),3)*length(vector));

% Kurtosis: a measure of the peakedness of a population
DCV(16) = sum(power(temp,4))/ (power(std(vector),4)*length(vector));

