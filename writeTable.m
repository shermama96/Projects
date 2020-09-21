function [] = writeTable(data, columnNames, tableName, outFileID)
%{
Function writes the parameter table to a text file.
Inputs...
data: The parameter data to be written to the text file. mxn matrix of data
(string type) to be converted into columns then stitched into a table

Inputs...
data: mxn matrix of data (string type) to be converted into columns then 
stitched into a table.
columnNames: Names of each table column in sequential order, vector of
string types.
outFileID: File ID for text file to be written to.
%}
res = repmat(' ', size(data, 1) + 2, 1);
for i = 1:length(columnNames)
    tempCol = buildTableCol([columnNames(i); string(data(:, i))]);
    res = res + tempCol;
end

writeHeader(outFileID, tableName, strlength(res(1)) - 5);
fprintf(outFileID, '%s\n', res);

end