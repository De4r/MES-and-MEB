clc
clear all

% Macierz wsp�rz�dnych w�z��w w kolejno�ci w�z��w: 1-2-3-4 ..
% Format [ x1 y1; x2 y2; ..] czyli x1 y1 odno�i si� do w�z�a 1
nodes = [ 0 0; 1 2.75; 2 0; 3 2.75; 4 0;] %moje
% nodes = [4, 0; 6, 2; 6, 6; 0, 4; 4, 4]; % michala


% Macierz element�w pr�towych
% Podaj�c numery w�z��w jako par� zdefiniowanych wcze�niej w�z��w 
% np. [ 1 2; 1 3; .. ] tworzymy elementy odpowiednio numerowane 1-2-3..
elements_nodes = [ 1 2; 1 3; 2 3; 2 4; 3 4; 3 5; 4 5;] % moja
%elements_nodes = [1 2; 2, 3; 3, 4; 4, 5; 5, 1; 5, 2; 5, 3]; % michala

% Macierz obci��e� w w�z�ach w kolejno��i [ Px1 Py1 Px2 Py2 ... ]
% Gdzie Px1 oznacza si�e na kierunku x w w�le 1. Znak minus zmienia zwort.
P = zeros(2*length(nodes),1);
P(6) = -10^6; %[N]

% Podpory oraz kierunek podpory definowane w parach liczb
% Opcje: 1: x+y (nieprzesuwna), 2: y (pozioma przesuwna), 3: x (pionowa przesuwna)
% format: [wezel, typ; wezel, typ; ...]
supports = [1, 1; 5, 2];
%supports = [1, 2; 2, 3; 3, 2]; %michala

% Paramtery materia�owe - aktualnie sta�e dla ca�ej kratownicy - stal S355J2
E = 1.9 * 10^11; % [Pa] modu� Younga
ro = 7850; %[kg/m^3] g�sto��
Re = 335 * 10^6; % [Pa] 
Rm = 550 * 10^6; % [Pa] 
A = 0.00025; %[m^2] przekr�j pr�ta


% OBLICZENIA
[elements, local_stiffness, local_stiffness_in_global, ...
    local_stiffness_in_global_2, local_mass_in_global, ...
    local_mass_in_global_2, global_stiffness, global_mass] = ...
    calculate_truss_elements(nodes, elements_nodes, A, E, ro);

global_stiffness_2 = global_stiffness; % kopia pelnej macierzy sztywno�ci

% Uwzgl�dnianie warunk�w brzegowych za pomoc� funkcji
global_stiffness = apply_bounduary_conditions(global_stiffness, supports);

% Obliczenie przemieszcze� 
u = global_stiffness \ P;

% Obliczenie nowych wsp�rz�dnych, sortowanie z wektora na macierz
% wektor [x1 y1 x2 y2] zostaje zamieniony na [x1 y1; x2 y2;..]
u_cords = zeros(length(u)/2, 2);
for i=1:size(u_cords, 1)
   u_cords(i, 1) = u(2*i-1);
   u_cords(i, 2) = u(2*i);
end
% Dodanie przemieszcze� w�z�owych do wsp�rz�dnych w�z��w
new_nodes = nodes + u_cords;

% Wykre�lenie wynik�w
plot_truss(nodes, elements_nodes, 'b'); % Kratownica przed obci��eniem
plot_truss(new_nodes, elements_nodes, 'r'); % Kratownica po obci��eniu

% Wykres wysokiej rozdzielczo��i
plot_truss2(nodes, new_nodes, elements_nodes, ['b','r']); 

% Obliczenia dynamiczne, wyznaczenie cz�stotliwo�ci drga� w�asnych
[right_eigenvector, eigen_values] = eig(global_stiffness, global_mass);
czestotliwosci_dragn_wlasnych = sqrt(diag(eigen_values)) / ( 2* pi)