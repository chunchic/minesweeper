
function miner_version_1
clear all
global neighboorhood_x
global neighboorhood_y
   
    f = figure('units', 'pixels', 'outerposition', [200 70 750 700], 'menubar', 'none'); 
    mines = 100;
    length = 25;
    height = 25;
    for i = 1:length % создаем кнопки(поле игры)
        for j = 1:height
            board(i,j) = uicontrol('style','pushbutton','position',[i*length j*height length height],'backgroundcolor','b','callback',@first_click,'buttondownfcn',@right_click);
        end
    end
    
    function first_click(hObject,~) % первое нажатие левой кнопкой мыши
        button_position = get(hObject,'Position');
        button_coord = [button_position(1)/length button_position(2)/height];
        for i = 1:length
            for j = 1:height
                board(i,j).Callback = @left_click;
            end
        end
        
        counter1 = 0; % считает кол-во соседних клеток 
        start_area = [button_coord(1)-1 button_coord(2)-1;button_coord(1) button_coord(2)-1;button_coord(1)+1 button_coord(2)-1;...
            button_coord(1)-1 button_coord(2);button_coord(1) button_coord(2);button_coord(1)+1 button_coord(2);...
            button_coord(1)-1 button_coord(2)+1;button_coord(1) button_coord(2)+1;button_coord(1)+1 button_coord(2)+1;]; % при первом нажатии делаем свободное поле
        start_area_array = zeros(1,size(start_area,1));
        for i = 1:size(start_area,1) % углы
            if start_area(i,1) > 0 && start_area(i,1) < length+1 && start_area(i,2) > 0 && start_area(i,2) < height+1 
                start_area_array(i) = (start_area(i,1)-1)*length+start_area(i,2);
            counter1 = counter1 + 1;
            end
        end
        new_board = zeros(length*height-counter1,2); % массив, в котором сопоставляем поле без мин
        for i = 1:length*height-counter1
            new_board(i,2) = i;
        end
        all = 1:length*height;
        for i = 1:length*height % вычеркиваем начальное поле
            for j = 1:size(start_area_array,2)
                if all(i) == start_area_array(j)
                    all(i) = 0;
                end
            end
        end
        all = sort(all);
        for i = 1:length*height-counter1       
            new_board(i,1) = all(i+counter1);
        end       
        
        mines_coord = randperm(length*height-counter1, mines); % массив из неповторяющихся чисел
        new_mines_coord = new_board(mines_coord,1);
        for i = 1:mines % переход из одномерного массива в двумерный
            mines_coord_x(i) = ceil(new_mines_coord(i)/length);
            mines_coord_y(i) = mod(new_mines_coord(i),length);
            if mines_coord_y(i) == 0
                mines_coord_y(i) = height;
            end
            board(mines_coord_x(i),mines_coord_y(i)).UserData = 'BOMB'; % называем бомбы бомбами :D
        end

        for i = 1:length
            for j = 1:height
                if strcmp(board(i,j).UserData,'BOMB') == 0 
                    board(i,j).UserData = '0'; % все кнопки без бомб - нули
                end
            end
        end

        for i = 1:mines % считаем коорды соседних к бомбам кнопок и добавляем им один
                neighboor = [mines_coord_x(i)-1 mines_coord_y(i)-1;mines_coord_x(i)-1 mines_coord_y(i);mines_coord_x(i)-1 mines_coord_y(i)+1;...
                    mines_coord_x(i) mines_coord_y(i)-1;mines_coord_x(i) mines_coord_y(i)+1;...
                    mines_coord_x(i)+1 mines_coord_y(i)-1;mines_coord_x(i)+1 mines_coord_y(i);mines_coord_x(i)+1 mines_coord_y(i)+1];
            for j = 1:size(neighboor,1)
                if neighboor(j,1) ~= 0 && neighboor(j,1) ~= length+1 && neighboor(j,2) ~= 0 && neighboor(j,2) ~= height+1
                    if strcmp(board(neighboor(j,1),neighboor(j,2)).UserData,'BOMB') == 0
                        mines_nearby = str2num(board(neighboor(j,1),neighboor(j,2)).UserData) + 1;
                        board(neighboor(j,1),neighboor(j,2)).UserData = num2str(mines_nearby);
                    end
                end           
            end    
        end 
        open(button_coord(1),button_coord(2));
    end
    
    function left_click(hObject,~)        
        button_position = get(hObject,'Position');
        button_coord = [button_position(1)/length button_position(2)/height]; 
        open(button_coord(1),button_coord(2));
    end

    function right_click(hObject,~)
        fig_hObject = ancestor(hObject,'figure'); % выбираем родителя
        right_click = get(fig_hObject,'SelectionType'); % в right_click хранится строка с кнопкой
        button_position = get(hObject,'Position');
        button_coord = [button_position(1)/length button_position(2)/height];
        if strcmp(right_click,'alt') == 1 && isempty(board(button_coord(1),button_coord(2)).String) == 1
            if board(button_coord(1),button_coord(2)).BackgroundColor == [0 0 0]
                board(button_coord(1),button_coord(2)).BackgroundColor = [0 0 1];
            elseif board(button_coord(1),button_coord(2)).BackgroundColor == [0 0 1]
                board(button_coord(1),button_coord(2)).BackgroundColor = [0 0 0];
            end      
        end
          
    end

    function open(open_x,open_y) % открывает выбранную клетку
        if board(open_x,open_y).BackgroundColor == [0 0 1]
            if strcmp(board(open_x,open_y).UserData,'BOMB') == 1
                board(open_x,open_y).BackgroundColor = [1 0 0];
                board(open_x,open_y).Enable = 'off';
            elseif strcmp(board(open_x,open_y).UserData,'0') == 1
                open_neighboors(open_x,open_y);
            elseif isempty(board(open_x,open_y).UserData) == 1
                board(neighboorhood_x(i),neighboorhood_y(i)).Enable = 'off';
                board(neighboorhood_x(i),neighboorhood_y(i)).BackgroundColor = [0.8 0.8 0.8];
                board(open_x,open_y).String = [];
                
                return
            else
                board(open_x,open_y).String = board(open_x,open_y).UserData;
                board(open_x,open_y).Enable = 'off';
                board(open_x,open_y).BackgroundColor = [0.8 0.8 0.8];
                board(open_x,open_y).UserData = [];
            end
        end    
    end
    
    function open_neighboors(x,y) % открывает клетки соседей
        i = 1;
        neighboorhood_x = x;
        neighboorhood_y = y;
        while i <= size(neighboorhood_x,2)
            if strcmp(board(neighboorhood_x(i),neighboorhood_y(i)).UserData,'0') == 1
                board(neighboorhood_x(i),neighboorhood_y(i)).String = board(neighboorhood_x(i),neighboorhood_y(i)).UserData;
                board(neighboorhood_x(i),neighboorhood_y(i)).UserData = [];

                neighboors(neighboorhood_x(i),neighboorhood_y(i));              
            end
            open(neighboorhood_x(i),neighboorhood_y(i));
            i = i+1;
        end
    end

    function neighboors(x,y) % кладет в neighboorhood клетки соседей
        if x == 1
            if y == 1
                neighboorhood_x(end+1:end+3) = [x x+1 x+1];
                neighboorhood_y(end+1:end+3) = [y+1 y+1 y];
            elseif y == height
                neighboorhood_x(end+1:end+3) = [x+1 x+1 x];
                neighboorhood_y(end+1:end+3) = [y y-1 y-1];
            else
                neighboorhood_x(end+1:end+5) = [x x x+1 x+1 x+1];
                neighboorhood_y(end+1:end+5) = [y-1 y+1 y-1 y y+1];                
            end
        elseif x == length
            if y == 1
                neighboorhood_x(end+1:end+3) = [x-1 x-1 x];
                neighboorhood_y(end+1:end+3) = [y y+1 y+1];
            elseif y == height
                neighboorhood_x(end+1:end+3) = [x-1 x-1 x];
                neighboorhood_y(end+1:end+3) = [y-1 y y-1];
            else
                neighboorhood_x(end+1:end+5) = [x-1 x-1 x-1 x x];
                neighboorhood_y(end+1:end+5) = [y-1 y y+1 y-1 y+1];                
            end
        elseif y == 1 && x ~= 1 && x ~= length
            neighboorhood_x(end+1:end+5) = [x-1 x-1 x x+1 x+1];
            neighboorhood_y(end+1:end+5) = [y y+1 y+1 y y+1];
        elseif y == height && x ~= 1 && x ~= length
            neighboorhood_x(end+1:end+5) = [x-1 x-1 x x+1 x+1];
            neighboorhood_y(end+1:end+5) = [y-1 y y-1 y-1 y];
        else
            neighboorhood_x(end+1:end+8) = [x-1 x-1 x-1 x x x+1 x+1 x+1];
            neighboorhood_y(end+1:end+8) = [y-1 y y+1 y-1 y+1 y-1 y y+1];
        end
    end
end