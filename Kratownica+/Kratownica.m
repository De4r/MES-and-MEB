clc
clear all
close all

% Opcja zapisu wykres�w
savePlots = 'n' % y/n

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
elementsNodes = [ 1 2; 1 3; 2 3; 2 4; 3 4; 3 5; 4 5;] % moja
P = zeros(2*length(nodes),1);
P(6) = -10^6; %[N]
supportsDefinitions = [1, 1; 5, 2];


% Paramtery materia�owe - aktualnie sta�e dla ca�ej kratownicy - stal S355J2
E = 1.9 * 10^11; % [Pa] modu� Younga
density = 7850; %[kg/m^3] g�sto��
Re = 335 * 10^6; % [Pa] 
Rm = 550 * 10^6; % [Pa] 
A = 0.00025; %[m^2] przekr�j pr�ta


%%-----------------------OBLICZENIA--------------------------------------%%
[elements, localStiffnes, localMass, localStiffnesMatrixInGlobalCoord, ...
    localStiffnesMatrixInGlobalCoordAllNodes, localMassMatrixInGlobalCoord, ...
    localMassMatrixInGlobalCoordAllNodes, globalStiffnes, globalMass] = ...
    createTrussElements(nodes, elementsNodes, A, E, density);

globalStiffnesCopy = globalStiffnes; % kopia pelnej macierzy sztywno�ci
globalMassCopy = globalMass;

% Uwzgl�dnianie warunk�w brzegowych za pomoc� funkcji
% apply_bounduary_conditions(matrix, supports_matrix)

globalStiffnes = applyBounduaryConditions(globalStiffnes, supportsDefinitions);
globalMass = applyBounduaryConditions(globalMass, supportsDefinitions);

% Obliczenie przemieszcze� 
u = globalStiffnes \ P;

% Obliczenie nowych wsp�rz�dnych, sortowanie z wektora na macierz
% wektor [x1 y1 x2 y2] zostaje zamieniony na [x1 y1; x2 y2;..]
uCoords = zeros(length(u)/2, 2);
for i=1:size(uCoords, 1)
   uCoords(i, 1) = u(2*i-1);
   uCoords(i, 2) = u(2*i);
end
% Dodanie przemieszcze� w�z�owych do wsp�rz�dnych w�z��w
newNodes = nodes + uCoords;

% Wykre�lenie wynik�w modelu statycznego
figureNumber = 1;
plotTruss(nodes, elementsNodes, 'b', figureNumber, 0); % Kratownica przed obci��eniem
plotTruss(newNodes, elementsNodes, 'r', figureNumber, 0); % Kratownica po obci��eniu

% Wykres wysokiej rozdzielczo�ci
if savePlots == 'y'
    figureNumber = figureNumber + 1;
    plotTrussHighResolution(nodes, newNodes, elementsNodes, ['b','r'],...
        figureNumber, 0, "statyczne");
    
end


% Obliczenia dynamiczne, wyznaczenie cz�stotliwo�ci drga� w�asnych
[rightEigenVectors, eigenValeus] = eig(globalStiffnes, globalMass);
disp('Cz�stotliwosci drgan w�asnych:');
modalFrequencies = sqrt(diag(eigenValeus)) / ( 2* pi)

% Normalizacja wektor�w w�asny M-ortogonalnie
for i=1:size(rightEigenVectors,2)
   rightEigenVectorsNormalized = rightEigenVectors / real((sqrt(...
       rightEigenVectors'*globalMass*rightEigenVectors)));
end

% Wyrkesy postaci drgan kratownicy
modalShapeNumber = 0;
for i=1:length(modalFrequencies)
    if eigenValeus(i,i) ~= 1
        figureNumber = figureNumber + 1;
        %u = rightEigenVectors(:,i);
        u = rightEigenVectorsNormalized(:,i);
        for j=1:size(uCoords, 1)
            uCoords(j, 1) = u(2*j-1);
            uCoords(j, 2) = u(2*j);
        end
        newNodes = nodes + uCoords;
        plotTruss(nodes, elementsNodes, 'b', figureNumber, 0); % Kratownica
        % Kratownica w postaci drgan
        plotTruss(newNodes, elementsNodes, 'r', figureNumber, modalFrequencies(i));
    end
end

if savePlots == 'y'
    for i=1:length(modalFrequencies)
        if eigenValeus(i,i) ~= 1
            figureNumber = figureNumber + 1;
            modalShapeNumber = modalShapeNumber + 1;
            u = rightEigenVectors(:,i);
            for j=1:size(uCoords, 1)
                uCoords(j, 1) = u(2*j-1);
                uCoords(j, 2) = u(2*j);
            end
            newNodes = nodes + uCoords;
            plotTrussHighResolution(nodes, newNodes, elementsNodes, ['b','r'], figureNumber, modalFrequencies(i), num2str(modalShapeNumber));
        end
    end
end



% for i=1:size(localMassMatrixInGlobalCoordAllNodes,3)
%     latexMatrixPrint(localMassMatrixInGlobalCoordAllNodes(:,:,i), 3, 'filename.txt')
% end