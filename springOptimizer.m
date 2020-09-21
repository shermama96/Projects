function [] = springOptimizer(fileName, showResultQTY, objective, constraints, material, coilLimits, ...
    outerDiameterLimits, freeLengthLimits, shearMod, requiredTravel, minRequiredForce, FOS)
%{
**************************
USE ONLY for 302SS SPRINGS
**************************
    
TODO: upgrade to sort by any output parameter. In its current state the
function brute forces a spring optimization by sweeping input parameters
and "minimizing" an objective. Really it just sorts the resulting data
sequentially by a particular output parameter, in this case, the "spring
constant" parameter is the sorting variable. 

Inputs...
fileName: string to write output table to text file
    showResultQTY: (integer) dictates how many output entries to write to
    output table
    objective: string used to write objective to text file
    constraints: string used to write constrains to text file
    material: string used to write material to text file
    coilLimts: 2 entry array for upper and lower limit of active coil count
    outerDiameterLimits: 2 entry array for upper and lower limit of spring
    outer diameter
    freeLengthLimits: 2 entry array for upper and lower limit spring free
    length
    shearMod: material shear modulus
    requiredTravel: amount of travel required by spring in use
    minRequiredForce: minimum operating force needed to be produced by
    spring
    FOS: FOS used against shear stress failure
%}

wireDiameter = [.305, .330, .356, .381,...
    .406, .432, .457, .483, .508, .533, .559, .584, .610, .635,...
    .660, .686, .711, .737, .762, .787, .813, .838, .864, .889,...
    .914, .940, .965, .991, 1.016, 1.041, 1.067, 1.092, 1.118,...
    1.143, 1.168, 1.194, 1.219, 1.225, 1.270, 1.296, 1.321, 1.346,...
    1.372, 1.397, 1.422, 1.448, 1.473, 1.499, 1.524, 1.549, 1.588,...
    1.6, 1.626, 1.651, 1.676, 1.702, 1.727, 1.778, 1.803, 1.829,...
    1.854, 1.880, 1.905, 1.930, 1.981, 2.007, 2.032, 2.057, 2.083,...
    2.108, 2.134, 2.159, 2.184, 2.210]./1000; %mm
numCoils = [coilLimits(1):setStep(coilLimits(1), coilLimits(2)):coilLimits(2)];
outerDiameter = [outerDiameterLimits(1):setStep(outerDiameterLimits(1), outerDiameterLimits(2)):...
    outerDiameterLimits(2)]./1000; %mm
freeLength = [freeLengthLimits(1):setStep(freeLengthLimits(1), freeLengthLimits(2)):...
    freeLengthLimits(2)]./1000; %mm
