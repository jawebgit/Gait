function [frame,strike,ankle_norm,avg_stance] = gaitphase(force,ankle,freq)
%GAITPHASE is used to determine gait events from the supplied forceplate and ankle position data.
% 
%Usage:
%[frame,strike,ankle_norm] = GAITPHASE(force,ankle);
% 
%frame - Outputs a vector consisting index of heel-strikes.
% 
%strike - Outputs a nx3 vector consisting toe-strike, heel-off, toe-off respectively.
% 
%ankle_norm - Outputs a normalized ankle vector zeroed at heel-strikes (aquired signal offset removal).
% 
%force - Input vector consisting of cleaned forceplate data.
%See also CLEANGRF
% 
%ankle - Input vector consisting of raw aquired goniometer signal.
tic;
count = 0;
icount = 0;%Set counter
for i = 1:length(force)-1
    if force(i,1) <= 0 && force(i+1,1) > 0
        count = count+1;
        frame(count,1) = i;%Pull sample number corresponding to heelstrike
    elseif force(i,1) > 0 && force(i+1,1) <= 0
        icount = icount+1;
        strike(icount,1) = i;
    end
    
end 
frame = frame(2:end);
range = abs(diff(frame));%Count sample range for heelstrike
max_sample = max(range)+1;%Cycle with most number of points
min_sample = min(range)+1;%Cycle with most number of points
clearvars i
mex = zeros(length(frame),1);
for i=1:length(frame)-1
    mex = ankle(frame(i));
    ankle(frame(i):frame(i+1)-1) = ankle(frame(i):frame(i+1)-1)-mex;
end
% offset = mean(mex);
ankle_norm = ankle;
clearvars i count
toestrike = zeros(length(frame)-1,1);
heeloff = zeros(length(frame)-1,1);
toeoff = zeros(length(frame)-1,1);
count = 1;
for i = 1:length(frame)-1
    framx = ankle_norm(frame(i):frame(i+1));
    frac = range(i);
    toestrike(count,1) = frame(i) + find(framx == (min(ankle_norm(frame(i):frame(i)+round(0.2*frac)))),1,'first');
    heeloff(count,1) = frame(i) + find(framx == (max(ankle_norm(toestrike(i):frame(i)+round(0.55*frac)))),1,'first');
    toeoff(count,1) = frame(i) + find(framx == (min(ankle_norm(heeloff(i):frame(i)+round(0.75*frac)))),1,'first');  
    count = count+1;
end
%strike = [toestrike heeloff toeoff];
avg_stance = 0;%(mean(abs(strike(2:end) - frame(1:end-1))+1))/freq;
avg_time = (mean(range)+1)/freq;
disp(['Time Elapsed: ',num2str(toc),' seconds'])
disp(['Average Gait Cylce: ',num2str((avg_time)),' seconds'])
disp(['Average Stance Time: ',num2str(avg_stance),' seconds'])
disp(['Longest Gait Cycle: ',num2str((max_sample/freq)),' seconds'])
disp(['Shortest Gait Cycle: ',num2str((min_sample/freq)),' seconds'])
end