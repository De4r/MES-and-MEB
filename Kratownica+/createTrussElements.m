function [elements, localStiffness, localMass, ...
    localStifnessMatrixInGlobalCoord, ...
    localStiffnesMatrixInGlobalCoordAllNodes, ...
    localMassMatrixInGlobalCoord,...
    localMassMatrixInGlobalCoordAllNodes, globalStiffnes, globalMass] =...
    createTrussElements(nodes, elementsNodes, A, E, ro) 
% Funkcja tworz�ca elementy, macierze obrotu DC, macierze sztywno�ci i mas:
% lokalne, lokalne w uk�adzie globlanym, macierz w uk�adzie dla globlanym
% wszystkich w�z��w

% Predefincija macierzy element�w
elements = zeros(length(elementsNodes));

% P�tla przypisuj�ca ka�demu elementowi indeks, wsp�rz�dne, d�ugo��,
% przekr�j, modu� Younga, g�sto��, cosinus i sinus
for i=1:size(elements, 1)
    elements(i,1) = i; %indeks elementu
    elements(i,2) = nodes(elementsNodes(i,1),1); % wspo�. x w�z�a pocz.
    elements(i,3) = nodes(elementsNodes(i,1),2); % wspo�. y w�z�a pocz.
    elements(i,4) = nodes(elementsNodes(i,2),1); % wspo�. x w�z�a ko�.
    elements(i,5) = nodes(elementsNodes(i,2),2); % wspo�. y w�z�a ko�.
    elements(i,6) = sqrt( (elements(i,4)- elements(i,2))^2 +...
        (elements(i,5)- elements(i,3))^2); % dlugo�� elementu
    elements(i,7) = A; % przekr�j
    elements(i,8) = E; % modu� younga
    elements(i,9) = ro; % gesto��
    % Obliczenie sinus�w i kosinus�w dla elementu
    elements(i, 10) = (elements(i,4)- elements(i,2)) / elements( i,6);
    elements(i, 11) = (elements(i,5)- elements(i,3)) / elements( i,6);
end
disp('Utworzono macierz element�w: ');
format shortG
elements
format

% Predefinicja macierzy lokalnych, gloablnych i macierzy DC
localStiffness = zeros(4,4, size(elements, 1));
localDC  = localStiffness;
localStifnessMatrixInGlobalCoord = localStiffness;
localMass = zeros(4,4, size(elements, 1));
localMassMatrixInGlobalCoord = localMass;
 
% Obliczenia macierzy sztywno�ci i mas
 for i=1:size(localStiffness,3)
    % obliczenia sztywnosci
    localStiffness(1,1,i) = 1;
    localStiffness(3,3,i) = 1;
    localStiffness(1,3,i) = -1;
    localStiffness(3,1,i) = -1;
    localStiffness(:,:,i) = localStiffness(:,:,i) * elements(i,7) ...
        * elements(i,8) / elements(i,6); % skalowanie przez AE/l
    % macierz DC dla elementu
    
    tempDC = [ elements(i,10) elements(i,11); ...
        -1*elements(i,11) elements(i,10);];
    localDC(:,:,i) = [tempDC, zeros(2,2); zeros(2,2), tempDC;];
    
    % macierz sztywno�ci po obr�ceniu do uk�adu globalnego
    localStifnessMatrixInGlobalCoord(:,:,i) = ...
        localDC(:,:,i)' * localStiffness(:,:,i) * localDC(:,:,i);
    
    % oblcizenia masowe analogicznie
    localMass(1,1,i) = 2; localMass(2,2,i) = 2;
    localMass(3,3,i) = 2; localMass(4,4,i) = 2;
    localMass(1,3,i) = 1; localMass(2,4,i) = 1; 
    localMass(3,1,i) = 1; localMass(4,2,i) = 1;
    localMass(:,:,i) = localMass(:,:,i) * elements(i,7) *...
        elements(i,9) * elements(i,6) / 6;
    localMassMatrixInGlobalCoord(:,:,i) = localDC(:,:,i)' *...
        localMass(:,:,i) * localDC(:,:,i);
    
 end

