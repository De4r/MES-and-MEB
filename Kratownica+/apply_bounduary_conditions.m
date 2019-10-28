function global_property_matrix = apply_bounduary_conditions(global_property_matrix, supports)
% Funkcja nak³adaj¹ca warunki brzegowe na macierz sztywnoœci lub masy
% wed³ug regu³y podanej w pliku kratownica -> MODYFIKACJ MACIERZY SZTYWNOSCI
% Podpory oraz kierunek podpory definowane w parach liczb
% Opcje: 1: x+y (nieprzesuwna), 2: y (pozioma przesuwna), 3: x (pionowa przesuwna)
% format: [wezel, typ; wezel, typ; ...]

for i=1:size(supports,1)
    temp_index = 2*supports(i,1)-1;
    if supports(i,2) == 1
        global_property_matrix(temp_index:temp_index + 1, :) = 0;
        global_property_matrix(:, temp_index:temp_index + 1) = 0;
        global_property_matrix(temp_index, temp_index) = 1;
        global_property_matrix(temp_index + 1, temp_index + 1) = 1;
    elseif supports(i,2) == 2 % dla y
        global_property_matrix(temp_index + 1, :) = 0;
        global_property_matrix(:, temp_index + 1) = 0;
        global_property_matrix(temp_index + 1, temp_index + 1) = 1;
    elseif supports(i,2) == 3 % dla x
        global_property_matrix(temp_index, :) = 0;
        global_property_matrix(:, temp_index) = 0;
        global_property_matrix(temp_index, temp_index) = 1;
    else
        disp('Nie poprawny typ podpory');
    end
end

end