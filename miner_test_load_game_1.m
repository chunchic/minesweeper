% checking if "save_minesweeper is empty"
% trying to load a matrix

load = fopen('test_load_game.txt');
a = fscanf(load,'%i',[20,10]);
b = a';