% Utworzenie macierzy sztywnosci i mas globalnych dla wszystkich w�z��w
% macierz k0 (4x4) wpisana w 10x10
localStiffnesMatrixInGlobalCoordAllNodes = ...
    zeros(length(nodes)*2, length(nodes)*2, size(localStiffness,3));
localMassMatrixInGlobalCoordAllNodes =...
    localStiffnesMatrixInGlobalCoordAllNodes;

% tyle samo co elementsNodes czyli pr�t�w!
for i=1:size(localStiffnesMatrixInGlobalCoordAllNodes, 3)
    % Brany index z macierzy definuj�cej elementy tzn. pobieramy indeksy
    % wez��w kt�re tworz� akualny element
    % mno�ymy razy 2 bo dla 1 wezla mamy dwie wsp�rz�dne x1,y1
    % indeks wezla pierwszego elementu tj. np. 1 -> x1, y1 
    % czyli kolumna 1,2 i wiersz 1,2 dla 2 w�z�a-> kol. 3, 4 i wier. 3, 4
    tempIndexNode1 = 2*elementsNodes(i, 1) - 1;
    % indeks drugiego wezla elementu
    tempIndexNode2 = 2*elementsNodes(i, 2) - 1;
    % przepisanie p�l macierzy dla indeksow z tego samego wezla np. x1,x1
    localStiffnesMatrixInGlobalCoordAllNodes(tempIndexNode1:tempIndexNode1 + 1,...
        tempIndexNode1:tempIndexNode1 + 1, i) =...
        localStifnessMatrixInGlobalCoord(1:2,1:2,i);
    
    localStiffnesMatrixInGlobalCoordAllNodes(tempIndexNode2:tempIndexNode2 + 1,...
        tempIndexNode2:tempIndexNode2 + 1, i) =...
        localStifnessMatrixInGlobalCoord(3:4,3:4,i);
    
    % przep. p�l macierzy dla indeks�w kombinacyjnych np. x1,y1 lub x2,y3
    localStiffnesMatrixInGlobalCoordAllNodes(tempIndexNode1:tempIndexNode1 + 1,...
        tempIndexNode2:tempIndexNode2 + 1, i) =...
        localStifnessMatrixInGlobalCoord(1:2,3:4,i);
    
    localStiffnesMatrixInGlobalCoordAllNodes(tempIndexNode2:tempIndexNode2 + 1,...
        tempIndexNode1:tempIndexNode1 + 1, i) =...
        localStifnessMatrixInGlobalCoord(3:4,1:2,i);
    
    % dla macierzy mas analogicznie
    localMassMatrixInGlobalCoordAllNodes(tempIndexNode1:tempIndexNode1 + 1, ...
        tempIndexNode1:tempIndexNode1 + 1, i) = ...
        localMassMatrixInGlobalCoord(1:2,1:2,i);
    
    localMassMatrixInGlobalCoordAllNodes(tempIndexNode2:tempIndexNode2 + 1, ...
        tempIndexNode2:tempIndexNode2 + 1, i) = ...
        localMassMatrixInGlobalCoord(3:4,3:4,i);
    
    % przepisanie pol macierzy dla indeksow kombincyjnych np x1 y1 z x2 y3
    localMassMatrixInGlobalCoordAllNodes(tempIndexNode1:tempIndexNode1 + 1, ...
        tempIndexNode2:tempIndexNode2 + 1, i) = ...
        localMassMatrixInGlobalCoord(1:2,3:4,i);
    
    localMassMatrixInGlobalCoordAllNodes(tempIndexNode2:tempIndexNode2 + 1, ...
        tempIndexNode1:tempIndexNode1 + 1, i) = ...
        localMassMatrixInGlobalCoord(3:4,1:2,i);
end

% Agregacja macierzy mas i sztywno�ci
globalStiffnes = sum(localStiffnesMatrixInGlobalCoordAllNodes, 3);
globalMass = sum(localMassMatrixInGlobalCoordAllNodes, 3);

end