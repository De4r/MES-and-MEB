function [elements, local_stiffness, local_stiffness_in_global, local_stiffness_in_global_2, global_stiffness] = calculate_truss_elements(nodes, elements_nodes, A, E, ro) 
% funkcja tworz¹ca elementy oraz wynaczaj¹ca ich paramettry
% funkcja tworzy macierze sztywnoœci lokalne i globalne

elements = zeros(length(elements_nodes));

for i=1:size(elements, 1)
    elements(i,1) = i; %indeks elementu
    elements(i,2) = nodes(elements_nodes(i,1),1); % wspo³rzêdna wêz³a x1
    elements(i,3) = nodes(elements_nodes(i,1),2); % wspo³rzêdna wêz³a y1
    elements(i,4) = nodes(elements_nodes(i,2),1); % wspo³rzêdna wêz³a x2
    elements(i,5) = nodes(elements_nodes(i,2),2); % wspo³rzêdna wêz³a y2
    elements(i,6) = sqrt( (elements(i,4)- elements(i,2))^2 + (elements(i,5)- elements(i,3))^2); % dlugosc
    elements(i,7) = A; % przekrój
    elements(i,8) = E; % modu³ younga
    elements(i,9) = ro; % gestoœæ
    elements(i, 10) = (elements(i,4)- elements(i,2)) / elements( i,6); % cos fi
    elements(i, 11) = (elements(i,5)- elements(i,3)) / elements( i,6); % sin fi
    
end
 % Macierz lokalna i jej macierz DC 
 local_stiffness = zeros(4,4, size(elements, 1));
 local_DC  = local_stiffness; % zeros(4,4, size(elements, 1));
 local_stiffness_in_global = local_stiffness;
  
 for i=1:size(local_stiffness,3)
    local_stiffness(1,1,i) = 1;
    local_stiffness(3,3,i) = 1;
    local_stiffness(1,3,i) = -1;
    local_stiffness(3,1,i) = -1;
    local_stiffness(:,:,i) = local_stiffness(:,:,i) * elements(i,7) * elements(i,8) / elements(i,6); % skalowanie przez AE/l
    % macierz DC
    temp_DC = [ elements(i,10) elements(i,11); -1*elements(i,11) elements(i,10);];
    local_DC(:,:,i) = [temp_DC, zeros(2,2); zeros(2,2), temp_DC;];
    
    local_stiffness_in_global(:,:,i) = local_DC(:,:,i)' * local_stiffness(:,:,i) * local_DC(:,:,i);
 end

local_stiffness_in_global_2 = zeros(length(nodes)*2, length(nodes)*2, size(local_stiffness,3)); % macierz k0 (4x4) wpisana w 10x10
for i=1:size(local_stiffness_in_global_2, 3) % tyle samo co elements_nodes czyli prêtów!
    % bierzemy index z macierzy definuj¹cej l¹czenie indeksów wez³ów ->
    % mno¿ymy razy 2 bo dla 1 wezla mamy x1,y1, dla 2 wezla x2 y2
    temp_index_node_1 = 2*elements_nodes(i, 1) - 1; % indeks wezla pierwszego elementu tj. np. 1 -> x1, y1 czyli kolumna 1,2 i wiersz 1,2 dl a 2-> koluman 3, 4 i wiersz 3, 4
    temp_index_node_2 = 2*elements_nodes(i, 2) - 1; % indeks 2 wezla elementu
    % przepisanie pol macierzy dla indeksow tego samego wezla
    local_stiffness_in_global_2(temp_index_node_1:temp_index_node_1 + 1, temp_index_node_1:temp_index_node_1 + 1, i) = local_stiffness_in_global(1:2,1:2,i); 
    local_stiffness_in_global_2(temp_index_node_2:temp_index_node_2 + 1, temp_index_node_2:temp_index_node_2 + 1, i) = local_stiffness_in_global(3:4,3:4,i);
    % przepisanie pol macierzy dla indeksow kombincyjnych np x1 y1 z x2 y3
    local_stiffness_in_global_2(temp_index_node_1:temp_index_node_1 + 1, temp_index_node_2:temp_index_node_2 + 1, i) = local_stiffness_in_global(1:2,3:4,i); 
    local_stiffness_in_global_2(temp_index_node_2:temp_index_node_2 + 1, temp_index_node_1:temp_index_node_1 + 1, i) = local_stiffness_in_global(3:4,1:2,i);
end

global_stiffness = sum(local_stiffness_in_global_2, 3);



end