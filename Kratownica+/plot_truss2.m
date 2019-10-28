function plot_truss2(coords, coords2, links, color, fig_number, freq, filename)
    % zak�ada wsp�rz�dne w formie [ x1 y1; x2 y2; ...
    % zak�ada macierz definuj�ca po��czenia
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
    
       
    xlabel({'x\ $[m]$'},'Interpreter','latex')
    ylabel({'y\ $[m]$'},'Interpreter','latex')
    grid on
    set(gca,'fontsize',22)
    if freq == 0
        title({'$Kratownica\ po\ przemieszczeniu$'},'Interpreter','latex')
        print(gcf,["wynik_"+filename],'-dpng','-r300')
    else
        title({['$Postac\ drgan\ dla\ f=\ $' num2str(freq) '\ $[Hz]$']},'Interpreter','latex')
        print(gcf,["postac_dragn_"+filename],'-dpng','-r300')
    end
    
    end