clear all; close all; clc;
syms x Ra2 Ra3 Mr E I real
cmdHeaderLength = 70;
fileID = fopen('SC_FORCEANALYSIS.txt', 'w');
g = 9.81; %m/s^2
scLength = 2.6; %m
scDistLoad = 30.490*g; %N
antlerMass = 10.5; %Kg
wheelPos1 = 0; %m
wheelPos2 = 1.37;
wheel2WheelSpacing = (scLength - wheelPos2);
rollingFrictionCoeff = .005;
flatBearingLength = .024; % roller to roller distance
roller2RollerSpacing = .008;
rollingResistanceFOS = 2.5;
kFactor = 1.25;
numOfBiasSprings = 4;
BCs = [1, 0, 0; 2, 0, 0];
bearing = setBearingVals('EGIS E-BF5032', 375700, .01, 5.5, 8, 1, 35); % make sure to check factors when changing

%% Actual loadings with zero redundancies
Ma1 = .5*scDistLoad*scLength^2;
M1(x) = scDistLoad*scLength*x - Ma1 - .5*scDistLoad*x^2;
beam1MomentEqns = buildBeamEqs({M1}, [0, scLength], E, I);
beam1System = solveAndSubBeamConsts(beam1MomentEqns, BCs);

%% Roller Support Redundancy at (L)
Fc = Ra3;
Ma3 = Fc*scLength;
M4(x) = Ma3 - Ra3*x;
beam3MomentEqns = buildBeamEqs({M4}, [0, scLength], E, I);
beam3System = solveAndSubBeamConsts(beam3MomentEqns, BCs);

%% Moment Support Redundancy at (L)
Ma4 = -Mr;
M5(x) = Ma4;
beam4MomentEqns = buildBeamEqs({M5}, [0, scLength], E, I);
beam4System = solveAndSubBeamConsts(beam4MomentEqns, BCs);

%% Callable Function Handles
beam1DispHandle = matlabFunction(beam1System{1, 3});
beam3DispHandle = matlabFunction(beam3System{1, 3});
beam4DispHandle = matlabFunction(beam4System{1, 3});

beam1ThetaHandle = matlabFunction(beam1System{1, 2});
beam3ThetaHandle = matlabFunction(beam3System{1, 2});
beam4ThetaHandle = matlabFunction(beam4System{1, 2});

%% Solving for redundant reactions via superposition
eqn1 = 0 == beam1DispHandle(E, I, scLength) + beam3DispHandle(E, I, Ra3, scLength) + ...
    beam4DispHandle(E, I, Mr, scLength);
eqn2 = 0 == beam1ThetaHandle(E, I, scLength) + beam3ThetaHandle(E, I, Ra3, scLength) + ...
    beam4ThetaHandle(E, I, Mr, scLength);
res = solve([eqn1, eqn2], [Ra3, Mr]);

globalWheelMoment = double(res.Mr); % total moment carried by qty:4 wheels (not per wheel)
globalWheelReaction = double(res.Ra3); % total reaction carried by qty:4 wheels (not per wheel)


%% Solving for per wheel loads
momentInducedPointLoadPerWheel = globalWheelMoment/wheel2WheelSpacing/4; % recall: 2 bearing in tension, 2 in compression
reactionPerWheel = globalWheelReaction/4; % reaction carried by lower 2 wheels (qty: 4)
highLoadWheelForce = reactionPerWheel + momentInducedPointLoadPerWheel;
lowLoadWheelForce = reactionPerWheel - momentInducedPointLoadPerWheel;
wheelSideFrictForce = 2*rollingFrictionCoeff*(highLoadWheelForce + lowLoadWheelForce);

%% Solving for XYZ Mechanism Loading
XYZMechMomentLoad = globalWheelMoment + globalWheelReaction*scLength - .5*scDistLoad*scLength^2;
XYZMechTransverseLoad = antlerMass*g + scDistLoad*scLength - globalWheelReaction;
normalForceAtRollers = calcBearingLoadDist(XYZMechMomentLoad, bearing.preload, XYZMechTransverseLoad, roller2RollerSpacing);
XYZMechSideFrictForce = 2*rollingFrictionCoeff*sum(normalForceAtRollers);
totalRollingResistance = kFactor * (XYZMechSideFrictForce + wheelSideFrictForce);
perSpringReqForce = (1/numOfBiasSprings)*totalRollingResistance;

%% Optimizing Spring Geometry
fileName = "SERVICE CYLINDER AXIAL BIAS SPRING SIZING";
showResultQTY = 100;
objective = "minimize spring constant"; constraints = ["minimum force requirements", "shear failure"];
material = "302 STAINLESS STEEL";
lowerCoilLimit = 3; upperCoilLimit = 20;
lowerOuterDiameterLimit = 5; upperOuterDiameterLimit = 12.5;
lowerFreeLengthLimit = 15; upperFreeLengthLimit = 70;
shearMod = 77.2E9;
requiredTravel = .005;
minRequiredForce = 111/2;
factorOfSafety = 1;
springOptimizer(fileName, showResultQTY, objective, constraints, material, ...
    [lowerCoilLimit, upperCoilLimit], [lowerOuterDiameterLimit, upperOuterDiameterLimit], ...
    [lowerFreeLengthLimit, upperFreeLengthLimit], shearMod, requiredTravel, ...
    perSpringReqForce, factorOfSafety);

