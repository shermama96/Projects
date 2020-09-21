function res = evalBeam(beam, xVal, positionVars)
%{
Function takes a "beam object" (although yes I know not actually an object)
and evaluates it. This is necessary as you need to ensure that when you
evaulate the beam object, which is comprised of multiple disp and anglue eqns,
values are returned from equations existing in the prescribed domain.

Inputs...
inFuncs: a cell array of displacement and angle equations (returned from function 
"buildBeamEqs"
BCs: (numeric) a matrix of values in the form of [type, location, value;
type, location, value] i.e. [1, 0, 0; 2, 0, 0]
1 for angle BC and 2 for displacement BC

Outputs...
eqns: system of equations to be solved in conjunction with continuity eqns 
%}
idx = 1;
domains = [beam{1, :}];

while true
    if idx > length(domains)
        fprintf("Uh-oh, x-value is not inside beam domain")
        res = [];
        break
    end
    
    if xVal >= domains(idx) ||  xVal <= domains(idx+1)
        eqnIdx = (idx + 1)/2;
        res = double(vpa(subs([beam{eqnIdx, 2}; beam{eqnIdx, 3}], positionVars, xVal), 6));
        cmdHeader("Beam output at position: x=" + string(xVal), 55);
        fprintf("SLOPE: %.4f\n", res(1));
        fprintf("DEFLECTION: %.4f\n", res(2));
        break
    end
    idx = idx + 2;
end
end