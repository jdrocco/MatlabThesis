% This function plots the z stack of intensities for the given box and
% axis over time, indicating skin location as well.

function creststack(axid,boxid,timesinseries,zstep,stackermult,skinlocmult,hittriggermult)

map=colormap;
timerange=1:timesinseries;
figure;
for j=timerange
plot(zstep*(1:size(stackermult,4)),squeeze(stackermult(axid,j,boxid,:)),'color',squeeze(map(ceil((j-timerange(1)+1)*64/length(timerange)),:)));
hold on;
if(exist('skinlocmult'))
    plot(skinlocmult(axid,j,boxid),stackermult(axid,j,boxid,round(skinlocmult(axid,j,boxid)/zstep)),'*','color',squeeze(map(ceil((j-timerange(1)+1)*64/length(timerange)),:)));
end
if(exist('hittriggermult'))
    plot(zstep*hittriggermult(j,boxid),stackermult(axid,j,boxid,hittriggermult(axid,j,boxid)),'+','color',squeeze(map(ceil((j-timerange(1)+1)*64/length(timerange)),:)));
end
end
title(['Intensity z-stack at box ' num2str(boxid)]);
ylabel('Intensity');
xlabel('z (\mum)');
