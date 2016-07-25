file = 'DE_Wuerzburg';
ext = 'dat';

% path definitions
parampath = fullfile('library_simulink', 'Weather', 'Weather_from_File', 'parameter_set');
filename = [file,'.',ext];
intfile = fullfile(path_carnot('int'), parampath, filename);
pubfile = fullfile(path_carnot('pub'), parampath, filename);

% show internal picture if defined, otherwise use public picture
if exist(filename,'file')      % search file on matlab path
    load (filename)
elseif exist(intfile,'file')   % search on internal path
    load(intfile)
elseif exist(pubfile,'file')   % search on public path
    load(pubfile)
end
