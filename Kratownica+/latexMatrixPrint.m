function latexMatrixPrint(matrix, precision, filename)



    
if precision ~=0
    
    latex_table = latex(vpa(sym(matrix), precision))
    
else
    
    latex_table = latex(sym(matrix))
    
end
fid = fopen(filename, 'w');
fprintf(fid, latex_table);
fclose(fid);