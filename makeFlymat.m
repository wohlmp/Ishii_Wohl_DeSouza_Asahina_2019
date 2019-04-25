function [flymatAll] = makeFlymat(scoresgalore,info)

% Organizes JAABA scores files and metadata for each fly. Also calculates
% duration of behaviors and divides behaviors into minute bins for ease of 
% analysis
%   Ususally called by organizeBehavData.m 

% INPUTS: scoresgalore  - structure containing scores data for each movie 
%         info - matlab table containing infofile contents

% OUTPUTS: flymatAll - structure containing scores and metadata for each fly


cnt=0;
% Loop through each movie file listed in infofile
for n=1:size(scoresgalore,2)
    index = scoresgalore(n).index;
    
    % Loop through each fly's data
    for s=1:length(index) % #flies per movie
        ind = index(s);
        cnt=cnt+1;
        vnames = info.Properties.VariableNames; % var names in infofile
        
        % Make variables in infofile fields in flymat structure
        for t=1:length(vnames);
            matname = strcat('flymat.',vnames(t));
            evalc([matname{1},' = info.',vnames{t},'(ind)']);
        end
       
        % Extract field names of behaviors that were scored by JAABA
        scorefields = fieldnames(scoresgalore);
        temp = [];
        for i = 1:length(scorefields)
            if strcmp(scorefields(i),'movie') || strcmp(scorefields(i),'index')
                temp(i) = 1;
            else
                temp(i) = 0;
            end
        end
        scorefields(find(temp)) = [];
        
        % Extract scored data for each fly and calculate total # of bouts,
        % total duration of bouts, and binned bout # and duration for each
        % minute (if sampling frequency is given in infofile as fps)
        for i = 1:length(scorefields)
            if ~isempty(scoresgalore(n).(scorefields{i})) % check if scores are there
                if length(scoresgalore(n).(scorefields{i}).t0s) < s
                    disp('WARNING: Number of flies specified in info file does not match number of flies tracked')
                end
                flymat.([scorefields{i},'_start']) = scoresgalore(n).(scorefields{i}).t0s{s};
                flymat.([scorefields{i},'_end']) = scoresgalore(n).(scorefields{i}).t1s{s};
                flymat.([scorefields{i},'_startsm']) = scoresgalore(n).(scorefields{i}).startsm{s};
                flymat.([scorefields{i},'_endsm']) = scoresgalore(n).(scorefields{i}).endsm{s};
                flymat.([scorefields{i},'_binary']) = scoresgalore(n).(scorefields{i}).binary{s};
                flymat.([scorefields{i},'_bouts']) = length(scoresgalore(n).(scorefields{i}).endsm{s});
                flymat.([scorefields{i},'_dur']) = sum(flymat.([scorefields{i},'_binary']));
                if any(strcmp('fps',fieldnames(info)))
                    [flymat.([scorefields{i},'_binbouts']),flymat.([scorefields{i},'_bindur'])] = ...
                        makeMinuteBins(flymat.([scorefields{i},'_startsm']),...
                        flymat.([scorefields{i},'_binary']),info.fps(1));
                end
            end
        end
        
        % Add info for that fly to the experiment structure
        flymatAll(cnt)=flymat;
    end
end