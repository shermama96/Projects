function [] = writeNote(outFileID, note)

fprintf(outFileID, 'Note: %s\n', note);

end