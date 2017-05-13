
% imstack is for a single embryo and has indices:
% 1: number in sequence
% 2: slice in stack
% 3: channel
% 4: trans dimension
% 5: AP dimension

% chancontrol is the channel to use to determine the top
% i.e. should be the one without Bcd fluorescence
% use zero if just one channel and there no 3rd index

function toploc=findtop(imstack,chancontrol)

if(~exist('chancontrol','var'))
    chancontrol=1;
end

if(~chancontrol)
    imsummer=sum(sum(imstack,4),3);
else
    imsummer=sum(sum(imstack(:,:,chancontrol,:,:),5),4);
end

imsumall=squeeze(sum(imsummer,1));

[val,toploc]=min(diff(imsumall'));