function MaskIcon(block)
    set_param(block,'MaskDisplay',...
        sprintf(['plot(0,0,100,100,[10,40,50,40,10,10],[90,90,80,70,70,90],[28,28,22,22],[70,10,10,70],[70,80,80,70,70],[50,50,10,10,50],[77,77],[10,50],[73,73],[10,50],[76,76,74,74],[50,90,90,50])']));
    set_param(block,'BackgroundColor','magenta');    
end
