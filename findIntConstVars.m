function res = findIntConstVars(inFuncs)
%{
Function used to parse symbolic functions and return a list of the
constants of integration in the symbolic functions.

Inputs...
inFuncs: a cell array of displacement and angle equations (returned from function 

Outputs...
res: (string vector) list of symbolic variables used to sub in system of
eqns stemming from BCs and CCs
%}
funcs2String = strjoin(string(inFuncs(:, 3)));
[constIdxStart, constIdxEnd] = regexp(funcs2String, 'C\d(\d)?(\d)?');

for i = 1:length(constIdxStart)
    res(i, 1) = string(extractBetween(funcs2String, constIdxStart(i), constIdxEnd(i)));
end
res = sort(sym(res));
end