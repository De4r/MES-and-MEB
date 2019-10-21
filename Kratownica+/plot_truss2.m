function plot_truss2(coords, coords2, links, color)
    % zak³ada wspó³rzêdne w formie [ x1 y1; x2 y2; ...
    % zak³ada macierz definuj¹ca po³¹czenia
    draw_links = size(links, 1);
    figure('units','normalized','outerposition',[0 0 1 1])
    for i=1:draw_links
        plot([coords(links(i,1), 1), coords(links(i,2), 1)], [coords(links(i,1), 2), coords(links(i,2), 2)], color(1), 'LineWidth', 2.5);
        hold on
    end
    for i=1:draw_links
        plot([coords2(links(i,1), 1), coords2(links(i,2), 1)], [coords2(links(i,1), 2), coords2(links(i,2), 2)], color(2), 'LineWidth', 2.5);
        hold on
    end
title({'$Kratownica\ po\ przemieszczeniu$'},'Interpreter','latex')
xlabel({'x\ $[m]$'},'Interpreter','latex')
ylabel({'y\ $[m]$'},'Interpreter','latex')
grid on
set(gca,'fontsize',22)
print(gcf,["wynik"],'-dpng','-r300')
    end