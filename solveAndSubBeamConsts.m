function res = solveAndSubBeamConsts(inFuncs, BCs)
%{
Main symbolic beam solver. Function parses symbolic functions to find the 
unknown constants of integration, establish a system of equations to solve
for those constants based on BCs and CCs.

Inputs...
inFuncs: a cell array of displacement and angle equations (returned from function 
"buildBeamEqs"
BCs: (numeric) a matrix of values in the form of [type, location, value;
type, location, value] i.e. [1, 0, 0; 2, 0, 0]
1 for angle BC and 2 for displacement BC

Outputs...
res: a cell array "beam object" representing the angle and displacement
functions and their corresponding domains. Can be evaluated calling
"evalBeam"
%}
constantVars = findIntConstVars(inFuncs);
continuityEqns = constructContConds(inFuncs);
boundaryEqns = constructBoundConds(inFuncs, BCs);

constantVals = solve([continuityEqns, boundaryEqns], constantVars);

for i = 1:size(inFuncs, 1)
    temp(i, 1) = inFuncs{:, 2};
    temp(i, 2) = inFuncs{:, 3};
end

finalEqns = subs(temp, constantVars, struct2cell(constantVals));
res = [{inFuncs{:, 1}}', sym2cell(finalEqns)];
end