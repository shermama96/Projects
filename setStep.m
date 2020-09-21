function stepSize = setStep(lowerLimit, upperLimit, resolutionFactor)
%{
sets the step size for spring optimization parameter sweeps

inputs...
lowerLimit: (double) lower parameter limit
upperLimit: (double) upper parameter limit
resolutionFactor: (double) defaults to 2 percent, percentage of difference
between upper and lower limit used to generate step size

outputs...
stepSize: (double) step size in parameter sweep
%}
if ~exist('resolutionFactor', 'var')
    resolutionFactor = .02;
end
temp = (upperLimit - lowerLimit)*resolutionFactor;
stepSize = floor(temp) + ceil((temp - floor(temp))/.25)*.25;
end