function rollerForce = calcBearingLoadDist(appliedMoment, preload, transverseLoad, rollerSpacing)
%{
Function takes parameters that describe rolling element interface and
resolves loads per rolling elements. Paramterizes reaction force
distribution as a quadratic function, solving for leading coefficient.
Relies on symmetric nature of loading. 

Inputs...
appliedMomeny: (double) moment applied to linear bearing
preload: (double) global preload applied to overall bearing (all rollers)
transverseLoad: (double) linear force applied to bearing interface
rollerSpacing: (double) linear distance between rollers 

Outputs...
rollerForce: (double) an array of normal forces acting on rollers
%}
syms a
x1 = 0;
x2 = rollerSpacing;
x3 = 2*rollerSpacing;
x4 = 3*rollerSpacing;
Fp = preload/4;
Ft = transverseLoad/4;

F1 = 0;
F2 = a*x2^2;
F3 = a*x3^2;
F4 = a*x4^2;
F5 = 0;
F6 = F2;
F7 = F3;
F8 = F4;

AMB = -appliedMoment == (F7 + Fp + Ft)*x2 + (F6 + Fp + Ft)*x3 + (F5 + Fp + Ft)*x4 - (F4 + Fp + Ft)*x4 - (F3 + Fp + Ft)*x3 - (F2 + Fp + Ft)*x2;
aRes = double(solve(AMB, a));

rollerForce(1) = Fp + Ft + double(subs(F1, a, aRes));
rollerForce(2) = Fp + Ft + double(subs(F2, a, aRes));
rollerForce(3) = Fp + Ft + double(subs(F3, a, aRes));
rollerForce(4) = Fp + Ft + double(subs(F4, a, aRes));
end