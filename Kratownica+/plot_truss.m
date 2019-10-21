function plot_truss(coords, links, color)
    % zak³ada wspó³rzêdne w formie [ x1 y1; x2 y2; ...
    % zak³ada macierz definuj¹ca po³¹czenia
    draw_links = size(links, 1);
    figure(1)
    for i=1:draw_links
        plot([coords(links(i,1), 1), coords(links(i,2), 1)], [coords(links(i,1), 2), coords(links(i,2), 2)], color);
        hold on
        
    grid on;
end