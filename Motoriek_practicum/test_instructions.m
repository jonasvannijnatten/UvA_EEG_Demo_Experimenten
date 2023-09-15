close

try
    
    ListenChar(2);
    figure
    set(gcf, 'MenuBar', 'none')
    set(gcf, 'ToolBar', 'none')
    set(gcf, 'Windowstate', 'fullscreen')
    set(gca, 'visible', 'off')
    set(gcf, 'Color', 'k')
    pause(.1);
    instructions = sprintf(['In this experiment you will hear two types of tones;\n' ...
        'A low tone and a high tone.\n' ...
        'When you hear the LOW TONE you have to PRESS SPACE BAR as soon as possible.\n' ...
        'When you hear the HIGH TONE you have to DO NOTHING.\n\n'...
        'Press any key to start the practice' ...
        ]);
    t_practice = text(.1, .6, instructions, 'color', 'w','fontsize', 20);
    
    pause(.1)
    KbWait([],2);
    set(t_practice, 'Visible', 'off')
    
    % run trials
    t_fixcross = text(.45, .5, '+', 'color', 'w','fontsize', 40);
    pause(.1)
    KbWait([],2);
    close
    ListenChar();
catch
    close
    ListenChar();
end
