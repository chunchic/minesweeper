function miner_version_4

global neighboorhood_x
global neighboorhood_y
global click_check
global opened_squares
global flagged_squares
global time
global finished
global restart
global mines_coord

    length = 30; %(9-30)
    height = 10; %(9-24)    
    button_size = 20;
    opened_squares = 0;
    mines = 25;
    flagged_squares = 0;
    button_color = [0.25 0.25 1];
    figure_color = [0.75 0.75 1];
    time = 0;
    finished = 0;
    restart = false;
    steps = 0;
    
    f = figure('units', 'pixels', 'outerposition', [200 700-(height+5)*button_size (length+3)*button_size (height+7)*button_size],'numbertitle','off','name','Minersweeper', 'menubar', 'none','color',figure_color,'closerequestfcn',@close_game);
    menubar_1 = uimenu(f,'text','&Game'); % "&" underlines the next char w/ alt
    new_game = uimenu(menubar_1,'text','New Game','menuselectedfcn',@new_game_selection);
    stats = uimenu(menubar_1,'text','Statistics');
    options = uimenu(menubar_1,'text','Options','menuselectedfcn',@game_options);
    appearance = uimenu(menubar_1,'text','Change Appearance');
    exit = uimenu(menubar_1,'text','Exit','menuselectedfcn',@close_game);
    menubar_2 = uimenu(f,'text','&Help');
    view_help = uimenu(menubar_2,'text','View Help');
    about_minesweeper = uimenu(menubar_2,'text','About Minesweeper');
    get_more_games_online = uimenu(menubar_2,'text','Get More Games Online');

    for i = 1:length 
        for j = 1:height
            board(i,j) = uicontrol(f,'style','pushbutton','position',[i*button_size (j+2)*button_size button_size button_size],'backgroundcolor',button_color,'callback',@first_click,'buttondownfcn',@right_click);
        end
    end
    
    stopwatch = uicontrol('style','text','position',[button_size*length/4 button_size button_size*2.5 button_size*1.5],'string',num2str(time),'backgroundcolor',button_color,'foregroundcolor',[1 1 1],'fontsize',16);
    flags_left = uicontrol('style','text','position',[button_size*3*length/4 button_size button_size*2.5 button_size*1.5],'string',num2str(mines),'backgroundcolor',button_color,'foregroundcolor',[1 1 1],'fontsize',16); 
      
    function first_click(hObject,~) % opening the first square
        steps = steps + 1;
        button_position = get(hObject,'Position');
        button_position(2) = button_position(2) - button_size*2; % look at the positions in line 30
        button_coord = [button_position(1)/button_size button_position(2)/button_size];
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
                start_area_array(i) = start_area(i,1)+(start_area(i,2)-1)*length;
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
        
        if restart == false
            mines_coord = randperm(length*height-counter1, mines); % putting new mines that shouldn't spawn near the first position
        end
        
        new_mines_coord = new_board(mines_coord,1);
        for i = 1:mines % spawning mines
            mines_coord_y(i) = ceil(new_mines_coord(i)/length);
            mines_coord_x(i) = mod(new_mines_coord(i),length);
            if mines_coord_x(i) == 0
                mines_coord_x(i) = length;
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
        start_timer();
    end

    function left_click(hObject,~)
        steps = steps + 1;
        button_position = get(hObject,'Position');
        button_position(2) = button_position(2) - button_size*2; % look at the positions in line 30
        button_coord = [button_position(1)/button_size button_position(2)/button_size];
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

    function right_click(hObject,~) % putting a flag
        fig_hObject = ancestor(hObject,'figure'); 
        right_click = get(fig_hObject,'SelectionType'); 
        button_position = get(hObject,'Position');
        button_position(2) = button_position(2) - button_size*2; % look at the positions in line 30
        button_coord = [button_position(1)/button_size button_position(2)/button_size];
        if strcmp(right_click,'alt') && strcmp(board(button_coord(1),button_coord(2)).Enable,'on') %&& isempty(board(button_coord(1),button_coord(2)).String) == 1
            if board(button_coord(1),button_coord(2)).BackgroundColor == [0 0 0] 
                flagged_squares = flagged_squares - 1;
                board(button_coord(1),button_coord(2)).BackgroundColor = button_color;
                board(button_coord(1),button_coord(2)).String = '?';
            elseif board(button_coord(1),button_coord(2)).BackgroundColor == button_color
                if isempty(board(button_coord(1),button_coord(2)).String)
                    flagged_squares = flagged_squares + 1;
                    board(button_coord(1),button_coord(2)).BackgroundColor = [0 0 0];
                elseif strcmp(board(button_coord(1),button_coord(2)).String,'?')
                    board(button_coord(1),button_coord(2)).String = '';
                end
            end
            steps = steps + 1;
        end
        flags_left.String = num2str(mines-flagged_squares);
        if strcmp(board(button_coord(1),button_coord(2)).String,'0')
            board(button_coord(1),button_coord(2)).String = [];
        end
    end

    function open(open_x,open_y) % opens a square
        if board(open_x,open_y).BackgroundColor == button_color % only blue squares can be opened
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
        finished = 1;
        for i = 1:length
            for j = 1:height
                if strcmp(board(i,j).UserData,'BOMB')
                    board(i,j).BackgroundColor = [1 0 0];
                end
                if board(i,j).BackgroundColor == [0 0 0]
                    board(i,j).BackgroundColor = [0 1 0];
                    board(i,j).String = [];
                end
                board(i,j).Enable = 'off';
            end
        end
        
        game_lost_figure = dialog('position',[(f.Position(1)+f.Position(3))/2-100 (f.Position(2)+f.Position(4))/2-50 415 230],'numbertitle','off','name','Game Lost');
        exit_game_button_lose = uicontrol(game_lost_figure,'style','pushbutton','position',[5 10 127 25],'string','Exit','callback',@exit_game);
        restart_game_button_lose = uicontrol(game_lost_figure,'style','pushbutton','position',[138 10 127 25],'string','Restart this game','callback',@restart_game);
        start_new_game_button_lose = uicontrol(game_lost_figure,'style','pushbutton','position',[272 10 127 25],'string','Play again','callback',@start_new_game);
        lost_label = uicontrol(game_lost_figure,'style','text','position',[50 120 300 25],'string','Sorry, you lost this game. Better luck next time!');
    end

    function win(~,~) % if opened all squares w/o bombs
        finished = 1;
        for i = 1:length
            for j = 1:height
                if strcmp(board(i,j).UserData,'BOMB') == true
                    board(i,j).BackgroundColor = [1 1 0];
                end
                board(i,j).Enable = 'off';
            end
        end
        
        game_won_figure = dialog('position',[[(f.Position(1)+f.Position(3))/2-100 (f.Position(2)+f.Position(4))/2-50 310 300]],'numbertitle','off','name','Game Won');
        exit_game_button_win = uicontrol(game_won_figure,'style','pushbutton','position',[5 10 140 25],'string','Exit','callback',@exit_game);
        start_new_game_button_win = uicontrol(game_won_figure,'style','pushbutton','position',[155 10 140 25],'string','Play again','callback',@start_new_game);
        won_label = uicontrol(game_won_figure,'style','text','position',[50 160 200 25],'string','Congratulations, you won the game!');
    end
    
    function start_timer(~,~)
        while time > -1 
            if finished
                return
            end
            stopwatch.String = time; 
            time = time+1;
            pause(1);
        end
    end
    
    function close_game(~,~)
        if steps == 0
            delete(f)
            close all
        else
            close_game_figure = dialog('position',[(f.Position(1)+f.Position(3))/2-100 (f.Position(2)+f.Position(4))/2-50 300 200],'numbertitle','off','name','Exit Game');
            close_game_button_save = uicontrol(close_game_figure,'style','pushbutton','position',[100 10 30 25],'string','Save','callback',@save_game);
            close_game_button_dont_save = uicontrol(close_game_figure,'style','pushbutton','position',[180 10 30 25],'string','Don''t save','callback',@exit_game);
            close_game_button_cancel = uicontrol(close_game_figure,'style','pushbutton','position',[250 10 30 25],'string','Cancel','callback',@closing_small_figure_request);
        end
    end
    
    function exit_game(hObject,~)
    small_figure = ancestor(hObject,'figure');
    delete(f)
    delete(small_figure)
    close all
    end

    function start_new_game(hObject,~)
        figure = ancestor(hObject,'figure');
        close(figure)
        opened_squares = 0;
        flagged_squares = 0;
        time = 0;
        finished = 0;
        restart = false;
        stopwatch.String = num2str(time);
        flags_left.String = num2str(mines);
        steps = 0;
        for i = 1:length
            for j = 1:height
                board(i,j).Callback = @first_click;
                board(i,j).Enable = 'on';
                board(i,j).BackgroundColor = button_color;
                board(i,j).String = '';
                board(i,j).UserData = '';
            end
        end
    end
    
    function restart_game(hObject,~)
        figure = ancestor(hObject,'figure');
        close(figure)
        opened_squares = 0;
        flagged_squares = 0;
        time = 0;
        finished = 0;
        restart = true;
        stopwatch.String = num2str(time);
        flags_left.String = num2str(mines);
        steps = 0;
        for i = 1:length
            for j = 1:height
                board(i,j).Callback = @first_click;
                board(i,j).Enable = 'on';
                board(i,j).BackgroundColor = button_color;
                board(i,j).String = '';
                board(i,j).UserData = '';
            end
        end
    end
    
    function closing_small_figure_request(hObject,~)
        this_figure = ancestor(hObject,'figure');
        delete(this_figure)
    end

    function game_options(~,~)
        options_figure = dialog('position',[(f.Position(1)+f.Position(3))/2-100 (f.Position(2)+f.Position(4))/2-50 382 391],'numbertitle','off','name','Options');
        button_group = uibuttongroup(options_figure,'selectionchangedfcn',@game_difficulty);
        difficulty_label = uicontrol(options_figure,'style','text','position',[18 364 50 20],'string','Difficulty');
        choose_beginner = uicontrol(button_group,'style','radiobutton','position',[20 330 100 20],'string','Beginner','value',1);
        choose_intermediate = uicontrol(button_group,'style','radiobutton','position',[20 300 100 20],'string','Intermediate');
        choose_advanced = uicontrol(button_group,'style','radiobutton','position',[20 270 100 20],'string','Advanced');
        choose_custom = uicontrol(button_group,'style','radiobutton','position',[260 340 100 20],'string','Custom');
        label_height = uicontrol(options_figure,'style','text','position',[260 310 40 20],'string','Height','enable','off');
        label_width = uicontrol(options_figure,'style','text','position',[260 280 40 20],'string','Windth','enable','off');
        label_mines = uicontrol(options_figure,'style','text','position',[260 250 40 20],'string','Mines','enable','off');
        edit_height = uicontrol(options_figure,'style','edit','position',[330 310 40 20],'enable','off');
        edit_width = uicontrol(options_figure,'style','edit','position',[330 280 40 20],'enable','off');
        edit_mines = uicontrol(options_figure,'style','edit','position',[330 250 40 20],'enable','off');
        display_animations = uicontrol(options_figure,'style','checkbox','position',[20 220 200 20],'string','Display animations');
        play_sounds = uicontrol(options_figure,'style','checkbox','position',[20 190 200 20],'string','Play sounds');
        show_tips = uicontrol(options_figure,'style','checkbox','position',[20 160 200 20],'string','Show tips');
        always_continue = uicontrol(options_figure,'style','checkbox','position',[20 130 200 20],'string','Always continue saved game');
        always_save = uicontrol(options_figure,'style','checkbox','position',[20 100 200 20],'string','Always save game on exit');
        allow_question_marks = uicontrol(options_figure,'style','checkbox','position',[20 70 200 20],'string','Allow question marks (on double right-click)');
        options_ok_button = uicontrol(options_figure,'style','pushbutton','position',[140 15 110 25],'string','OK');
        option_cancel_button = uicontrol(options_figure,'style','pushbutton','position',[260 15 110 25],'string','Cancel','callback',@closing_small_figure_request);
    
        function game_difficulty(~,~)
            if choose_custom.Value == 1
                label_height.Enable = 'on';
                label_width.Enable = 'on';
                label_mines.Enable = 'on';
                edit_height.Enable = 'on';
                edit_width.Enable = 'on';
                edit_mines.Enable = 'on';
            else
                label_height.Enable = 'off';
                label_width.Enable = 'off';
                label_mines.Enable = 'off';
                edit_height.Enable = 'off';
                edit_width.Enable = 'off';
                edit_mines.Enable = 'off';
            end
        end
    end

    function new_game_selection(~,~)
        new_game_selection_figure = dialog('position',[(f.Position(1)+f.Position(3))/2-100 (f.Position(2)+f.Position(4))/2-50 363 245],'color',[1 1 1],'numbertitle','off','name','New Game');
        new_game_question = uicontrol(new_game_selection_figure,'style','text','position',[10 180 343 60],'string','What do you want to do with the game in progress?','fontsize',12,'foregroundcolor',[0 0 1],'backgroundcolor',[1 1 1]);
        start_new_game_selection = uicontrol(new_game_selection_figure,'style','pushbutton','position',[10 110 343 45],'string','Quit and start a new game','callback',@start_new_game);
        restart_this_game_selection = uicontrol(new_game_selection_figure,'style','pushbutton','position',[10 60 343 45],'string','Restart this game','callback',@restart_game);
        keep_playing_selection = uicontrol(new_game_selection_figure,'style','pushbutton','position',[10 10 343 45],'string','Keep playing','callback',@closing_small_figure_request);
    end

%     function game_pause(~,~) % pause and continue doesn't impact the stopwatch
%         for i = 1:length
%             for j = 1:height
%                 board(i,j).Enable = 'off';
%             end
%         end
%     end
%     
%     function game_continue(~,~)
%         for i = 1:length
%             for j = 1:height
%                 board(i,j).Enable = 'on';
%             end
%         end
%     end

    
end


