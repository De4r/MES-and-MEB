clc
clear all
close all

% Opcja zapisu wykresów
savePlots = 'n' % y/n

% Macierz wspó³rzêdnych wêz³ów w kolejnoœci wêz³ów: 1-2-3-4 ..
% Format [ x1 y1; x2 y2; ..] czyli x1 y1 odnoœi siê do wêz³a 1

% Macierz elementów prêtowych
% Podaj¹c numery wêz³ów jako parê zdefiniowanych wczeœniej wêz³ów 
% np. [ 1 2; 1 3; .. ] tworzymy elementy odpowiednio numerowane 1-2-3..

% Macierz obci¹¿eñ w wêz³ach w kolejnoœæi [ Px1 Py1 Px2 Py2 ... ]
% Gdzie Px1 oznacza si³e na kierunku x w wêŸle 1. Znak minus zmienia zwort.

% Podpory oraz kierunek podpory definowane w parach liczb
% Opcje: 1: x+y (nieprzesuwna), 2: y (pozioma przesuwna), 3: x (pionowa przesuwna)
% format: [wezel, typ; wezel, typ; ...]

nodes = [ 0 0; 1 2.75; 2 0; 3 2.75; 4 0;]
elementsNodes = [ 1 2; 1 3; 2 3; 2 4; 3 4; 3 5; 4 5;] % moja
P = zeros(2*length(nodes),1);
P(6) = -10^6; %[N]
supportsDefinitions = [1, 1; 5, 2];


% Paramtery materia³owe - aktualnie sta³e dla ca³ej kratownicy - stal S355J2
E = 1.9 * 10^11; % [Pa] modu³ Younga
density = 7850; %[kg/m^3] gêstoœæ
Re = 335 * 10^6; % [Pa] 
Rm = 550 * 10^6; % [Pa] 
A = 0.00025; %[m^2] przekrój prêta


%%-----------------------OBLICZENIA--------------------------------------%%
[elements, localStiffnes, localMass, localStiffnesMatrixInGlobalCoord, ...
    localStiffnesMatrixInGlobalCoordAllNodes, localMassMatrixInGlobalCoord, ...
    localMassMatrixInGlobalCoordAllNodes, globalStiffnes, globalMass] = ...
    createTrussElements(nodes, elementsNodes, A, E, density);

globalStiffnesCopy = globalStiffnes; % kopia pelnej macierzy sztywnoœci
globalMassCopy = globalMass;

% Uwzglêdnianie warunków brzegowych za pomoc¹ funkcji
% apply_bounduary_conditions(matrix, supports_matrix)

globalStiffnes = applyBounduaryConditions(globalStiffnes, supportsDefinitions);
globalMass = applyBounduaryConditions(globalMass, supportsDefinitions);

% Obliczenie przemieszczeñ 
u = globalStiffnes \ P;

% Obliczenie nowych wspó³rzêdnych, sortowanie z wektora na macierz
% wektor [x1 y1 x2 y2] zostaje zamieniony na [x1 y1; x2 y2;..]
uCoords = zeros(length(u)/2, 2);
for i=1:size(uCoords, 1)
   uCoords(i, 1) = u(2*i-1);
   uCoords(i, 2) = u(2*i);
end
% Dodanie przemieszczeñ wêz³owych do wspó³rzêdnych wêz³ów
newNodes = nodes + uCoords;

% Wykreœlenie wyników modelu statycznego
figureNumber = 1;
plotTruss(nodes, elementsNodes, 'b', figureNumber, 0); % Kratownica przed obci¹¿eniem
plotTruss(newNodes, elementsNodes, 'r', figureNumber, 0); % Kratownica po obci¹¿eniu

% Wykres wysokiej rozdzielczoœci
if savePlots == 'y'
    figureNumber = figureNumber + 1;
    plotTrussHighResolution(nodes, newNodes, elementsNodes, ['b','r'],...
        figureNumber, 0, "statyczne");
    
end


% Obliczenia dynamiczne, wyznaczenie czêstotliwoœci drgañ w³asnych
[rightEigenVectors, eigenValeus] = eig(globalStiffnes, globalMass);
disp('Czêstotliwosci drgan w³asnych:');
modalFrequencies = sqrt(diag(eigenValeus)) / ( 2* pi)

% Normalizacja wektorów w³asny M-ortogonalnie
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