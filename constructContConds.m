function res = constructContConds(inFuncs)
%{
Function takes the cell array of displacement and angle equations, connects
domain(1) to domain(2) so that several moment equations satisfy a
continuity condition

Inputs...
inFuncs: a cell array of displacement and angle equations (returned from function 
"buildBeamEqs"

Outputs...
eqns: system of equations to be solved in conjunction with boundary eqns 
and resolve constants of integration
%}
if size(inFuncs, 1) == 1
    res = [];
else
    syms thetaCont dispCont
    
    for i = 1:size(inFuncs, 1) - 1
        domains = inFuncs{i, 1};
        currentThetaFunc = inFuncs{i, 2};
        nextThetaFunc = inFuncs{i + 1, 2};
        currentDispFunc = inFuncs{i, 3};
        nextDispFunc = inFuncs{i + 1, 3};
        thetaCont(i, 1) = currentThetaFunc(domains(2)) == nextThetaFunc(domains(2));
        dispCont(i, 1) = currentDispFunc(domains(2)) == nextDispFunc(domains(2));
    end
    res = [thetaCont; dispCont];
end
end
