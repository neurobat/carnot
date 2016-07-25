function MaskIcon(block)
	set_param(block,'MaskDisplay',...
        sprintf(['plot(30,40,60,90,[36,36,40,50,54,54,50,40,36],[90,50,45,45,50,90,93,93,90],[36,51,40,51,36],[74,74,79,85,85],[36,51,44,51,36],[54,54,56,58,58])']));
    set_param(block,'BackgroundColor','red');    
end
