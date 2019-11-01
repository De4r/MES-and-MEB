function plotTruss(coords, links, color, figureNumber, freq)
    % zak³ada wspó³rzêdne w formie [ x1 y1; x2 y2; ...
    % zak³ada macierz definuj¹ca po³¹czenia
    drawLinks = size(links, 1);
    figure(figureNumber)
    for i=1:drawLinks
        plot([coords(links(i,1), 1), coords(links(i,2), 1)], [coords(links(i,1), 2), coords(links(i,2), 2)], color);
        hold on
        
    grid on;
    if freq == 0
        title({'$Kratownica\ po\ przemieszczeniu$'},'Interpreter','latex')
    else
        title({['$Postac\ drgan\ dla\ f=\ $' num2str(freq) '\ $[Hz]$']},'Interpreter','latex')
    end
    xlabel({'x\ $[m]$'},'Interpreter','latex')
    ylabel({'y\ $[m]$'},'Interpreter','latex')
end