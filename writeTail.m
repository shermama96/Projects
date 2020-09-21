function [] = writeTail(fileID)
fprintf(fileID, '\nOutput file generated at: %s\n', datetime('now'));
fprintf(fileID, 'Current Directory: %s\n\n', pwd);
end