function global_stiffness = apply_bounduary_conditions(global_stiffness, supports)
%funkcja nak³adaj¹ca warunki brzegowe na macierz sztywnoœci
for i=1:size(supports,1)
    temp_index = 2*supports(i,1)-1;
    if supports(i,2) == 1
        global_stiffness(temp_index:temp_index + 1, :) = 0;
        global_stiffness(:, temp_index:temp_index + 1) = 0;
        global_stiffness(temp_index, temp_index) = 1;
        global_stiffness(temp_index + 1, temp_index + 1) = 1;
    elseif supports(i,2) == 2 % dla y
        global_stiffness(temp_index + 1, :) = 0;
        global_stiffness(:, temp_index + 1) = 0;
        global_stiffness(temp_index + 1, temp_index + 1) = 1;
    elseif supports(i,2) == 3 % dla x
        global_stiffness(temp_index, :) = 0;
        global_stiffness(:, temp_index) = 0;
        global_stiffness(temp_index, temp_index) = 1;
    else
        disp('Nie poprawny typ podpory');
    end
end

end