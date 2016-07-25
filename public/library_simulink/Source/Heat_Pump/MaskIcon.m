function MaskIcon(block)
	set_param(block,'MaskDisplay',...
        sprintf(['plot(20,20,80,100,[30,46,36,46,36,46,30],[40,40,50,60,70,80,80],[70,54,64,54,64,54,64,54,64,54,70],[40,40,44,50,55,60,65,70,75,80,80],[56,45],[95,95],[51,51],[82,95])']));
    set_param(block,'BackgroundColor','red');    
end
