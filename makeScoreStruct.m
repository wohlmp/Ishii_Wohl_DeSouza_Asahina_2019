function [scoresgalore,info] = makeScoreStruct(expfolder,infofile)
% Organizes JAABA scores files for each movie folder 
%   Ususally called by organizeBehavData.m  

% INPUTS: exfolder - path to experimental folder
%         infofile- name of excel file that contains per-fly metadata

% OUTPUTS: scoresgalore - structure containing scores data for each movie 
%                         specified by infofile
%          info - infofile converted into a matlab table


% Extract experiment info and determine slash direction (PC vs Mac)
if ~isempty(strfind(expfolder, '/'))
    pathnames = strsplit(expfolder,'/');
    slash = '/';
elseif ~isempty(strfind(expfolder,'\'))
    pathnames = strsplit(expfolder,'\');
    slash = '\';
end;
experimentname = pathnames(end);
info=readtable(infofile);
infomovielist = info.movie; %pick out movies represented in infofile
infomoviefolders = unique(infomovielist);
expfiles=dir; %get filenames within date folder
for i = 3:length(expfiles)
    temp(i) = isdir(expfiles(i).name);
end
expfiles = expfiles(find(temp));
cnt = 0;

% For current date folder, determine which movie folders to analzye
for e=1:length(expfiles)
    datefolder = expfiles(e).name;
    datefiles = dir([expfolder,slash,datefolder]);
    moviefolders = {};
    for i = 3:length(datefiles)
        moviefolders(i-2) = {datefiles(i).name};
    end
    temp = [];
    for i = 1:size(infomoviefolders,1)
        try
            temp(i) = find((strcmp(infomoviefolders(i),moviefolders)));
        end
    end
    if isempty(temp)
        continue
    else
        temp(temp == 0) = [];
    end
    analyzefolders = moviefolders(temp); %these are the movie folders we will analyze
    
    % For current analysis folder, pull out relevant info from info file
    for i = 1:length(analyzefolders)
        analyzefolder = analyzefolders{i};
        disp(['Evaluating the experiment folder: ',analyzefolder])
        infoindex = find(strcmp(infomovielist,analyzefolder));
        
        % If there is a 'frameshift' field in infofile, note it
        % (this is for when LED flashes before or after expected time)
        if any(strcmp('frameshift',fieldnames(info)))
            frameshift = info.frameshift(infoindex(1));
        else
            frameshift = 0; %if no frameshift specified
        end;
        
        % Find tracking folder
        moviefiles = dir([expfolder,slash,datefolder,slash,analyzefolder]);
        temp = [];
        for j = 3:size(moviefiles,1)
            temp(j) = isdir(moviefiles(j).name);
        end
        if sum(temp) > 1
            trackfolder = uigetdir([expfolder,slash,datefolder,slash,analyzefolder]);
            trackfolder = trackfolder.name;
            trackfolder = strsplit(trackfolder,slash); trackfolder = trackfolder(end);
        elseif sum(temp) == 0
            disp('WARNING: cannot find tracking folder')
        else
            trackfolder = moviefiles(find(temp)).name;
        end;
        
        % Find JAABA folder
        trackfiles = dir([expfolder,slash,datefolder,slash,analyzefolder,slash,trackfolder]);
        temp = [];
        for j = 3:size(trackfiles,1)
            temp(j) = isdir(trackfiles(j).name);
        end
        if sum(temp) > 1
            JAABAfolder = uigetdir([expfolder,slash,datefolder,slash,analyzefolder,slash,trackfolder]);
            JAABAfolder = JAABAfolder.name;
            JAABAfolder = strsplit(JAABAfolder,slash); JAABAfolder = JAABAfolder(end);
        elseif sum(temp) == 0
            disp('WARNING: cannot find JAABA folder')
        else
            JAABAfolder = trackfiles(find(temp)).name;
        end;
        
        % Identify score files
        JAABAfiles = dir([expfolder,slash,datefolder,slash,analyzefolder,slash,trackfolder,slash,JAABAfolder]);
        temp = []; scorefiles = {};
        for j = 3:size(JAABAfiles,1)
            temp(j) = strncmp('scores',JAABAfiles(j).name,6);
            scorefiles{j} = JAABAfiles(j).name;
            if ~isempty(strfind(scorefiles{j},'~'))
                temp(j) = 0;
            end
        end
        scorefiles = scorefiles(find(temp));
        cnt = cnt+1;
        
        % Extract scored data from JAABA folder
        for n=1:length(scorefiles);
            scorefile = scorefiles{n};
            try
                scoresmat = load([expfolder,slash,datefolder,slash,analyzefolder,...
                    slash,trackfolder,slash,JAABAfolder,slash,scorefile]);
            end
            if ~isempty(strfind(scorefile,'unge'))
                A = changeJAABAconfidenceValCutoff(scoresmat.allScores,0.1); %(Scores, threshold)
                B = smoothBehavBouts(A,frameshift,1,4);  %(Scores, frameshift, max gap, min bout)
                scoresgalore(cnt).L = B;
            elseif ~isempty(strfind(scorefile,'butt'))
                A = changeJAABAconfidenceValCutoff(scoresmat.allScores,0.1);
                B = smoothBehavBouts(A,frameshift,1,3);
                scoresgalore(cnt).HB = B;
            elseif ~isempty(strfind(scorefile,'xt'))
                A = changeJAABAconfidenceValCutoff(scoresmat.allScores,0.1);
                B = smoothBehavBouts(A,frameshift,3,6);
                scoresgalore(cnt).WE = B;
            elseif ~isempty(strfind(scorefile,'harge'))
                A = changeJAABAconfidenceValCutoff(scoresmat.allScores,0.0);
                B = smoothBehavBouts(A,frameshift,1,4);
                scoresgalore(cnt).C = B;
            elseif ~isempty(strfind(scorefile,'hreat'))
                A = changeJAABAconfidenceValCutoff(scoresmat.allScores,0.1);
                B = smoothBehavBouts(A,frameshift,1,6);
                scoresgalore(cnt).WT = B;
            elseif ~isempty(strfind(scorefile,'ussling'))
                A = changeJAABAconfidenceValCutoff(scoresmat.allScores,0.0);
                B = smoothBehavBouts(A,frameshift,1,6);
                scoresgalore(cnt).T = B;
            elseif ~isempty(strfind(scorefile,'olding'))
                A = changeJAABAconfidenceValCutoff(scoresmat.allScores,0.0);
                B = smoothBehavBouts(A,frameshift,3,6);
                scoresgalore(cnt).H = B;
            end;
            scoresgalore(cnt).movie = analyzefolder;
            scoresgalore(cnt).index = infoindex; %adding index of flies in infofile
        end
    end
end


% Save Data
% filename = char(strcat('scoresgalore_',experimentname,'.mat'));
% save(filename,'scoresgalore','-v7.3');
end

