function MaskIcon(block)
	set_param(block,'MaskDisplay',...
        sprintf(['plot(0,0,100,100,[30,40,60,70,70,30,30],[50,44,44,50,10,10,50],[50,50],[44,57],[50,46,44,46,50,54,56,54,50],[93,85,70,54,48,54,70,85,93])']));
    set_param(block,'BackgroundColor','red');    
end
