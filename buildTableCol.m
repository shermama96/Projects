function res = buildTableCol(stringVector)
%{
function builds a column of of an output table and pads with spacing
Inputs...
stringVector: an nx1 vector of strings, numeric types should also be
converted to strings vector.
Outputs...
res: A string vector that is padded to center title, and bias remaining
data. A seperator is added between the title and data.

%}
pad = ceil(max(strlength(stringVector)) * .15);
colWidth = max(strlength(stringVector)) + pad;
for i = 1:length(stringVector)
    if i == 1
        offset = floor((colWidth - strlength(stringVector(i)))/2);
    else
        offset = floor(pad/2);
    end
    
    if isempty(str2double(stringVector(i))) == false && str2double(stringVector(i)) < 0
        offset = offset - 1;
    end
    
    tempString(i) = repmat(' ', 1, offset) + stringVector(i) +...
        repmat(' ', 1, abs(colWidth - offset - strlength(stringVector(i))));
end
temp = tempString(2:end);
res = [tempString(1); string(repmat('-', 1, colWidth)); temp'];
res = res + repmat(' ', length(res), 5);
end