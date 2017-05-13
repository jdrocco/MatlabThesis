% A function which plots the entire set of zstacks for a given time and
% axis, giving the sense of the embryo lying sideways.

function crestline(zstep,stackermult,axid,timeid,skinlocmult,hittriggermult)

stacker=squeeze(stackermult(axid,timeid,:,:));
skinloc=squeeze(skinlocmult(axid,timeid,:));
hittrigger=squeeze(hittriggermult(axid,timeid,:));
map=colormap;
axboxes=size(stacker,1);

for j=1:axboxes
    hold on;
    plot(zstep*(1:size(stacker,2)),squeeze(stacker(j,:)),'color',squeeze(map(ceil(j*64/axboxes),:)));
    if(exist('skinloc'))
        plot(zstep*skinloc(j),stacker(j,skinloc(j)),'*','color',squeeze(map(ceil(j*64/axboxes),:)));
    end
    if(exist('hittrigger'))
        plot(zstep*hittrigger(j),stacker(j,hittrigger(j)),'+','color',squeeze(map(ceil(j*64/axboxes),:)));
    end
end
title('Intensity z-stacks');
ylabel('Intensity');
xlabel('z (\mum)');
