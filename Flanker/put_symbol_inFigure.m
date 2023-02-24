function put_symbol_inFigure(loc, s, k)
% This function places a letter (symbol) s, with colour k at location loc
% in a figure
% loc = array of 1x2, with numbers between 0 and 1
% first = x-coordinate, second is y-coordinate

g = text(loc(1), loc(2), s, 'FontSize', 20);
set(g, 'color', k);
end
