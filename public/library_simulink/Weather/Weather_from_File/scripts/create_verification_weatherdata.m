modelfile = 'create_verification_weather_file';
% $Revision$
% $Author$
% $Date$
% $HeadURL$
load_system(modelfile)
simOut = sim(modelfile);
close_system(modelfile)
verification_weather_file = [[0:24]'*3600, simout];
save verification_weather_file verification_weather_file