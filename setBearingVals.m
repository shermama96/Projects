function bearingStruct = setBearingVals(partNum, nomLoadRating, preloadPercentage, spaceToEdge, rollSpace, hardFactor, bearingLength)
%{
Clean way of building struct that tracks the bearing selected by designer

Input...
partNum: (string) part number from manufacturer
preloadPercenage: (double) percentage of static load rating for preload
spaceToEdge: (double) distance between edge of bearing and first roller
used to approximate static load carrying capacity
rollspace: (double) distance between each roller
hardFactor: (double) read from EGIS datasheet, used to reduce static load
carrying capacity of joint based on devation for 60-62HRC surface hardness
bearingLength: (double) overall length of bearing

bearingStruct: (struct) a struct capturing all useful bearing info
%}
nomRatingAtLength = hardFactor*nomLoadRating*((bearingLength - (2*spaceToEdge) + rollSpace)/100);
bearingStruct.lengthLoadRating = nomRatingAtLength;
bearingStruct.preloadPercentage = preloadPercentage;
bearingStruct.preload = preloadPercentage*nomRatingAtLength;
bearingStruct.nomLoadRating = nomLoadRating;
bearingStruct.length = bearingLength;
bearingStruct.PN = partNum;
end