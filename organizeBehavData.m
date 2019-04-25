function  organizeBehavData ()
% OrgData is meant to combine experimental metadata with classification 
% values calculated by JAABA seperate data on a per fly basis 
% (JAABA: The Janelia Automatic Animal Behavior Annotator
% Copyright 2012, Kristin Branson, HHMI Janelia Farm Resarch Campus)

% **The following file structure is expected to exist:
% expfolder/datefolder/moviefolder/trackingfolder/JAABAfolder/

%INPUTS are queried: First, the experimental folder - expfolder
%Second, the excel file containing per-fly metadata - infofile
    % Required fieldnames for excel file (order doesn't matter): 
    % "movies" -contains movie folder name
    % "fly" - index of fly assigned by tracker
    % "genotype" - integer or character differentiating flies of different kinds
    
    % Optional filednames for excel file: 
    % "fps" - frames per second of movie file
    % "frameshift" - amount (pos or neg) to shift frames,
    % vararg - can input any other metadata you care about
    
% OUTPUT: flymatAll - saved mat file containing metadata and scores data for
%                     each fly


% Query user for experiment folder and info file
expfolder = uigetdir('','Select Experiment Folder'); 
cd(expfolder);
infofile = uigetfile('*.xlsx','Select Info File'); 

% Organize data into a structure
[scoresgalore,info] = makeScoreStruct(expfolder,infofile);

% Now organize data by fly
[flymatAll] = makeFlymat(scoresgalore,info);

% Save file
if ~isempty(strfind(expfolder, '/'))
    pathnames = strsplit(expfolder,'/');
elseif ~isempty(strfind(expfolder,'\'))
    pathnames = strsplit(expfolder,'\');
end
experimentname = pathnames(end);
filename = char(strcat('FLYMAT_',experimentname,'.mat'));
save(filename,'flymatAll','-v7.3');

end
