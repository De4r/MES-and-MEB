function plot_truss(coords, links, color)
    % zak�ada wsp�rz�dne w formie [ x1 y1; x2 y2; ...
    % zak�ada macierz definuj�ca po��czenia
    draw_links = size(links, 1);
    figure(1)
    for i=1:draw_links
        plot([coords(links(i,1), 1), coords(links(i,2), 1)], [coords(links(i,1), 2), coords(links(i,2), 2)], color);
        hold on
        
    grid on;
end