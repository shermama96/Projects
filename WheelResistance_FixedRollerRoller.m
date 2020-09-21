clear all; close all; clc;
syms x Ra2 Ra3 Mr E I real
g = 9.81;
scLength = 2.6;
scDistLoad = 30.490*g;
antlerMass = 10.5;
scTotalGravLoad = g * (antlerMass + scDistLoad*scLength);
wheelPos1 = [0, 0];
wheelPos2 = 1.37; % DOUBLE CHECK THIS YOU DUMB FUCK

%% Actual loadings with zero redundancies
Ma1 = .5*scDistLoad*scLength^2;
BCs = [1, 0, 0; 2, 0, 0];
M1(x) = scDistLoad*scLength*x - Ma1 - .5*scDistLoad*x^2;
beam1MomentEqns = buildBeamEqs({M1}, [0, scLength], E, I);
beam1System = solveAndSubBeamConsts(beam1MomentEqns, BCs);

%% Roller Support Redundancy at (a)
a = wheelPos2;
Fb = Ra2;
Ma2 = Fb*a;
M2(x) = Ma2 - Ra2*x;
M3(x) = Fb*(x - a) + Ma2 - Ra2*x;
beam2MomentEqns = buildBeamEqs({M2, M3}, [0, a; a, scLength], E, I);
beam2System = solveAndSubBeamConsts(beam2MomentEqns, BCs);

%% Roller Support Redundancy at (L)
Fc = Ra3;
Ma3 = Fc*scLength;
M4(x) = Ma3 - Ra3*x;
beam3MomentEqns = buildBeamEqs({M4}, [0, scLength], E, I);
beam3System = solveAndSubBeamConsts(beam3MomentEqns, BCs);

%% Callable Function Handles
beam1DispHandle = matlabFunction(beam1System{1, 3});
beam2DispHandle = matlabFunction(beam2System{2, 3});
beam3DispHandle = matlabFunction(beam3System{1, 3});

beam1ThetaHandle = matlabFunction(beam1System{1, 2});
beam2ThetaHandle = matlabFunction(beam2System{2, 2});
beam3ThetaHandle = matlabFunction(beam3System{1, 2});

%% Solving for two redundant rollers reaction forces via superposition
eqn1 = 0 == beam1DispHandle(E, I, a) + beam2DispHandle(E, I, Ra2, a) + beam3DispHandle(E, I, Ra3, a);
eqn2 = 0 == beam1DispHandle(E, I, scLength) + beam2DispHandle(E, I, Ra2, scLength) + beam3DispHandle(E, I, Ra3, scLength);
res = solve([eqn1, eqn2], [Ra2, Ra3]);