totalNumOfSprings = length(wireDiameter)*length(numCoils)*length(outerDiameter)*length(freeLength);
idx = 1;
tic;
for i = 1:length(wireDiameter) % wire thickness loop
    % ***************************************************************
    % THE IF STATEMENT BELOW HAS VALUES THAT ONLY APPLY TO 302SS!!!!!
    % ***************************************************************
    if wireDiameter(i) >= .0003 && wireDiameter(i) <= .0025
        A = 1867E6;
        m = .146;
    elseif wireDiameter(i) > .0025 && wireDiameter(i) <= .005
        A = 2065E6;
        m = .263;
    elseif wireDiameter(i) > .005 && wireDiameter(i) <= .010
        A = 2911E6;
        m = .478;
    else
        A = 0; fprintf('Invalid wire diameter!\n');
    end
    ultimateStrength = A/wireDiameter(i)^m;
    stressFailureCriteria = .75*.65*ultimateStrength; %yield as 80 percent of ult, and max as 65 percent of yields
    for j = 1:length(numCoils) % number of active coils
        for k = 1:length(outerDiameter) % size of outer diameter
            for m = 1:length(freeLength) % free length
                meanDiameter = (outerDiameter(k) + (outerDiameter(k) - 2*wireDiameter(i)))/2;
                slenderRatio = freeLength(m)/meanDiameter;
                springIndex = meanDiameter/wireDiameter(i);
                bottomHeight = numCoils(j)*wireDiameter(i);
                clashClearance = bottomHeight*.1;
                maxDelta = round(freeLength(m) - (bottomHeight + clashClearance), 8);
                if maxDelta >= requiredTravel && springIndex >= 4 ...
                        && springIndex <= 10 && slenderRatio <= 4.5 % check if the spring can even displace the minimum required travel and if it can be made
                    springConstant = (shearMod*wireDiameter(i))/(8*numCoils(j)*springIndex^3);
                    deltaAtMinReqForce = minRequiredForce/springConstant;
                    if maxDelta >= deltaAtMinReqForce + requiredTravel % check if the spring can actually produce the required force
                        staticWahlFactor = 1 + (.5/springIndex);
                        forceAtFullTravel = springConstant*(deltaAtMinReqForce + requiredTravel);
                        maxRequiredStress = (8*forceAtFullTravel*springIndex*staticWahlFactor)/(pi*wireDiameter(i)^2);
                        if maxRequiredStress <= (stressFailureCriteria)/(FOS)
                            spring(idx).wireDiameter = wireDiameter(i)*1000;
                            spring(idx).numberOfCoils = numCoils(j);
                            spring(idx).outerDiameter = outerDiameter(k)*1000;
                            spring(idx).freeLength = freeLength(m)*1000;
                            spring(idx).springConstant = springConstant/1000;
                            spring(idx).springIndex = springIndex;
                            spring(idx).slenderRatio = freeLength(m)/meanDiameter;
                            spring(idx).minDeltaToMeetForce = deltaAtMinReqForce*1000;
                            spring(idx).minDeltaPlusTravel = (deltaAtMinReqForce + requiredTravel)*1000;
                            spring(idx).deltaToClashHeight = maxDelta*1000;
                            spring(idx).alottedClashClearance = clashClearance*1000;
                            spring(idx).totalClearance = (maxDelta - deltaAtMinReqForce - requiredTravel + clashClearance)*1000;
                            spring(idx).forceAtMinTravel = springConstant*deltaAtMinReqForce;
                            spring(idx).forceAtFullTravel = forceAtFullTravel;
                            spring(idx).clashHeightForce = springConstant*maxDelta;
                            spring(idx).maxStress = maxRequiredStress*10^-6;
                            spring(idx).fosAtEndOfTravel = (stressFailureCriteria)/maxRequiredStress;
                            idx = idx + 1;
                            if mod(idx, 10000) == 0
                                fprintf("%.0f VIABLE SPRINGS COMPLETED\n", idx)
                            end
                        end
                    end
                end
            end
        end
    end
end

elapsedTime = toc;

tempTable = struct2table(spring);
sortedTable = sortrows(tempTable, 'springConstant');
spring = table2struct(sortedTable);
springMatrix = table2array(sortedTable);
colNames = string(fieldnames(spring)');

fileID = fopen(fileName + ".txt", 'wt');
fprintf(fileID, "UNITS: N-mm-MPa-Kg\n");
fprintf(fileID, "OBJECTIVE: %s\n", upper(objective));
fprintf(fileID, "CONSTRAINT: %s\n", upper(constraints));
fprintf(fileID, "MATERIAL: %s\n", upper(material));
fprintf(fileID, "NUMER OF ITERATIONS COMPLETE: %.0f\n", totalNumOfSprings);
fprintf(fileID, "NUMBER OF ITERATIONS YIELDING VIABLE SPRINGS: %.0f (%.2f%%)\n", length(spring), length(spring)/totalNumOfSprings*100);
fprintf(fileID, "TOTAL ELAPSED TIME: %.2f SECONDS\n", elapsedTime);
writeTable(springMatrix(1:showResultQTY, :), colNames, fileName + " Optimization -- Showing Results 1 thru " + string(showResultQTY), fileID);
writeTail(fileID);
fclose(fileID);
fprintf("SPRING OPTIMIZATION COMPLETE...\n");
end
