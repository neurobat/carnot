function MaskIcon(block)
    set_param(block,'MaskDisplay',...
        sprintf(['plot(0,0,100,100,[80,20],[10,10],[70,55,45,30],[10,90,90,10])']));
    set_param(block,'ForegroundColor','gray');    
    set_param(block,'BackgroundColor','black');    
end
