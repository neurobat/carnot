function MaskIcon(block)
    set_param(block,'MaskDisplay',...
        sprintf(['plot(10,10,90,100,[40,40,45,55,60,60,55,45,40],[84,36,30,30,36,84,90,90,84],[40,35],[77,77],[64,60],[77,77],[40,35],[42,42],[64,60],[42,42])']));
    set_param(block,'BackgroundColor',mat2str([240,0,0]/255));    
end
