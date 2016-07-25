function MaskIcon(block)
	set_param(block,'MaskDisplay',...
        sprintf(['plot(0,0,100,100,[0,10,16,19,20],[80,81,84,90,100],[7,10],[79,60],[17,30],[84,70],[21,40],[94,90],[30,90,100,40,30],[10,70,60,-0,10],[90,90,40,33],[70,60,10,13],[89,39],[61,12])']));
    set_param(block,'BackgroundColor','yellow');    
end
