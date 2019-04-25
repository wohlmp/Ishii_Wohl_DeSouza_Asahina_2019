function B = smoothBehavBouts(allScores,frameshift,max_gap,min_bout)
% Processes JAABA output further by closing small gaps in behaviour bouts
% and getting rid of very small bouts that may be false positives

% INPUTS: max_gap - maximum isi for which two bouts will be combined
%         min_bout - minimum number of frames to call something a behavior

% OUTPUT: B - allScores structure with added fieldnames and values that
%             reflect recalculated behavior data based on frameshift, 
%             max_gap, and min_bout


% For behaviors that didn't need to go through thresholding (don't have
% thresholded behavior data), pull from original JAABA output
if ~isfield(allScores,'startth')
    allScores.startth = allScores.t0s;
    allScores.endth = allScores.t1s;
end

% Obtain the number of flies in a given movie
flies_n = size(allScores.t0s, 2);
frames = length(allScores.postprocessed{1});
for p = 1:flies_n;
    
    % Apply frame shift specified in info file if run from OrgData or manually entered
    startth = allScores.startth{p} + frameshift;
    endtth = allScores.endth{p} + frameshift;
    
    % Remove a behavior bout when it occurs at the very beginning or end of
    % a movie
    if ~(length(startth) == length(endtth))
        disp('start and end frames do not have equal elements')
        if length(startth) > length(endtth)
            startth = startth(1:length(endtth));
        else
            endtth = endtth(1:length(startth));
        end
    end
    
    % Merge bouts with a gap less than or equal to max_gap
    isi = startth(2:end)- endtth(1:(end-1)); %Gap between neighboring bouts
    startth((find(isi <= max_gap) + 1)) = [];
    endtth(find(isi <= max_gap)) = [];
    
    % Remove bouts that are less than or equal to min_bout
    boutlength = endtth - startth;
    startsm = startth(find(boutlength >= min_bout));
    endsm = endtth(find(boutlength >= min_bout));
    
    % Remove of bouts that may be have been shifted to before or after
    % the start or end of the movie
    startsm = startsm(find(startsm < frames));
    endsm = endsm(find(endsm <= frames));
    if length(startsm) > length(endsm)
        endsm = [endsm,frames];
    end
    
    allScores.startsm{p} = startsm;
    allScores.endsm{p} = endsm;
    
    % Recreate binary array to reflect changes applied in smoothing
    bouts = length(startsm);
    binary = zeros(1,frames);
    for b = 1:bouts
        if startsm(b) > 0;
            binary(startsm(b):endsm(b))=1;
        end
    end
    allScores.binary{p} = binary;
end

B = allScores;







