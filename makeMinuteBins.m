
function [binned,binneddur] = makeMinuteBins(starts,binary,fps)
% Bins behavior bouts and behavior duration (frames) per minute
% behavior bouts are binned by the *start* of the behaviors

% INPUTS: starts - start frames for behavior bouts,
%         binary - logical array for behavior

% OUTPUTS: binned - binned behavior bouts, binneddur - binned duration

frames = length(binary); %total frames
secsperbin = 60; %seconds per bin
windows = 1:(fps*secsperbin):frames;
extfr = rem(frames,(fps*secsperbin));
bins = length(windows)-1;
minratio = 1; 

% Deal with extra frames if they aren't divisible by a minute by adding
% extra bin and making a ratio to divide binned values so they are per/minute
if extfr > 0
    bins = bins+1;
    windows(end+1) = frames;
    minratio = extfr/(fps*secsperbin);
%     disp(['FYI: Last minute bin is not divisible by a minute. It is ',...
%         num2str(extfr/fps),' seconds long'])
end

% Bin Data
binned = zeros(1,bins); 
binneddur = zeros(1,bins);
for b = 1:bins
    binned(b) = length(find((windows(b) < starts) & (starts < windows(b+1))));
    binneddur(b) = sum(binary(windows(b):windows(b+1)));
end
    binned(end) = binned(end)/minratio;
    binneddur(end) = binneddur(end)/minratio;

end