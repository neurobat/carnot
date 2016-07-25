function AddToCarnotMDL(LibDirectory, CarnotDirectory, OffsetX, OffsetY)
% function AddToCarnotMDL
% This function is called by CreateCarnotMDL.
% Parameter:
%     LibDirectory:    Directory of the atomic libraries
%     CarnotDirectory: Directory of the file carnot.slx
%     OffsetX:         Offset of the block positions in horizontal direction
%     OffsetY:         Offset of the block positions in vertical direction
% 
% This file assembles all atomic libries in the sub-directories if LibDirectory to the file carnot.slx


% This file is part of the CARNOT Blockset.
% 
% Copyright (c) 1998-2015, Solar-Institute Juelich of the FH Aachen.
% Additional Copyright for this file see list auf authors.
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without 
% modification, are permitted provided that the following conditions are 
% met:
% 
% 1. Redistributions of source code must retain the above copyright notice, 
%    this list of conditions and the following disclaimer.
% 
% 2. Redistributions in binary form must reproduce the above copyright 
%    notice, this list of conditions and the following disclaimer in the 
%    documentation and/or other materials provided with the distribution.
% 
% 3. Neither the name of the copyright holder nor the names of its 
%    contributors may be used to endorse or promote products derived from 
%    this software without specific prior written permission.
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE 
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF 
% THE POSSIBILITY OF SUCH DAMAGE.
% **********************************************************************
% D O C U M E N T A T I O N
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
% author list:     aw -> Arnold Wohlfeil
%
% version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%
% Version   Author  Changes                                     Date
% 6.1.0     aw      created                                     oct2015



    warning('off','all');
    cd(CarnotDirectory)
    fprintf('Adding %s to the carnot library ...\n', LibDirectory);
    
    cd(LibDirectory);
    fprintf('\tSearching directories of the atomic libraries ...');
    %cd([(dirScript) '\ReleaseFunctions']);
    models(1).path=[];
    [models] = modelpaths(models, LibDirectory);
    fprintf(' done \n');
    %pause

    fprintf('\tCreating mask icons and sub-library blocks ...');
    %cd([(dirScript) '\ReleaseFunctions']);
    [position]=allicons(models, LibDirectory, CarnotDirectory, OffsetX, OffsetY);  %, origCarnot);
    fprintf(' done \n');
    %pause

    fprintf('\tChecking dependencies and status of the models ...');
    %cd([(dirScript) '\ReleaseFunctions']);
    [models]=dependenciesnstatus(models, LibDirectory, CarnotDirectory);
    fprintf(' done \n');
    %pause

    fprintf('\tcopying models ... ');
    %cd([(dirScript) '\ReleaseFunctions']);
    set_param('carnot','Lock','off');
    copymodels(models, LibDirectory, CarnotDirectory, position);
    fprintf(' done \n');
    %pause

    fprintf('\tCreating links ...')
    %cd([(dirScript) '\ReleaseFunctions']);
    linkmodels(models, CarnotDirectory);
    fprintf(' done \n');
    %pause

    %fprintf(' Lösche AtomicLibs, Testfiles, Makefiles, leere Ordner ...')
    %cd([(dirScript) '\ReleaseFunctions']);
    %cleanup(models, LibDirectory);
    %fprintf(' Erledigt \n \n');
    %cd(dirScript);

    set_param('carnot','Lock','on');
    save_system('carnot',[CarnotDirectory,'\carnot']);
    close_system('carnot', 0);
    
    cd(CarnotDirectory);
    fprintf('\n');

end



