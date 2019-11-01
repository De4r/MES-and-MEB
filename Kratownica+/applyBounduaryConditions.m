function globalPropertyMatrx = applyBounduaryConditions(globalPropertyMatrx, supportsDefinitions)
% Funkcja nak³adaj¹ca warunki brzegowe na macierz sztywnoœci lub masy
% wed³ug regu³y podanej w pliku kratownica -> MODYFIKACJ MACIERZY SZTYWNOSCI
% Podpory oraz kierunek podpory definowane w parach liczb
% Opcje: 1: x+y (nieprzesuwna), 2: y (pozioma przesuwna), 3: x (pionowa przesuwna)
% format: [wezel, typ; wezel, typ; ...]

for i=1:size(supportsDefinitions,1)
    tempIndex = 2*supportsDefinitions(i,1)-1;
    if supportsDefinitions(i,2) == 1
        globalPropertyMatrx(tempIndex:tempIndex + 1, :) = 0;
        globalPropertyMatrx(:, tempIndex:tempIndex + 1) = 0;
        globalPropertyMatrx(tempIndex, tempIndex) = 1;
        globalPropertyMatrx(tempIndex + 1, tempIndex + 1) = 1;
    elseif supportsDefinitions(i,2) == 2 % dla y
        globalPropertyMatrx(tempIndex + 1, :) = 0;
        globalPropertyMatrx(:, tempIndex + 1) = 0;
        globalPropertyMatrx(tempIndex + 1, tempIndex + 1) = 1;
    elseif supportsDefinitions(i,2) == 3 % dla x
        globalPropertyMatrx(tempIndex, :) = 0;
        globalPropertyMatrx(:, tempIndex) = 0;
        globalPropertyMatrx(tempIndex, tempIndex) = 1;
    else
        disp('Nie poprawny typ podpory');
    end
end

end