function [] = cmdHeader(fileID, header, width)
%{
Function that writes header for a block of information in the command line
or to a text file.

Inputs...
fileID: (numeric) found using fopen, used to write to a text file
header: (string) the actual header text
width: (numeric) total width of header padded with dashes
%}
header = upper(header);
if isempty(fileID)
    if width < strlength(header)
        fprintf('%s\n', "-------------" + header + "-------------");
    else
        paddingLength = round((width - strlength(header))/2);
        outTitle = repmat('-', 1, paddingLength) + header + repmat('-', 1, paddingLength);
        fprintf('\n%s\n', outTitle);
    end
else
    if width < strlength(header)
        fprintf(fileID, '%s\n', "-------------" + header + "-------------");
    else
        paddingLength = round((width - strlength(header))/2);
        outTitle = repmat('-', 1, paddingLength) + header + repmat('-', 1, paddingLength);
        fprintf(fileID, '\n%s\n', outTitle);
    end
end
end