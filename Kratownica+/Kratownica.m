clc
clear all
close all

% Opcja zapisu wykres�w
zapis = 'y' % y/n
% Macierz wsp�rz�dnych w�z��w w kolejno�ci w�z��w: 1-2-3-4 ..
% Format [ x1 y1; x2 y2; ..] czyli x1 y1 odno�i si� do w�z�a 1

% Macierz element�w pr�towych
% Podaj�c numery w�z��w jako par� zdefiniowanych wcze�niej w�z��w 
% np. [ 1 2; 1 3; .. ] tworzymy elementy odpowiednio numerowane 1-2-3..

% Macierz obci��e� w w�z�ach w kolejno��i [ Px1 Py1 Px2 Py2 ... ]
% Gdzie Px1 oznacza si�e na kierunku x w w�le 1. Znak minus zmienia zwort.

% Podpory oraz kierunek podpory definowane w parach liczb
% Opcje: 1: x+y (nieprzesuwna), 2: y (pozioma przesuwna), 3: x (pionowa przesuwna)
% format: [wezel, typ; wezel, typ; ...]

nodes = [ 0 0; 1 2.75; 2 0; 3 2.75; 4 0;]
elements_nodes = [ 1 2; 1 3; 2 3; 2 4; 3 4; 3 5; 4 5;] % moja
P = zeros(2*length(nodes),1);
P(6) = -10^6; %[N]
supports = [1, 1; 5, 2];


% Paramtery materia�owe - aktualnie sta�e dla ca�ej kratownicy - stal S355J2
E = 1.9 * 10^11; % [Pa] modu� Younga
ro = 7850; %[kg/m^3] g�sto��
Re = 335 * 10^6; % [Pa] 
Rm = 550 * 10^6; % [Pa] 
A = 0.00025; %[m^2] przekr�j pr�ta


%------------------------OBLICZENIA---------------------------------------%
[elements, local_stiffness, local_stiffness_in_global, ...
    local_stiffness_in_global_2, local_mass_in_global, ...
    local_mass_in_global_2, global_stiffness, global_mass] = ...
    calculate_truss_elements(nodes, elements_nodes, A, E, ro);

global_stiffness_2 = global_stiffness; % kopia pelnej macierzy sztywno�ci
global_mass_2 = global_mass;

% Uwzgl�dnianie warunk�w brzegowych za pomoc� funkcji
% apply_bounduary_conditions(matrix, supports_matrix)

global_stiffness = apply_bounduary_conditions(global_stiffness, supports);
global_mass = apply_bounduary_conditions(global_mass, supports);

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

% Wykre�lenie wynik�w modelu statycznego
fig_number = 1;
plot_truss(nodes, elements_nodes, 'b', fig_number, 0); % Kratownica przed obci��eniem
plot_truss(new_nodes, elements_nodes, 'r', fig_number, 0); % Kratownica po obci��eniu

% Wykres wysokiej rozdzielczo�ci
if zapis == 'y'
    fig_number = fig_number + 1;
    plot_truss2(nodes, new_nodes, elements_nodes, ['b','r'],...
        fig_number, 0, "statyczne");
    
end


% Obliczenia dynamiczne, wyznaczenie cz�stotliwo�ci drga� w�asnych
[right_eigenvector, eigen_values] = eig(global_stiffness, global_mass);
disp('Cz�stotliwosci drgan w�asnych:');
modal_frequency = sqrt(diag(eigen_values)) / ( 2* pi)

% Wyrkesy postaci drgan kratownicy
modal_shape_number = 0;
for i=1:length(modal_frequency)
    if eigen_values(i,i) ~= 1
        fig_number = fig_number + 1;
        u = right_eigenvector(:,i);
        for j=1:size(u_cords, 1)
            u_cords(j, 1) = u(2*j-1);
            u_cords(j, 2) = u(2*j);
        end
        new_nodes = nodes + u_cords;
        plot_truss(nodes, elements_nodes, 'b', fig_number, 0); % Kratownica
        % Kratownica w postaci drgan
        plot_truss(new_nodes, elements_nodes, 'r', fig_number, modal_frequency(i));
    end
end

if zapis == 'y'
    for i=1:length(modal_frequency)
        if eigen_values(i,i) ~= 1
            fig_number = fig_number + 1;
            modal_shape_number = modal_shape_number + 1;
            u = right_eigenvector(:,i);
            for j=1:size(u_cords, 1)
                u_cords(j, 1) = u(2*j-1);
                u_cords(j, 2) = u(2*j);
            end
            new_nodes = nodes + u_cords;
            plot_truss2(nodes, new_nodes, elements_nodes, ['b','r'], fig_number, modal_frequency(i), num2str(modal_shape_number));
        end
    end
end