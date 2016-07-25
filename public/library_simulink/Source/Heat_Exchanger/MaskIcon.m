function MaskIcon(block)
	set_param(block,'MaskDisplay',...
        sprintf(['plot(0,0,100,100,[70,30,30,70,70,30],[90,10,90,90,10,10])']));
    set_param(block,'BackgroundColor','red');    
end
