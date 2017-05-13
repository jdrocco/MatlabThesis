% This plots the gradient timeseries of a single embryo at
% a single depth.
% Within crestmult tree

function crestplot(gradoutmult,timesinseries,AP_x,AP_y,depth,pxsize,pysize,zsize,axboxes,time,xppm,yppm,transdir)

xbs=round(2*pxsize/xppm);
ybs=round(2*pysize/yppm);

if(transdir==1)
    axialppm=yppm;
else
    axialppm=xppm;
end
timerange=1:timesinseries;
tottime=round(time(timerange(end))-time(timerange(1)));

map=colormap;
grads=figure;
for j=timerange
    micfac=sqrt((AP_x(j,1)-AP_x(j,2))^2+(AP_y(j,1)-AP_y(j,2))^2)/(axboxes*axialppm);
    figure(grads);
    plot((ceil(size(gradoutmult,2)/11):ceil(10*size(gradoutmult,2)/11))*micfac,squeeze(gradoutmult(j,ceil(end/11):ceil(10*end/11))),'.','color',squeeze(map(ceil((j-timerange(1)+1)*64/length(timerange)),:)));
    hold on;
end
title(['Anteroposterior profile of BG39 intensity at depth ',num2str(depth),' +/- ',num2str(zsize),' microns, total time ',num2str(tottime),' min']);
ylabel('Intensity');xlabel(['Position (microns), box size: ',num2str(xbs),' x ',num2str(ybs)]);
