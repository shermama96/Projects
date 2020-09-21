function eqns = buildBeamEqs(momentFunctions, domains, E, I)
%{
Function takes symbolic moment functions, and their corresponding 
domains and integrates them to build displacement and angle functions

Inputs...
momentFunctions: A cell array of symfuns
domains: matrix of domains, each row corresponds to a momentFunc 
i.e. [0, a; a, L] (sym or double)
E: A value for youngs modulus (sym or double)
I: Value for moment of area (sym or double)

Outputs...
eqns: a cell matrix of the angle and displacement equations and each
corresponding domains
%}
for i = 1:size(momentFunctions, 2)
    
    inputVars = argnames(momentFunctions{i});
    theta(inputVars) = (int(momentFunctions{i}, inputVars) + newIntConst())/(E*I);
    disp(inputVars) = int(theta, inputVars) + newIntConst();
    eqns(i,:) = {domains(i,:), theta, disp};
    
end
end