%% Double check closest available spring parameters
spring.mfg = "McMaster";
spring.PN = "3492N24";
spring.rate = 4.136; %N/mm
spring.freeLength = 29.5;
spring.outerDiameter = 11.25;
spring.wireDiameter = 1.25;
spring.maxLoad = 83.315;
spring.maxLoadHeight = 9.38;
spring.maxDelta = spring.freeLength - spring.maxLoadHeight;
spring.minForceHeight = perSpringReqForce/(spring.rate);
spring.totalRequiredDelta = spring.minForceHeight + (requiredTravel*1000);

if spring.totalRequiredDelta > spring.maxDelta
    fprintf("THE SELECTED SPRING IS NOT A VIABLE OPTION!!!\n")
end

%% Writing output data
cmdHeader(fileID, "wheel-side support reactions", cmdHeaderLength)
fprintf(fileID, "FORCE REACTION: %.2fN\n", globalWheelReaction);
fprintf(fileID, "MOMENT REACTION: %.2fNm\n", globalWheelMoment);

cmdHeader(fileID, "(wheel-side) per wheel reactions", cmdHeaderLength)
fprintf(fileID, "LOW LOAD WHEEL REACTION: %.2fN\n", lowLoadWheelForce);
fprintf(fileID, "HIGH LOAD WHEEL REACTION: %.2fN\n", highLoadWheelForce);

cmdHeader(fileID, "xyz-mechanism-side support reactions", cmdHeaderLength);
fprintf(fileID, "AT MECHANISM TRANSVERSE LOAD: %.2fN\n", XYZMechTransverseLoad);
fprintf(fileID, "AT MECHANISM MOMENT LOAD: %.2fNm\n", XYZMechMomentLoad);
fprintf(fileID, "AT MECHANISM TRANSVERSE LOAD (W/ Kf: %.2f): %.2fN\n", kFactor, kFactor*XYZMechTransverseLoad);
fprintf(fileID, "AT MECHANISM MOMENT LOAD (W/ Kf: %.2f): %.2fNm\n", kFactor, kFactor*XYZMechMomentLoad);

cmdHeader(fileID, "xyz-mechanism-side roller force/stress data", cmdHeaderLength);
fprintf(fileID, "APPROXIMATE STATIC LOAD RATING FROM EGIS DATASHEET (OVERALL BEARING): %.1fN\n", bearing.lengthLoadRating);
fprintf(fileID, "PRELOAD AS A PERCENTAGE OF STATIC LOAD RATING (OVERALL BEARING): %.1fN (%.1f%%)\n", bearing.preload, 100*bearing.preloadPercentage);
fprintf(fileID, "NEGATIVE PHYSICAL OFFSET TO PRODUCE PRELOAD: XXX MICRONS\n");
fprintf(fileID, "NORMAL FORCE AT BEARING ROLLER %.0d -- BASED ON QUADRATIC FORCE DISTRIBUTION: %.3fN\n", [1:4; normalForceAtRollers]);

cmdHeader(fileID, "rolling resistance data", cmdHeaderLength)
fprintf(fileID, "WHEEL-SIDE ROLLING RESISTANCE (W/ Cr: %.3f): %.2fN\n", rollingFrictionCoeff, wheelSideFrictForce);
fprintf(fileID, "WHEEL-SIDE ROLLING RESISTANCE (W/ Cr: %.3f, W/ Kf: %.2f): %.2fN\n", rollingFrictionCoeff, ...
    kFactor, kFactor*wheelSideFrictForce);
fprintf(fileID, "XYZ-MECHANISM-SIDE ROLLING RESISTANCE (W/ Cr: %.3f): %.2fN\n", rollingFrictionCoeff, XYZMechSideFrictForce);
fprintf(fileID, "XYZ-MECHANISM-SIDE ROLLING RESISTANCE (W/ Cr: %.3f, W/ Kf: %.2f): %.2fN\n", rollingFrictionCoeff, ...
    kFactor, kFactor*XYZMechSideFrictForce);
fprintf(fileID, "TOTAL SERVICE CYLINDER ROLLING RESISTANCE (W/ Cr: %.3f, W/ Kf: %.2f): %.2fN\n", rollingFrictionCoeff, ...
    kFactor, totalRollingResistance);
fprintf(fileID, "MINIMUM PER SPRING FORCE (W/ QTY: %.0d SPRINGS W/ Cr: %.3f, W/ Kf: %.2f): %.2fN\n", numOfBiasSprings, rollingFrictionCoeff, ...
    kFactor, perSpringReqForce);

writeTail(fileID);
fclose(fileID);