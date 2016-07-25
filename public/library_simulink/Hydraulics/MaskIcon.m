function MaskIcon(block)
    set_param(block,'MaskDisplay',...
        sprintf(['plot(0,0,100,100,[15,18,18,15,40,40,46,55,60,60,55,46,40,40,15,10,10,15],[60,53,46,40,40,20,24,24,20,80,85,85,80,60,60,53,46,40],[60,55,46,40],[20,15,15,20])']));
    set_param(block,'BackgroundColor','lightblue');
end
