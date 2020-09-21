function res = constructBoundConds(inFuncs, BCs)
%{
Function takes the cell array of displacement and angle equations, and
boundary conditions and builds a set of simultaneous equations to solve
based on the combination of BCs and inFuncs and resolve constants of
integration

Inputs...
inFuncs: a cell array of displacement and angle equations (returned from function 
"buildBeamEqs"
BCs: (numeric) a matrix of values in the form of [type, location, value;
type, location, value] i.e. [1, 0, 0; 2, 0, 0]
1 for angle BC and 2 for displacement BC

Outputs...
eqns: system of equations to be solved in conjunction with continuity eqns 
%}

eqnIdx = 1;
for i = 1:size(BCs, 1)
    currentXVal = BCs(i, 2);
    for j = 1:size(inFuncs, 1)
        thetaFunc = inFuncs{j, 2};
        dispFunc = inFuncs{j, 3};
        if max(strcmp(string(currentXVal), string(inFuncs{j, 1})))
            if BCs(i, 1) == 1
                eqns(eqnIdx,:) = BCs(i, 3) == thetaFunc(BCs(i, 2));
                eqnIdx = eqnIdx + 1;
            end
            
            if BCs(i, 1) == 2
                eqns(eqnIdx,:) = BCs(i, 3) == dispFunc(BCs(i, 2));
                eqnIdx = eqnIdx + 1;
            end
        end
    end
end

res = eqns;
end