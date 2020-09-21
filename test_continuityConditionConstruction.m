clear all; close all; clc;
syms C1 C2 C3 C4
syms x real positive
a = 5*12;
L = 15*12;
b = L-a;
E = 29E6;
P = 35E3;
I = 291;

M1(x) = (P/L)*b*x;
M2(x) = (P/L)*(b*x - L*(x - a));
BCs = [2, 0, 0; 2, L, 0];

res = buildBeamEqs({M1, M2}, [0, a; a, L], E, I);
test = solveAndSubBeamConsts(res, BCs);
test2 = evalBeam(test, a, argnames(M1));
