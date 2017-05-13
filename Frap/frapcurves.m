% This function will calculate frap intensity values for a set of N
% bleaching regions as specified by bleachregs. figshow flag chooses
% whether to display image and curves in a plot.  intenspre/intenspost are
% the intensity curves and regradius is an N length vector of the radii.
%
% [intenspre,intensbleach,intenspost,regradius]=frapcurves(bleachregs,figshow)

function [intenspre,intensbleach,intenspost,regradius,pretime,bleachtime,posttime]=frapcurves(bleachregs,Lfin,figshow,noncirc)

if(~exist('bleachregs'))
    bleachregs=1;
end

if(~exist('figshow'))
    figshow=0;
end

if(~exist('noncirc'))
    noncirc=0;
end

%First import the images and metadata
frapbleach=leicaimport('FRAP Bleach Series*tif');
frappb=leicaimport(strcat('FRAP Pb1 Series',sprintf('%02d',str2num(frapbleach.Group(int16(frapbleach.Group)>47&int16(frapbleach.Group)<58))+2),'*.tif'));
frappre=leicaimport(strcat('FRAP Pre Series',sprintf('%02d',str2num(frapbleach.Group(int16(frapbleach.Group)>47&int16(frapbleach.Group)<58))+1),'*.tif'));

%Pare down the structures to the channel of interest
frapbleach.Images=frapbleach.Images(frapbleach.Channel==0,:,:);
frapbleach.GlobalTimeMin=frapbleach.GlobalTimeMin(frapbleach.Channel==0);
bleachtime=frapbleach.GlobalTimeMin;
frappre.Images=frappre.Images(frappre.Channel==0,:,:);
frappre.GlobalTimeMin=frappre.GlobalTimeMin(frappre.Channel==0);
pretime=frappre.GlobalTimeMin;
frappb.Images=frappb.Images(frappb.Channel==0,:,:);
frappb.GlobalTimeMin=frappb.GlobalTimeMin(frappb.Channel==0);
posttime=frappb.GlobalTimeMin;

%Use the bleaching series to find contiguous regions of bleaching
imtoplay=squeeze(sum(frapbleach.Images,1));
if(~exist('Lfin','var'))
    [freqs,bars]=hist(imtoplay(:),200);
    barnow=5;
    L=bwlabel(imtoplay>bars(barnow));
    while(~(max(max(L))==bleachregs))
        barnow=barnow+1;
        L=bwlabel(imtoplay>bars(barnow));
    end
else
    L=Lfin;
end
centstruct=regionprops(L,'Centroid','ConvexArea','Area');

%Use metadata to find the centers and radii of the bleached regions.
for i=1:bleachregs
    zoomrat=min([(frappre.Xdimreal/frapbleach.Xdimreal) (frappre.Ydimreal/frapbleach.Ydimreal)]);
    regradius(i)=(sqrt(centstruct(i).ConvexArea/pi))/zoomrat;
    % of course, xml leica has got the x and y backwards
    xrelmicrons(i)=(centstruct(i).Centroid(2)-(size(imtoplay,1)/2))/(frapbleach.Ypixels/frapbleach.Ydimreal);
    yrelmicrons(i)=(centstruct(i).Centroid(1)-(size(imtoplay,2)/2))/(frapbleach.Xpixels/frapbleach.Xdimreal);
    xabsmic(i)=xrelmicrons(i)+(frapbleach.Yorigin-frappb.Yorigin);
    yabsmic(i)=yrelmicrons(i)-(frapbleach.Xorigin-frappb.Xorigin);
    xabspix(i)=round(xabsmic(i)*(frappre.Ypixels/frappre.Ydimreal))+frappre.Ypixels/2;
    yabspix(i)=round(yabsmic(i)*(frappre.Xpixels/frappre.Xdimreal))+frappre.Xpixels/2;
end
    
dottermat=zeros([bleachregs size(frappb.Images,2) size(frappb.Images,3)]);
intenspre=zeros([bleachregs size(frappre.Images,1)]);
intenspost=zeros([bleachregs size(frappb.Images,1)]);
intensbleach=zeros([bleachregs size(frapbleach.Images,1)]);

for i=1:bleachregs
    if(~noncirc)
        diskmat=fspecial('disk',regradius(i));
        dottermat(i,round(xabspix(i)-regradius(i)):round(xabspix(i)+regradius(i)),round(yabspix(i)-regradius(i)):round(yabspix(i)+regradius(i)))=diskmat;
    else
        dottermed=(Lfin==i);
        dottermat(i,:,:)=double(dottermed)/sum(dottermed(:));
    end
    for j=1:size(frappb.Images,1)
        intenspost(i,j)=sum(sum(squeeze(dottermat(i,:,:)).*double(squeeze(frappb.Images(j,:,:)))));
    end
    for j=1:size(frappre.Images,1)
        intenspre(i,j)=sum(sum(squeeze(dottermat(i,:,:)).*double(squeeze(frappre.Images(j,:,:)))));
    end
    for j=1:size(frapbleach.Images,1)
        intensbleach(i,j)=sum(sum(squeeze(dottermat(i,:,:)).*double(squeeze(frapbleach.Images(j,:,:)))));
    end
end
    
if(figshow) 
    figure;
    imtodisp=double(squeeze(frappb.Images(1,:,:)));
    origmaxint=max(imtodisp(:));
    for i=1:bleachregs
        imtodisp=imtodisp+2*squeeze(dottermat(i,:,:))*origmaxint*regradius(i)^2;
    end
    imagesc(imtodisp);
    title(frapbleach.Group(int16(frapbleach.Group)>47&int16(frapbleach.Group)<58));
    
    figure; hold on;
    map=colormap;
    for i=1:bleachregs
        plot(frappre.GlobalTimeMin-frappre.GlobalTimeMin(1),intenspre(i,:),'+','color',map(ceil(i*64/bleachregs),:));
        plot(frappb.GlobalTimeMin-frappre.GlobalTimeMin(1),intenspost(i,:),'+','color',map(ceil(i*64/bleachregs),:));
    end
    xlabel('Time (min)');
    ylabel('Intensity');
    title(strcat('FRAP Series ',frapbleach.Group(int16(frapbleach.Group)>47&int16(frapbleach.Group)<58)));
end