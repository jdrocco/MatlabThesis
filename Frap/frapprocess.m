function frapprocess(labelindexbleach)

% labelindexbeg=139;
% labelindexend=140;
% radius=9;
labelindexbeg=labelindexbleach+1;
labelindexend=labelindexbleach+2;
labelstring='*Series*';
imparamsbeg=crestleicxml(labelindexbeg);
imparamsend=crestleicxml(labelindexend);
imparamsbleach=crestleicxml(labelindexbleach);
imagestackbeg=crestleicsimpimport(labelstring,labelindexbeg,imparamsbeg.stacksize);
imagestackend=crestleicsimpimport(labelstring,labelindexend,imparamsend.stacksize);
imagestackbleach=crestleicsimpimport(labelstring,labelindexbleach,imparamsbleach.stacksize);
% if(~exist('ytrace'))
% figure; imagesc(squeeze(sum(imagestackbeg(1:imparamsbeg.stacksize,:,:),1)-sum(imagestackend(1:imparamsbeg.stacksize,:,:),1)));
% set(gcf,'Units','normalized')
% figpos=get(gcf,'position');
% set(gcf,'position',[0.16 0 .84 1])
% [xvel,yvel,xtrace,ytrace]=smoothwalksurfinterp(imparamsbeg,imagestackbeg);
% end
imtoplay=squeeze(sum(imagestackbleach,1));
[freqs,bars]=hist(imtoplay(:),200);
barnow=5;
L=bwlabel(imtoplay>bars(barnow));
h=fspecial('gaussian',10,1);
while(~(max(max(L))==2))
    barnow=barnow+1;
    L=bwlabel(imfill(imfilter(imtoplay,h)>bars(barnow),'holes'));
end
centstruct=regionprops(L,'Centroid','ConvexArea','Area');
if(centstruct(1).Area>centstruct(2).Area)
    smallregind=2;
    largeregind=1;
else
    smallregind=1;
    largeregind=2;
end
    radius=(sqrt(centstruct(smallregind).ConvexArea/pi)*(imparamsbleach.xdimreal(1)/imparamsbeg.xdimreal(1))*0.7);
    radiussm=(sqrt(centstruct(smallregind).ConvexArea)/2)*(imparamsbleach.xdimreal(1)/imparamsbeg.xdimreal(1))*0.9;
    radiuslg=(sqrt(centstruct(largeregind).ConvexArea)/2)*(imparamsbleach.xdimreal(1)/imparamsbeg.xdimreal(1))*0.9;
    % of course, xml leica has got the x and y backwards
xsmregmicrons=(centstruct(smallregind).Centroid(2)-(size(imtoplay,1)/2))/(imparamsbleach.ypixels(1)/imparamsbleach.ydimreal(1));
ysmregmicrons=(centstruct(smallregind).Centroid(1)-(size(imtoplay,2)/2))/(imparamsbleach.xpixels(1)/imparamsbleach.xdimreal(1));
xlgregmicrons=(centstruct(largeregind).Centroid(2)-(size(imtoplay,1)/2))/(imparamsbleach.ypixels(1)/imparamsbleach.ydimreal(1));
ylgregmicrons=(centstruct(largeregind).Centroid(1)-(size(imtoplay,2)/2))/(imparamsbleach.xpixels(1)/imparamsbleach.xdimreal(1));
xsmregabsmic=xsmregmicrons+imparamsbleach.yorigin(1);
ysmregabsmic=ysmregmicrons-imparamsbleach.xorigin(1);
xlgregabsmic=xlgregmicrons+imparamsbleach.yorigin(1);
ylgregabsmic=ylgregmicrons-imparamsbleach.xorigin(1);

xsmregabspix=round(xsmregabsmic*(imparamsbeg.ypixels(1)/imparamsbeg.ydimreal(1)))+imparamsbeg.ypixels(1)/2;
ysmregabspix=round(ysmregabsmic*(imparamsbeg.xpixels(1)/imparamsbeg.xdimreal(1)))+imparamsbeg.xpixels(1)/2;
xlgregabspix=round(xlgregabsmic*(imparamsbeg.ypixels(1)/imparamsbeg.ydimreal(1)))+imparamsbeg.xpixels(1)/2;
ylgregabspix=round(ylgregabsmic*(imparamsbeg.xpixels(1)/imparamsbeg.xdimreal(1)))+imparamsbeg.ypixels(1)/2;

