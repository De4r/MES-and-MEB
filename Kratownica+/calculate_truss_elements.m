function [elements, local_stiffness, local_stiffness_in_global, local_stiffness_in_global_2, local_mass_in_global, local_mass_in_global_2, global_stiffness, global_mass] = calculate_truss_elements(nodes, elements_nodes, A, E, ro) 
% Funkcja tworz�ca elementy, macierze obrotu DC, macierze sztywno�ci i mas:
% lokalne, lokalne w uk�adzie globlanym, macierz w uk�adzie dla globlanym
% wszystkich w�z��w

% Predefincija macierzy element�w
elements = zeros(length(elements_nodes));

% P�tla przypisuj�ca ka�demu elementowi indeks, wsp�rz�dne, d�ugo��,
% przekr�j, modu� Younga, g�sto��, cosinus i sinus
for i=1:size(elements, 1)
    elements(i,1) = i; %indeks elementu
    elements(i,2) = nodes(elements_nodes(i,1),1); % wspo�. x w�z�a pocz.
    elements(i,3) = nodes(elements_nodes(i,1),2); % wspo�. y w�z�a pocz.
    elements(i,4) = nodes(elements_nodes(i,2),1); % wspo�. x w�z�a ko�.
    elements(i,5) = nodes(elements_nodes(i,2),2); % wspo�. y w�z�a ko�.
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
local_stiffness = zeros(4,4, size(elements, 1));
local_DC  = local_stiffness;
local_stiffness_in_global = local_stiffness;
local_mass = zeros(4,4, size(elements, 1));
local_mass_in_global = local_mass;
 
% Obliczenia macierzy sztywno�ci i mas
 for i=1:size(local_stiffness,3)
    % obliczenia sztywnosci
    local_stiffness(1,1,i) = 1;
    local_stiffness(3,3,i) = 1;
    local_stiffness(1,3,i) = -1;
    local_stiffness(3,1,i) = -1;
    local_stiffness(:,:,i) = local_stiffness(:,:,i) * elements(i,7) * elements(i,8) / elements(i,6); % skalowanie przez AE/l
    % macierz DC dla elementu
    temp_DC = [ elements(i,10) elements(i,11); -1*elements(i,11) elements(i,10);];
    local_DC(:,:,i) = [temp_DC, zeros(2,2); zeros(2,2), temp_DC;];
    % macierz sztywno�ci po obr�ceniu do uk�adu globalnego
    local_stiffness_in_global(:,:,i) = local_DC(:,:,i)' * local_stiffness(:,:,i) * local_DC(:,:,i);
    
    % oblcizenia masowe analogicznie
    local_mass(1,1,i) = 2; local_mass(2,2,i) = 2; local_mass(3,3,i) = 2; local_mass(4,4,i) = 2;
    local_mass(1,3,i) = 1; local_mass(2,4,i) = 1; local_mass(3,1,i) = 1; local_mass(4,2,i) = 1;
    local_mass(:,:,i) = local_mass(:,:,i) * elements(i,7) * elements(i,9) * elements(i,6) / 6;
    local_mass_in_global(:,:,i) = local_DC(:,:,i)' * local_mass(:,:,i) * local_DC(:,:,i);
    
 end

% Utworzenie macierzy sztywnosci i mas globalnych dla wszystkich w�z��w
local_stiffness_in_global_2 = zeros(length(nodes)*2, length(nodes)*2, size(local_stiffness,3)); % macierz k0 (4x4) wpisana w 10x10
local_mass_in_global_2 = local_stiffness_in_global_2;

for i=1:size(local_stiffness_in_global_2, 3) % tyle samo co elements_nodes czyli pr�t�w!
    % Brany index z macierzy definuj�cej elementy tzn. pobieramy indeksy
    % wez��w kt�re tworz� akualny element
    % mno�ymy razy 2 bo dla 1 wezla mamy dwie wsp�rz�dne x1,y1
    % indeks wezla pierwszego elementu tj. np. 1 -> x1, y1 
    % czyli kolumna 1,2 i wiersz 1,2 dla 2 w�z�a-> kol. 3, 4 i wier. 3, 4
    temp_index_node_1 = 2*elements_nodes(i, 1) - 1;
    % indeks drugiego wezla elementu
    temp_index_node_2 = 2*elements_nodes(i, 2) - 1;
    % przepisanie p�l macierzy dla indeksow z tego samego wezla np. x1,x1
    local_stiffness_in_global_2(temp_index_node_1:temp_index_node_1 + 1,...
        temp_index_node_1:temp_index_node_1 + 1, i) =...
        local_stiffness_in_global(1:2,1:2,i); 
    local_stiffness_in_global_2(temp_index_node_2:temp_index_node_2 + 1,...
        temp_index_node_2:temp_index_node_2 + 1, i) =...
        local_stiffness_in_global(3:4,3:4,i);
    % przep. p�l macierzy dla indeks�w kombinacyjnych np. x1,y1 lub x2,y3
    local_stiffness_in_global_2(temp_index_node_1:temp_index_node_1 + 1,...
        temp_index_node_2:temp_index_node_2 + 1, i) =...
        local_stiffness_in_global(1:2,3:4,i); 
    local_stiffness_in_global_2(temp_index_node_2:temp_index_node_2 + 1,...
        temp_index_node_1:temp_index_node_1 + 1, i) =...
        local_stiffness_in_global(3:4,1:2,i);
    
    % dla macierzy mas analogicznie
    local_mass_in_global_2(temp_index_node_1:temp_index_node_1 + 1, ...
        temp_index_node_1:temp_index_node_1 + 1, i) = ...
        local_mass_in_global(1:2,1:2,i); 
    local_mass_in_global_2(temp_index_node_2:temp_index_node_2 + 1, ...
        temp_index_node_2:temp_index_node_2 + 1, i) = ...
        local_mass_in_global(3:4,3:4,i);
    % przepisanie pol macierzy dla indeksow kombincyjnych np x1 y1 z x2 y3
    local_mass_in_global_2(temp_index_node_1:temp_index_node_1 + 1, ...
        temp_index_node_2:temp_index_node_2 + 1, i) = ...
        local_mass_in_global(1:2,3:4,i); 
    local_mass_in_global_2(temp_index_node_2:temp_index_node_2 + 1, ...
        temp_index_node_1:temp_index_node_1 + 1, i) = ...
        local_mass_in_global(3:4,1:2,i);
end

% Agregacja macierzy mas i sztywno�ci
global_stiffness = sum(local_stiffness_in_global_2, 3);
global_mass = sum(local_mass_in_global_2, 3);

end