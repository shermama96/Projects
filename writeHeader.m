function [] = writeHeader(fileID, tableName, width)
%{
Function that writes the parameter table file header.

Inputs...
fileID: fileID for file to be written to.
width: The width of the parameter table, function of table size (width).
If the table is too thin, a default value is set.
%}
tableName = upper(tableName);
title = tableName;
if width < strlength(title)
    fprintf(fileID, '%s\n', "**********" + title + "**********");
else
    paddingLength = round((width - strlength(title))/2);
    outTitle = repmat('-', 1, paddingLength) + title + repmat('-', 1, paddingLength);
    fprintf(fileID, '\n%s\n', outTitle);
end
end