% This function will calculate frap intensity values for a set of N
% bleaching regions as specified by bleachregs. figshow flag chooses
% whether to display image and curves in a plot.  intenspre/intenspost are
% the intensity curves and regradius is an N length vector of the radii.
%
% [intenspre,intensbleach,intenspost,regradius]=frapcurves(bleachregs,figshow)
%
% NOTE: Good for no zoom only.

function [intenspre,intensbleach,intenspost,meanrad,pretime,bleachtime,posttime]=frapcurvessatinf(bleachregs)

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

imtoplay=squeeze(sum(frapbleach.Images,1));
[freqs,bars]=hist(imtoplay(:),200);
barnow=5;
L=bwlabel(imtoplay>bars(barnow));
while(~(max(max(L))==bleachregs))
    barnow=barnow+1;
    L=bwlabel(imtoplay>bars(barnow));
end
Lfin=L;

%Use the bleaching series to find contiguous regions of bleaching
centstruct=regionprops(Lfin,'Centroid','Area');

%Use metadata to find the centers and radii of the bleached regions.
for i=1:bleachregs
    zoomrat=min([(frappre.Xdimreal/frapbleach.Xdimreal) (frappre.Ydimreal/frapbleach.Ydimreal)]);
    regradius(i)=(sqrt(centstruct(i).Area/pi))/zoomrat;
    % of course, xml leica has got the x and y backwards
end
    
[regradsor,lut]=sort(regradius);

tolerance=0.1;
counter=0;
for i=2:length(regradsor)
    if(~(abs(regradsor(i)/regradsor(i-1)-1)<tolerance))
        counter=counter+1;
        breakind(counter)=i-1;
    end
end
breakind(counter+1)=length(regradsor);
radregs=length(breakind);

dottermat=zeros([radregs size(frappb.Images,2) size(frappb.Images,3)]);
for i=1:radregs
    clear dottermed
    if(i==1)
        meanrad(i)=mean(regradius(1:breakind(i)));
        for j=1:breakind(i)
            dottermed(j,:,:)=(Lfin==lut(j));
        end
        dottersum=sum(dottermed,1);
        dottermat(i,:,:)=double(dottersum)/sum(dottersum(:));
    else
        meanrad(i)=mean(regradius((breakind(i-1)+1):breakind(i)));
        for j=(breakind(i-1)+1):breakind(i)
            dottermed(j,:,:)=(Lfin==lut(j));
        end
        dottersum=sum(dottermed,1);
        dottermat(i,:,:)=double(dottersum)/sum(dottersum(:));
    end
end

intenspre=zeros([radregs size(frappre.Images,1)]);
intenspost=zeros([radregs size(frappb.Images,1)]);
intensbleach=zeros([radregs size(frapbleach.Images,1)]);

for i=1:radregs
    for j=1:size(frappb.Images,1)
        imnow=squeeze(frappb.Images(j,:,:));
        pixelvals=double(imnow(logical(dottermat(i,:,:))));
        intenspost(i,j)=satcorrect(pixelvals);
    end
    for j=1:size(frappre.Images,1)
        imnow=squeeze(frappre.Images(j,:,:));
        pixelvals=double(imnow(logical(dottermat(i,:,:))));
        intenspre(i,j)=satcorrect(pixelvals);
    end
    for j=1:size(frapbleach.Images,1)
        imnow=squeeze(frapbleach.Images(j,:,:));
        pixelvals=double(imnow(logical(dottermat(i,:,:))));
        intensbleach(i,j)=satcorrect(pixelvals);
    end
end
