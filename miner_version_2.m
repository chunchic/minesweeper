% lenght and height must be equal

function miner_version_2
clear neighboorhood_x 
clear neighboorhood_y 

global neighboorhood_x
global neighboorhood_y
global click_check
global opened_squares

    length = 15; %(9-30)
    height = 15; %(9-24)
    button_size = 20;
    opened_squares = 0;
%         f = figure('units', 'normalized', 'outerposition', [0.5-1/length 0.5-1/height 0.5+1/length 0.5+1/height], 'menubar', 'none');

%     f = figure('units', 'normalized', 'outerposition', [0 0.05 1 0.95], 'menubar', 'none');
    f = figure('units', 'pixels', 'outerposition', [200 50 650 600], 'menubar', 'none');
    menubar_1 = uimenu(f,'text','&Game'); % "&" underlines the next char w/ alt
    new_game = uimenu(menubar_1,'text','New Game');
    stats = uimenu(menubar_1,'text','Statistics');
    options = uimenu(menubar_1,'text','Options');
    appearance = uimenu(menubar_1,'text','Change Appearance');
    exit = uimenu(menubar_1,'text','Exit');
    menubar_2 = uimenu(f,'text','&Help');
    view_help = uimenu(menubar_2,'text','View Help');
    about_minesweeper = uimenu(menubar_2,'text','About Minesweeper');
    get_more_games_online = uimenu(menubar_2,'text','Get More Games Online');
%     f = figure('units', 'pixels', 'outerposition', [200 50 750 700]);
%     f = figure('units', 'pixels', 'outerposition', [length*8 length*3 length*30 height*28], 'menubar', 'none');
    mines = 20;

    for i = 1:length % NEEDS TO BE CHANGEBLE
        for j = 1:height
            board(i,j) = uicontrol('style','pushbutton','position',[i*length j*height button_size button_size],'backgroundcolor','b','callback',@first_click,'buttondownfcn',@right_click);
        end
    end
    
    function first_click(hObject,~) % opening the first square
        button_position = get(hObject,'Position');
        button_coord = [button_position(1)/length button_position(2)/height];
        for i = 1:length
            for j = 1:height
                board(i,j).Callback = @left_click;
            end
        end
        
        counter1 = 0; % number of neighboors
        start_area = [button_coord(1)-1 button_coord(2)-1;button_coord(1) button_coord(2)-1;button_coord(1)+1 button_coord(2)-1;...
            button_coord(1)-1 button_coord(2);button_coord(1) button_coord(2);button_coord(1)+1 button_coord(2);...
            button_coord(1)-1 button_coord(2)+1;button_coord(1) button_coord(2)+1;button_coord(1)+1 button_coord(2)+1;]; % list of all neighboors
        start_area_array = zeros(1,size(start_area,1));
        for i = 1:size(start_area,1) % checking if the nighboor exists
            if start_area(i,1) > 0 && start_area(i,1) < length+1 && start_area(i,2) > 0 && start_area(i,2) < height+1 
                start_area_array(i) = (start_area(i,1)-1)*length+start_area(i,2);
            counter1 = counter1 + 1;
            end
        end
        new_board = zeros(length*height-counter1,2); % a new board w/o neighboors
        for i = 1:length*height-counter1
            new_board(i,2) = i;
        end
        all = 1:length*height;
        for i = 1:length*height 
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
        
        mines_coord = randperm(length*height-counter1, mines); % putting new mines that shouldn't spawn near the first position
        new_mines_coord = new_board(mines_coord,1);
        for i = 1:mines % spawning mines
            mines_coord_x(i) = ceil(new_mines_coord(i)/length);
            mines_coord_y(i) = mod(new_mines_coord(i),length);
            if mines_coord_y(i) == 0
                mines_coord_y(i) = height;
            end
            board(mines_coord_x(i),mines_coord_y(i)).UserData = 'BOMB';
        end

        for i = 1:length
            for j = 1:height
                if strcmp(board(i,j).UserData,'BOMB') == 0 
                    board(i,j).UserData = '0'; % squares w/o bombs
                end
            end
        end

        for i = 1:mines % for each bomb nearby plus 1 to the number on the square
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
        if opened_squares == length*height-mines
            win;
        end
    end
    
    function left_click(hObject,~)        
        button_position = get(hObject,'Position');
        button_coord = [button_position(1)/length button_position(2)/height];
        if isempty(click_check) % single click
              click_check = 1;
              pause(0.2); 
              if click_check == 1
                  open(button_coord(1),button_coord(2));
                  click_check = [];
              end
        else % double click
              if board(button_coord(1),button_coord(2)).BackgroundColor == [0.8 0.8 0.8]
              click_check = [];
              double_click_open(button_coord(1),button_coord(2));
              end
        end
        if opened_squares == length*height-mines
            win;
        end
    end

    function right_click(hObject,~)
        fig_hObject = ancestor(hObject,'figure'); % putting a flag
        right_click = get(fig_hObject,'SelectionType'); 
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

    function open(open_x,open_y) % opens a square
        if board(open_x,open_y).BackgroundColor == [0 0 1] % only blue squares can be opened
            if strcmp(board(open_x,open_y).UserData,'BOMB') == 1 % if opens a bomb, lose
                lose();
            elseif strcmp(board(open_x,open_y).UserData,'0') == 1 % if opens an empty square, open neighboors
                open_neighboors(open_x,open_y);
%             elseif isempty(board(open_x,open_y).UserData) == 1 % ???????
%                 board(neighboorhood_x(i),neighboorhood_y(i)).BackgroundColor = [0.8 0.8 0.8];
%                 board(open_x,open_y).String = [];               
%                 return
            else 
                board(open_x,open_y).String = board(open_x,open_y).UserData; % if a square is bombless
                board(open_x,open_y).BackgroundColor = [0.8 0.8 0.8];
                board(open_x,open_y).UserData = [];
                opened_squares = opened_squares + 1;
            end
        end    
    end
    
    function open_neighboors(x,y) % opens neighboors
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

    function neighboors(x,y) % finds the neighboors of the square
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

    function double_click_open(x,y) % opening w/ double click
        flag = false; % can be opened only if the flags are nearby
        neighboorhood_x = x;
        neighboorhood_y = y;
        neighboors(x,y);
        mines_nearby = 0;
        for i = 2:size(neighboorhood_x,2)
            if board(neighboorhood_x(i),neighboorhood_y(i)).BackgroundColor == [0 0 0]
                mines_nearby = mines_nearby + 1;
                if mines_nearby >= str2num(board(x,y).String)     
                  flag = true;
                end
            end
        end
        for i = 2:size(neighboorhood_x,2)
            if flag
                open(neighboorhood_x(i),neighboorhood_y(i));
            end
        end
    end

    function lose(~,~) % if opened a bomb
        for i = 1:length
            for j = 1:height
                if strcmp(board(i,j).UserData,'BOMB') == true
                    board(i,j).BackgroundColor = [1 0 0];
                end
                board(i,j).Enable = 'off';
            end
        end
    end

    function win(~,~) % if opened all squares w/o bombs
        for i = 1:length
            for j = 1:height
                if strcmp(board(i,j).UserData,'BOMB') == true
                    board(i,j).BackgroundColor = [1 1 0];
                end
                board(i,j).Enable = 'off';
            end
        end
    end
end
