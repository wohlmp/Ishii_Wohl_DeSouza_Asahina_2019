
function A = changeJAABAconfidenceValCutoff(allScores,threshold)
% This allows you to change the thresholding of the confidence values from
% JAABA's default of zero to another value that you specify

% INPUTS: allScores - scores data structure from one classifier
%         threshold - the confidence interval at which a behavior will be counted

% OUTPUT: A - original allScores structure with added fields that reflect
%             new threshold values


% Normalize scores based on NormScore value given by JAABA
preNormalizedScores = allScores.scores;
binaryNT = cell(size(allScores.scores)); 
startNT = cell(size(allScores.scores)); endNT = cell(size(allScores.scores));
for p = 1:length(allScores.scores);
    normalizedScores = preNormalizedScores{p}/allScores.scoreNorm;
    
    % Create binary values (behavior / not behavior) based on new threshold
    binaryNewThresh = zeros(size(normalizedScores));
    binaryNewThresh(normalizedScores >= threshold) = 1;
    binaryNT{p} = binaryNewThresh;
    
    % Recalculate start and end frame cells for post-thresholded data
    starttemp = []; endtemp = []; flag = 0;
    for i = 1:length(binaryNewThresh)
        temp = binaryNewThresh(i);
        if temp == 1 && flag == 0
            starttemp = [starttemp,i];
            flag = 1;
        elseif temp == 0 && flag == 1
            endtemp = [endtemp,i];
            flag = 0;
        elseif temp ~= 0 && temp ~= 1
            disp('Warning: Binary contains non zero/one values')
        end
    end
    startNT{p} = starttemp;
    endNT{p} = endtemp;
end


%save new values to allScores structure
allScores.startNT = startNT;
allScores.endNT = endNT;
allScores.normalizedScores = normalizedScores;
allScores.binaryNT = binaryNT;
A = allScores;



