clear all; close all; clc;
syms x real positive

% ------------------------------
% ----------TEST CASE 1---------
% ------------------------------

a = 5*12;
L = 15*12;
b = L-a;
E = 29E6;
P = 35E3;
I = 291;

M1(x) = (P/L)*b*x;
M2(x) = (P/L)*(b*x - L*(x - a));
BCs = [2, 0, 0; 2, L, 0];

tempEqns = buildBeamEqs({M1, M2}, [0, a; a, L], E, I);
tempRes = solveAndSubBeamConsts(tempEqns, BCs);
tempEval = evalBeam(tempRes, a, argnames(M1));
fprintf("ACTUAL DEFLECTION: %.4f\n", -.398);

% ------------------------------
% ----------TEST CASE 2---------
% ------------------------------

a = 2;
w = 50E3;
L = 6;
E = 200E9;
I = 84.9E-6;
Ra = (5/6)*w*a;
Rb = (1/6)*w*a;

M1(x) = Ra*x - .5*w*x^2;
M2(x) = Rb*(L - x);
BCs = [2, 0, 0; 2, L, 0];

tempEqns = buildBeamEqs({M1, M2}, [0, a; a, L], E, I);
tempRes = solveAndSubBeamConsts(tempEqns, BCs);
tempEval = evalBeam(tempRes, a, argnames(M1));
fprintf("ACTUAL DEFLECTION: %.4f\n", -.0118);

% ------------------------------
% ----------TEST CASE 3---------
% ------------------------------
% CONTINUATION OF PREVIOUS TEST
tempEval = evalBeam(tempRes, 0, argnames(M1));
fprintf("ACTUAL SLOPE: %.4f\n", -8.18E-3);

% ------------------------------
% ----------TEST CASE 4---------
% ------------------------------
a = 1.2;
M0 = 60E3;
L = 4.8;
E = 200E9;
I = 34.4E-6;

M1(x) = (M0/L)*x;
M2(x) = (M0/L)*(x - L);
BCs = [2, 0, 0; 2, L, 0];

tempEqns = buildBeamEqs({M1, M2}, [0, a; a, L], E, I);
tempRes = solveAndSubBeamConsts(tempEqns, BCs);
tempEval = evalBeam(tempRes, a, argnames(M1));
fprintf("ACTUAL DEFLECTION: %.4f\n", .00628);

% ------------------------------
% ----------TEST CASE 5---------
% ------------------------------

syms E1 I1 L real positive
syms Ra M0 real

M1(x) = Ra*x - M0;
BCs = [2, 0, 0; 2, L, 0];

tempEqns = buildBeamEqs({M1}, [0, L], E1, I1);
tempRes = solveAndSubBeamConsts(tempEqns, BCs);
valRa = solve(0 == subs(tempRes{1, 2}, x, L), Ra);
cmdHeader("Redundant Support Results", 55);
fprintf("SOLVING FOR RA YIELDS: %s\n", string(valRa));
fprintf("THE ACTUAL VALUE OF RA: %s\n", string((3/2)*(M0/L)));