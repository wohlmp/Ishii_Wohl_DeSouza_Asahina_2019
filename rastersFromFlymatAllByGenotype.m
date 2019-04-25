function  rastersFromFlymatAllDataByGenotype(flymatAll,behavior,vswho)

% This codes makes raster plots by grabbing binary behavior values from flymat files
% It will split data by genotype and make a raster plot for each genotype

% INPUT: flymatALL - data structure spit out by OrgData including metadata
%                    JAABA output for each fly
%        behavior - string of behavior name you would like make into
%                   rasters
%        vswho - string that will appear on raster title

% OUTPUT: raster figures for each genotype

% Example : rastersFromFlymatAllDataByGenotype(flymatAll,'headbutt','vs CSMH males January')


% Graph parameters
stimon = 1 ; %set stimon = 1 if you want rectangles over stimulation windows
LineFormatL.Color = [0 0 0]; % raster line color
LineFormatL.LineWidth = .1; % rasterlines smaller than .1 are hard to see
StimRectangleColor = [0.5 0.5 0.5];

% Stimulation parameters used to make rectangle overlays for rasters
fps = 60;
reps = 1; % number of stimulation window(s)
pre = 300*fps; % frames before first stimulation
dur = 300*fps; % duration of stimulation(s)
int = 300*fps; % inter-stimulus interval

% Cycle through genotypes and graph rasters
genotypes = unique([flymatAll.genotype]);
for g = 1:length(genotypes)
    tempflymat = flymatAll([flymatAll.genotype] == genotypes(g)); %subset of flymat by genotype
    cnt=0;
    
    % Get data for specified behavior
    if (length(strfind(behavior,'unge')) >= 1) && (isempty(strfind(behavior,'~')))
        behavbinary = logical(permute(cell2array([{tempflymat.L_binary}]),[3,2,1])); 
    elseif(length(strfind(behavior,'butt')) >= 1) && (isempty(strfind(behavior,'~')))
        behavbinary = logical(permute(cell2array([{tempflymat.HB_binary}]),[3,2,1])); 
    elseif(length(strfind(behavior,'xtension')) >= 1) && (isempty(strfind(behavior,'~')))
        behavbinary = logical(permute(cell2array([{tempflymat.WE_binary}]),[3,2,1]));
    elseif(length(strfind(behavior,'harge')) >= 1) && (isempty(strfind(behavior,'~')))
        behavbinary = logical(permute(cell2array([{tempflymat.CH_binary}]),[3,2,1])); 
    elseif(length(strfind(behavior,'hreat')) >= 1) && (isempty(strfind(behavior,'~')))
        behavbinary = logical(permute(cell2array([{tempflymat.WT_binary}]),[3,2,1])); 
    end;
    
    % Initialize figure
    figure
    hold on
    ylabel('Flies');
    xlabel('Frames');
    
    % Plot stimulation overlay rectangles
    if stimon == 1 
        for n = 1:reps;  
            recT(n)= pre+(dur*(n-1))+(int*(n-1));
        end;
        for n = 1:length(recT) 
            rectangle('Position',[recT(n) 0 dur length(behav)],'Edgecolor','w','Facecolor',StimRectangleColor]) 
        end;
    end;
    
    % Plot and save rasters
    plotSpikeRaster(behavbinary,'PlotType','vertline','LineFormat',LineFormatL);
    figurename = strcat(behavior,vswho,' genotype ',num2str(genotypes(g)));
    title(figurename);
    hold off
    filename = strcat(figurename,'.eps');
    print('-depsc', filename)
end

end






