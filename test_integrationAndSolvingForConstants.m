clear all; close all; clc; 
initIntConst();
headerLength = 55;
syms P w x L E I

M(x) = P*(x - L);
theta1(x) = (int(M, x) + newIntConst())/(E*I);
disp1(x) = int(theta1, x) + newIntConst();
BCs1 = [1, 0, 0; 2, 0, 0]; 

beamLength = 1;
yMod = 200E9;
Ix = .0001;
force = 10000;

%{
@x = (1), f(x) = (2)
leading val dictates type of BC -- 1 for angle, 2 for displacement
%}
beam1Eqs = solveAndSubBeamConsts({[0, beamLength], theta1, disp1}, BCs1);
res = beam1Eqs(beamLength, yMod, Ix, beamLength, force);


cmdHeader("Fixed Cantilever Beam Test", headerLength);
fprintf("The test for max displacement yields: %d\n", res(2));
fprintf("The actual value for max displacement is: %d\n\n", -(force*beamLength^3)/(3*yMod*Ix))

M2(x) = .5*w*L*x - .5*w*x^2;
theta2(x) = (int(M2, x) + newIntConst())/(E*I);
disp2(x) = int(theta2, x) + newIntConst();
BCs2 = [2, 0, 0; 2, L, 0]; % @x = (1), f(x) = (2)
beam2Eqs = solveAndSubBeamConsts({[0, beamLength], theta2, disp2}, BCs2);

res2 = beam2Eqs(beamLength/2, yMod, Ix, beamLength, force);
cmdHeader("Pinned -- Pinned Beam Test", headerLength);
fprintf("The test for max displacement yields: %d\n", res2(2));
fprintf("The actual value for max displacement is: %d\n\n", -(5*force*beamLength^4)/(384*yMod*Ix))