function [models]=modelpaths(models, LibDirectory)
% Findet Modelle und speichert Pfad
% dirLib gibt alle Lib-Ordner über, in aktuellem Standort an (nur ein Pfad)
    SkriptPath = cd;
    % models nimmt Name und Pfad der Modelle auf

    cd(LibDirectory);
    % Indizes
    iLevel=1; %  für Suchtiefe
    iBranch=NaN(1,100); % für Abzweigungen auf der Indizierten Ebene
    iBranch(1)=1;
    iModel=1; % des nächsten gefundenen Modells

    % dirLib enthält alle Ordner des aktuell durchsuchten Zweigs und alle
    % Abzweigungen von diesem ohne Unterordner
    dirActual=dir;
    dirActual=struct2cell(dirActual);
    decidefolder=[dirActual{4,:}];
    dirActualfolders = dirActual(1, find(decidefolder));

    [tok,rem] = strtok(fliplr(LibDirectory),'\');
    dirLib{1,1} = char(fliplr(tok));
    dirLib(iLevel+1,1:length(dirActualfolders(1,:)))=dirActualfolders(1,1:end);

    while iLevel>0 %&& Zaehler < 2
        %Zaehler=Zaehler+1
        %cd


        dirActual=dir;
        dirActual=struct2cell(dirActual);

        %Entscheide, ob library_atomic vorhanden
        if any(cellfun(@(x)strcmp(x, 'library_atomic'), dirActual(1,1:end),'UniformOutput',true))
            % In diesem Ordner muss ein Modell sein!    

            % Speichere Pfad des aktuellen Modells durch Auswerten von dirLib
            path{1,1}=dirLib{1,1};
            directory=LibDirectory;
            for i=2:iLevel 
                path{1,i}=dirLib{i,iBranch(i-1)-1};
                if directory(end)~='\'
                    directory=[directory,'\'];
                end
                directory=[directory, path{1,i}];
            end
            path{1,iLevel+1}='library_atomic';
            directory=[directory, '\', path{1,end}];
            models(iModel,1).path= path(:);
            models(iModel,1).blocks=[];
            now=cd;

            % Wechsle in AtomicLib
            cd(directory);
            % Zeige Inhalt
            dirAtomic=dir;
            cd(now);
            dirAtomic=struct2cell(dirAtomic);
            % Suche Modell
            indName=strfind(dirAtomic(1,:), '.mdl');
            % Falls nicht gefunden suche nach alternativer Endung
            if all(cellfun(@isempty,indName))
                indName=strfind(dirAtomic(1,:), '.slx');
            end
            
            if ~all(cellfun(@isempty,indName))
                % Speichere Modellname
                A= dirAtomic{1,~cellfun(@isempty,indName)};
                A= cellstr(A(1:end-4));
                models(iModel,1).name{1,1}= A;

                iModel=iModel+1;
            end
            clear path;
        elseif ~strcmp(dirActual(1,end),'..')
            % Hier ist kein Modell
            % in Zeile 4 von cell ist isdir aufgeführt: 1/0
            decidefolder=[dirActual{4,:}];
            dirActualfolders = dirActual(1, find(decidefolder));

            % Ist der erste Buchstabe im Name ein Punkt sollte es sich um keinen 
            % regulären Ordner handeln, aussortiert:    
            unregular = cellfun(@(x)strfind(x(1),'.'),dirActualfolders(1,:),'UniformOutput', false);
            dirActualfolders= dirActualfolders(find(cellfun(@isempty,unregular)));

            % Speichere übrige Ordner in dirLib
            if iLevel+1 <= size(dirLib,1)
                dirLib(iLevel+1,:) = [];
            end
            dirLib(iLevel+1,1:length(dirActualfolders(1,:)))=dirActualfolders(1,1:end);
            % Merke auf aktueller Ebene in diesem Pfad zu durchsuchende
            % Unterordner
            nBranch(iLevel)= length(dirActualfolders(1,1:end));
        else
            % Ordner ist leer
            nBranch(iLevel)=0;
        end

        % Aufsteigen oder Absteigen?
        if ~any(cellfun(@(x)strcmp(x, 'library_atomic'), dirActual(1,1:end),'UniformOutput',true))
        % kein AtomicLib im aktuellen Ordner absteigen, falls...
            if nBranch(iLevel)  &&  isnan(iBranch(iLevel))
                % disp('Absteigen A')
                % Ordner ist nicht leer
                iBranch(iLevel) = 1;
                cd(dirLib{iLevel+1,iBranch(iLevel)});
                iBranch(iLevel) = iBranch(iLevel) +1;
                iLevel=iLevel+1;
                continue % Restliche Anweisungen der while Schleife ausgelassen
            elseif iBranch(iLevel) <= nBranch(iLevel)
                % wechsle in nächsten Unterordner
                % iLevel
                % iBranch(iLevel)
                % nBranch(iLevel)
                % disp('Absteigen B');  
                cd(dirLib{iLevel+1,iBranch(iLevel)});
                iBranch(iLevel) = iBranch(iLevel)+1;  
                iLevel=iLevel+1;
                continue % Restliche Anweisungen der while Schleife ausgelassen
            end
        end

        % Springe eine Ebene nach oben
        cd ..;
        clear dirLib{iLevel,:}
        iBranch(iLevel)=1; % Index der gerade durchsuchten Ebene zurücksetzen
        iLevel=iLevel-1; % Index der Ebene um 1 zurückgezählt
    end

    cd(SkriptPath);
end








function [position]=allicons(models, LibDirectory, CarnotDirectory, OffsetX, OffsetY)
% findet iterativ die Bibliotheken und legt Blöcke in Simulink an.
% falls Animation vorhanden eingefügt
% Position der Elemente kann in manchen Fällen falsch sein.
    clear position
    SkriptPath = cd;

    cd(CarnotDirectory);
    load_system('carnot');
    if get_param('carnot','Lock')
        set_param('carnot','Lock','off')
    end
    % rename carnot_base to ...
    save_system('carnot',[CarnotDirectory,'\carnot'],'OverwriteIfChangedOnDisk',true);

    cd(LibDirectory);
    
    position.XY(1:2,1) = [OffsetX; OffsetY];% Jede Ebene enthält eine Werte-Tabelle darin X,Y. Darunter enthaltene Libs

    for j=1:length(models)
        %j
        clear PosLevelB
        pathPos = [];
        for iLevel=2:length(models(j,1).path)-2 
            %iLevel
            % Erstelle icons in i-tem Level, falls noch nicht vorhanden

            % Setze directory zusammen
            directory='carnot';
            for k=2:iLevel
                %k
                directory = [directory, '/', models(j,1).path{k,:}];
                existBlock=strcmp(find_system('carnot','SearchDepth', k-1), directory);
                % Merke zu prüfende Lib als "Index" für Positionsstruktur
                pathPos{1,k-1} = models(j,1).path{k,1};   
                % Prüfe ob bereits ein gleichnamiger icon existiert
                if ~any(existBlock)
                    %Falls nicht, erstelle und setze Layout
                    add_block('built-in/Subsystem',directory);
                    ThisDirectory = pwd;
                    cd([LibDirectory, directory(7:end)]);
                    if exist('MaskIcon.m','file')
                        MaskIcon(directory);
                    end
                    cd(ThisDirectory);

                    % Setze Größe
                    pos2(1) = 0;
                    pos2(3) = 50;
                    pos2(2) = 0;
                    pos2(4) = 50;

                    % Greife aktuelle Position aus position ab
                    if length(pathPos) >=2
                        PosLevel = getfield(position, pathPos{1,1:end-1});
                        PosLevel = PosLevel.XY;
                    else
                        PosLevel = position.XY;
                    end
                    PosLevelX = PosLevel(1,1);
                    PosLevelX = PosLevelX +20+(pos2(4)-pos2(2)); % Verschiebung in x 
                    PosLevelY = PosLevel(2,1);

                    set_param(directory,'Position',[PosLevelX-(pos2(4)-pos2(2)) PosLevelY+30 PosLevelX PosLevelY+30+pos2(3)-pos2(1)]);

                    % Zeilenumbruch, in Unterlibs ein Element pro Zeile
                    if PosLevelX >= 700
                        PosLevelY =  PosLevelY+40+50;
                        PosLevelX =  0; %   -20;
                    elseif iLevel > 2
                        PosLevelY = PosLevelY+90;
                        PosLevelX = 0;
                    end

                    % Speichere Position, für erstellten Ordner initialisiert,
                    % für beinhaltenden Ordner aktuelle Position
                    pathPos{1,end+1} = 'XY';
        %            if ~
        %            position = setfield(position, pathPos{1,1:end-1}, []);
                    position = setfield(position, pathPos{1,:}, [0; 0]);
                    %pathPos{1,end-1} = 'XY';
                    pathPosB = {pathPos{1,1:end-2}, 'XY'};
                    position = setfield(position, pathPosB{1,:}, [PosLevelX; PosLevelY]);
                end 
                clear PosLevel
            end
        end
        clear pathPos
    end
    %close_system all
    cd(SkriptPath)
end







function [models]=dependenciesnstatus(models, LibDirectory, CarnotDirectory)
    SkriptPath = cd;

    % get status of models
    fid = fopen([LibDirectory '/Status.txt']);
    status = textscan(fid, '%s %s');
    fclose(fid);

    for j=1:length(models)
        %j
        % Wechsle in Ordner des Modells
        directory=LibDirectory;
        for k=2:length(models(j,1).path)
           directory= [directory, '/', models(j,1).path{k,:}];
        end
        cd(directory)

        % Lade Modell, Finde alle abhängigen Blöcke
        modelname=models(j,1).name{1,1};
%         load_system(modelname)        % Bernd: auskommentiert, klappt nicht unter R2010b
        load_system(char(modelname))    % Bernd: umwandeln in char klappt
        % Finde referenzierte Blöcke
        used_blocks = find_system(modelname,...
            'LookUnderMasks','all','Type','block','BlockType','Reference');
        referenced_blocks = get_param(used_blocks,'SourceBlock');

        % 
        models(j,1).UsedBlockPaths = referenced_blocks;
        models(j,1).dependingOn = [];
        models(j,1).UsedBlockPaths = [];
        for k=1:length(used_blocks)
            [~,used_blocks{k,1}] = strtok(used_blocks{k,1},'/');
            [~,models(j,1).blocks{k,1}] = strtok(used_blocks{k,1},'/');
            %[~,referenced_blocks{k,1}] = strtok(referenced_blocks{k,1},'/');
            %referenced_blocks{k,1}=referenced_blocks{k,1}(2:end);
            %positions = strfind(referenced_blocks{k,1},'/');
            models(j,1).UsedBlockPaths{k,1}=referenced_blocks{k,1};%(positions(end)+1:end);
        end

         % Finde falls vorhanden, referenzierte Blöcke unter den Blöcken aus Libs

         iDepending=0;
         for k=1:length(referenced_blocks)
             for l=1:length(models)
                 if strcmp(referenced_blocks{k,1}, models(l,1).name{1,1})
                     iDepending=iDepending+1;
                     models(j,1).dependingOn{iDepending,1}= models(l,1).name{1,1};
                 end
             end
         end

        %Prüfe Status
        models(j,1).status = 0;
        indMod=find(strcmp(models(j,1).name{1,1}, status{1,1})); %Schleife auch durch status{1,2}([1 5 8 ...],1) ersetzbar
        % ...des eigentlichen Modells
        if (strcmpi(status{1,2}(indMod,1),'Done'))
            models(j,1).status = 1;
            % ...der referenzierten Blöcke
            for iDepending=1:length(models(j,1).dependingOn)
                % iDepending
                % Finde Originalblock in Status-Tabelle
                indDep=find(strcmpi(models(j,1).dependingOn{iDepending,1}, status{1,1}));
                if isempty(indDep) || ...
                        ~strcmpi(status{1,2}(indDep), 'Done')
                    % Kein Block gefunden oder Status nicht in Ordnung
                    models(j,1).status = 0;
                    models.messages(end+1,1)=['Referenziertes Modell', models(j,1).dependingOn,...
                        'Nicht freigegeben'];
                end    
            end
        end

        close_system(models(j,1).path{end-1,1});
        clear used_blocks %referenced_blocks
    end
    cd(LibDirectory)
    save_system('carnot', [CarnotDirectory,'\carnot']);
    cd(SkriptPath);

end








function copymodels(models, LibDirectory, CarnotDirectory, position)

    SkriptPath = cd;

    % Status okay?
    cd(CarnotDirectory)
    load_system('carnot');
    if get_param('carnot','Lock')
        set_param('carnot','Lock','off')
    end
    % rename carnot_base to ...
    save_system('carnot',[CarnotDirectory,'\carnot'],'OverwriteIfChangedOnDisk',true);
    
    cd(LibDirectory);

    for j=1:length(models)
        % Prüfe Status
        if models(j,1).status
            %j
            % Setze Pfade des Modells in ursprünglicher Lib und in Carnot
            % zusammen
            k=2;
            directory=[models(j,1).path{k,:}];
            for k=3:length(models(j,1).path)-2
               directory = [directory, '/', models(j,1).path{k,:}];
            end
            k=length(models(j,1).path)-2;
            % dirActLib = ['carnot/', directory];
            directory = [directory, '/', models(j,1).path{k+1,:}];
            directoryModel = [directory, '/library_atomic'];
            directoryCarnot = ['carnot/', directory];

            % Lade das System
            cd(directoryModel);
            if exist([models(j,1).path{end-1,1},'.mdl'],'file') || exist([models(j,1).path{end-1,1},'.slx'],'file')
                load_system(models(j,1).path{end-1,1});
            else
                load_system(['lib_',models(j,1).path{end-1,1}]);
            end
            %set_param(models(j,1).path{end-1,1},'Lock','off');
            % Suche und speichere Namen des Modells
            system = find_system(models(j,1).path{end-1,1},'SearchDepth',1);
            [tok,rem] = strtok(system(2),'/');
            rem = char(rem);
            modelname = rem(2:end);
            models(j,1).modelname = modelname;


            % add block & set link status
            cd(LibDirectory)
            
            add_block(char(system(2)), directoryCarnot) %, 'MakeNameUnique', 'on');

            %set link status to none if the block is not linked to carnot
            %this is important if there are links within the carnot library
            %e.g. if a block willl occur two times in carnot
            if ~strcmp(get_param(directoryCarnot,'LinkStatus'),'unresolved') %everything ok
                set_param(directoryCarnot, 'LinkStatus','none')
            else %something strange, might be a link within carnot
                if ~strcmp(strtok(get_param(directoryCarnot,'SourceBlock'),'/'),'carnot')
                    set_param(directoryCarnot, 'LinkStatus','none')
                end
            end


            iLevel = length(models(j,1).path);
            % Greife Position aus structure ab.
            posCar = position;
            pathPos = [];
            for iPath = 2 : length(models(j,1).path)-2
                posCar = getfield(posCar, models(j,1).path{iPath,1});
                pathPos{end+1,1}= models(j,1).path{iPath,1};
            end
            pathPos{end+1,1}= 'XY';
            posCarX = posCar.XY(1,1);
            posCar = posCar.XY(2,1);

            % Setze Position 
            pos = get_param(directoryCarnot, 'Position');
            posCar=posCar+40+(pos(4)-pos(2));
            set_param(directoryCarnot, 'Position',...
                [30 posCar-(pos(4)-pos(2)) 30+pos(3)-pos(1) posCar]);
            % cleanup
            close_system(models(j,1).path{end-1,1},0);
            % Speichere neue Position
            position=setfield(position, pathPos{:,1}, [posCarX; posCar]);
        else
            fprintf('Block %s konnte nicht zugefügt werden \nStatus ungültig, siehe Status.txt \n', models(j,1).path{end-1,:});
            % pause
        end

        

    end

    save_system('carnot', [CarnotDirectory,'\carnot']);
    cd(SkriptPath)
    
end







function linkmodels(models, CarnotDirectory)

    for j=1:length(models)
        % j
        % Prüfe Status
        if models(j,1).status
        % Modell wurde kopiert    
            % Prüfe alle im Modell verbauten Blöcke
            for l=1:length(models(j,1).blocks)
                pathDepending= 'carnot';
                for k= 2:length(models(j,1).path)-2
                    pathDepending=[pathDepending, '/', models(j,1).path{k,1}];
                end
                pathDepending=[pathDepending,'/', models(j,1).name{1,1}{:}];
                pathDepending=[pathDepending, models(j,1).blocks{l,1}];
                set_param(pathDepending,'ReferenceBlock',models(j,1).UsedBlockPaths{l})
            end 
        end 
    end

    save_system('carnot', [CarnotDirectory, '\carnot']);

end



