clc
clear all

% Paramtery materia³owe - stal S355J2
E = 1.9 * 10^11; % [Pa] modu³ Younga
ro = 7850; %[kg/m^3] gêstoœæ
Re = 335 * 10^6; % [Pa] 
Rm = 550 * 10^6; % [Pa] 
A = 0.0001; %[m^2] przekrój prêta

% Macierz wspó³rzêdnych wêz³ów w kolejnoœci 1-2-3-4 ..
% [ x1 y1; x2 y2; ..]
nodes = [ 0 0; 1 2.75; 2 0; 3 2.75; 4 0;]

% Macierz elementów prêtowych
% podaj¹c numery wêz³ów jako parê np. [ 1 2; 1 3; .. ]
elements_nodes = [ 1 2; 1 3; 2 3; 2 4; 3 4; 3 5; 4 5;]

% Macierz obci¹¿eñ w wêz³ach w kolejnoœæi [ Px1 Py1 Px2 Py2 ... ]
P = zeros(2*length(nodes),1);
P(6) = -10^6; %[N]

% wêz³y podpór, oraz kierunek podpory dla 1 - x+y, 2 - y (pozioma), 3 - x (pionowa) -> format
% [wezel, typ; wezel, typ;]
supports = [1, 1; 5, 2];




% OBLICZENIA
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
global_stiffness_2 = global_stiffness; % kopia pelnej macierzy

% Uwzglêdnianie warunków brzegowych !
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

% Obliczenie przemieszczeñ !
u = global_stiffness \ P;

u_cords = zeros(length(u)/2, 2);
for i=1:size(u_cords, 1)
   u_cords(i, 1) = u(2*i-1);
   u_cords(i, 2) = u(2*i);
end
new_nodes = nodes + u_cords;

wykres(nodes, elements_nodes, 'b');

wykres(new_nodes, elements_nodes, 'r');