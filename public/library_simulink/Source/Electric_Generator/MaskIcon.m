function MaskIcon(block)
	set_param(block,'MaskDisplay',...
        sprintf(['plot(0,0,100,100,[40,20],[50,50],[40,40],[30,70],[50,50],[-0,100],[70,50],[50,50])']));
    set_param(block,'BackgroundColor',mat2str([128,128,255]/255));    
end