for i=1:3
testimstack(i,:,:)=sum(imagestackend(floor((size(imagestackend,1)/3)*(i-1)+1):ceil((size(imagestackend,1)/3)*(i)-1),:,:),1);
end
nucposuse(1,1)=ysmregabspix;
nucposuse(1,2)=xsmregabspix;
nucposuse(2,2)=xlgregabspix;
nucposuse(2,1)=ylgregabspix;
% [xvel,yvel,xtrace,ytrace]=smoothwalksurfinterp(imparamsend,testimstack,nucposuse);
% 
% ignoretracking=0;
% outtraceuse=[[mean(ytrace,2)],[mean(xtrace,2)]];
% badnessoforig=sum(sum((outtraceuse-nucposuse).^2))
% if(badnessoforig>60)
%     disp('Warning--shift, ignoring tracking');
%     ignoretracking=1;
% end
% if((abs(max(xtrace(:,end)-xtrace(:,1)))>3)||(abs(max(ytrace(:,end)-ytrace(:,1)))>3))
%     disp('Warning--movement, ignoring tracking');
%     ignoretracking=1;
% end
ignoretracking=1;
if(ignoretracking)
    xsmtraceuse=xsmregabspix;
    ysmtraceuse=ysmregabspix;
    xlgtraceuse=xlgregabspix;
    ylgtraceuse=ylgregabspix;
end
% xsmtraceuse=round(outtraceuse(1,2));
% ysmtraceuse=round(outtraceuse(1,1));
% xlgtraceuse=round(outtraceuse(2,2));
% ylgtraceuse=round(outtraceuse(2,1));

h=fspecial('disk',radius);
hsm=fspecial('disk',radiussm);
hlg=fspecial('disk',radiuslg);
% must choose small nucleus first
dottermatsm=zeros(size(squeeze(imagestackbeg(1,:,:))));
dottermatsm(round(xsmtraceuse-radiussm):round(xsmtraceuse+radiussm),round(ysmtraceuse-radiussm):round(ysmtraceuse+radiussm))=hsm;
dottermatlg=zeros(size(squeeze(imagestackbeg(1,:,:))));
dottermatlg(round(xlgtraceuse-radiuslg):round(xlgtraceuse+radiuslg),round(ylgtraceuse-radiuslg):round(ylgtraceuse+radiuslg))=hlg;
figure; imagesc(dottermatsm*40000-dottermatlg*400000+squeeze(sum(imagestackend,1)/size(imagestackend,1)))
title(num2str(labelindexbleach));

for i=1:size(imagestackend,1)
smblout(i)=sum(sum(dottermatsm.*double(squeeze(imagestackend(i,:,:)))));
lgblout(i)=sum(sum(dottermatlg.*double(squeeze(imagestackend(i,:,:)))));
end
for i=1:size(imagestackbeg,1)
smblstart(i)=sum(sum(dottermatsm.*double(squeeze(imagestackbeg(i,:,:)))));
lgblstart(i)=sum(sum(dottermatlg.*double(squeeze(imagestackbeg(i,:,:)))));
end
% smnormalizer=mean(smblstart(2:end));
% lgnormalizer=mean(lgblstart(2:end));
smnormalizer=1;
lgnormalizer=1;
figure; plot(60*(imparamsbeg.timeinmin-imparamsbeg.timeinmin(1)),smblstart/smnormalizer,'r+');hold on; plot(60*(imparamsbeg.timeinmin-imparamsbeg.timeinmin(1)),lgblstart/lgnormalizer,'b+'); plot(60*(imparamsend.timeinmin(1,:)-imparamsbeg.timeinmin(1)),smblout(smblout>0)/smnormalizer,'r+');plot(60*(imparamsend.timeinmin(1,:)-imparamsbeg.timeinmin(1)),lgblout(lgblout>0)/lgnormalizer,'b+')
xlabel('Time (s)');
ylabel('Center nucleus intensity');
title(strcat('FRAP Series ',num2str(labelindexbleach)));
save(strcat('frapdump',num2str(labelindexbleach)));