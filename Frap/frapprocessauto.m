imtoplay=squeeze(sum(imagestackbleach,1));
[freqs,bars]=hist(imtoplay(:),200);
L=bwlabel(imtoplay>bars(10));
centstructdry=regionprops(L,'Centroid','ConvexArea','Area');
while(~(max(max(L))==2))
    for j=1:length(centstruct)
        areavec(j)=centstruct(j).Area;
    end
    [mival,miloc]=min(areavec);
    imtoplay(L==miloc)=0;
    [freqs,bars]=hist(imtoplay(:),200);
    L=bwlabel(imtoplay>bars(10));
    centstructdry=regionprops(L,'Centroid','ConvexArea','Area');
end
if(centstruct(1).Area>centstruct(2).Area)
    smallregind=2;
    largeregind=1;
else
    smallregind=1;
    largeregind=2;
end
    radiustouse=round(sqrt(centstruct(smallregind).ConvexArea/pi));
    % of course, xml leica has got the x and y backwards
xsmregmicrons=(centstruct(smallregind).Centroid(2)-(size(imtoplay,1)/2))/(imparamsbleach.ypixels/imparamsbleach.ydimreal);
ysmregmicrons=(centstruct(smallregind).Centroid(1)-(size(imtoplay,2)/2))/(imparamsbleach.xpixels/imparamsbleach.xdimreal);
xlgregmicrons=(centstruct(largeregind).Centroid(2)-(size(imtoplay,1)/2))/(imparamsbleach.ypixels/imparamsbleach.ydimreal);
ylgregmicrons=(centstruct(largeregind).Centroid(1)-(size(imtoplay,2)/2))/(imparamsbleach.xpixels/imparamsbleach.xdimreal);
xsmregabsmic=xsmregmicrons-imparamsbleach.yorigin;
ysmregabsmic=xsmregmicrons-imparamsbleach.xorigin;
xlgregabsmic=xlgregmicrons-imparamsbleach.yorigin;
ylgregabsmic=xlgregmicrons-imparamsbleach.xorigin;

xsmregabspix=round(xsmregabsmic*(imparamsbeg.ypixels/imparamsbeg.ydimreal))+imparamsbeg.ypixels/2;
ysmregabspix=round(ysmregabsmic*(imparamsbeg.xpixels/imparamsbeg.xdimreal))+imparamsbeg.xpixels/2;
xlgregabspix=round(xlgregabsmic*(imparamsbeg.ypixels/imparamsbeg.ydimreal))+imparamsbeg.xpixels/2;
ylgregabspix=round(ylgregabsmic*(imparamsbeg.xpixels/imparamsbeg.xdimreal))+imparamsbeg.ypixels/2;
