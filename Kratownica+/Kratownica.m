clc
clear all

% Macierz wspó³rzêdnych wêz³ów w kolejnoœci 1-2-3-4 ..
% [ x1 y1; x2 y2; ..]
nodes = [ 0 0; 1 2.75; 2 0; 3 2.75; 4 0;] %moje
% nodes = [4, 0; 6, 2; 6, 6; 0, 4; 4, 4]; % michala


% Macierz elementów prêtowych
% podaj¹c numery wêz³ów jako parê np. [ 1 2; 1 3; .. ]
elements_nodes = [ 1 2; 1 3; 2 3; 2 4; 3 4; 3 5; 4 5;] % moja
%elements_nodes = [1 2; 2, 3; 3, 4; 4, 5; 5, 1; 5, 2; 5, 3]; % michala

% Macierz obci¹¿eñ w wêz³ach w kolejnoœæi [ Px1 Py1 Px2 Py2 ... ]
P = zeros(2*length(nodes),1);
P(6) = -10^6; %[N]

% Podpory oraz kierunek podpory dla 1: x+y, 2: y (pozioma), 3: x (pionowa)
% format: [wezel, typ; wezel, typ;]
supports = [1, 1; 5, 2];
%supports = [1, 2; 2, 3; 3, 2]; %michala

% Paramtery materia³owe - stal S355J2
E = 1.9 * 10^11; % [Pa] modu³ Younga
ro = 7850; %[kg/m^3] gêstoœæ
Re = 335 * 10^6; % [Pa] 
Rm = 550 * 10^6; % [Pa] 
A = 0.00025; %[m^2] przekrój prêta


% OBLICZENIA
[elements, local_stiffness, local_stiffness_in_global, local_stiffness_in_global_2, global_stiffness] = calculate_truss_elements(nodes, elements_nodes, A, E, ro);
global_stiffness_2 = global_stiffness; % kopia pelnej macierzy

elements
% Uwzglêdnianie warunków brzegowych !
global_stiffness = apply_bounduary_conditions(global_stiffness, supports);

% Obliczenie przemieszczeñ !
u = global_stiffness \ P;

% Obl. nowych wspó³rzêd., sortowanie z x1 y1 x2 y2 na [x1 y1; x2 y2;..]
u_cords = zeros(length(u)/2, 2);
for i=1:size(u_cords, 1)
   u_cords(i, 1) = u(2*i-1);
   u_cords(i, 2) = u(2*i);
end
new_nodes = nodes + u_cords;

% Wykreœlenie wyników
plot_truss(nodes, elements_nodes, 'b');
plot_truss(new_nodes, elements_nodes, 'r');


plot_truss2(nodes, new_nodes, elements_nodes, ['b','r']);