% Embim is the fluorescence intensity image. Maskaprat is an image
% containing the mask with values from 0 to 1 representing AP axis
% location. Apboxes is the number of slices to take along the AP axis.
% [locquant,locconc,csrad,nucrad]=findlocquant(embim,maskaprat,apboxes,xmpp,ympp)

function [locquant,locconc,csrad,nucrad]=findlocquant(embim,maskaprat,apboxes,xmpp,ympp)

%Must use doubles! Otherwise you will max out the variable taking the sum
embim=double(embim);

if(~exist('xmpp','var'))
    xmpp=1;
end

if(~exist('ympp','var'))
    ympp=1;
end

if(~exist('apboxes','var'))
    apboxes=100;
end

locquant=zeros(apboxes,1);
csrad=zeros(apboxes,2);
nucrad=zeros(apboxes,2);
locconc=zeros(apboxes,2);

    apincrement=1/apboxes;
	for k=1:apboxes
        locquant(k)=0;
        labeled=bwlabel((maskaprat<(k*apincrement))&(maskaprat>((k-1)*apincrement)));
        if(max(labeled(:))==0)
            continue
        end
        regpro=regionprops(labeled,'Area','PixelList','PixelIdxList','Centroid');
        if(length(regpro)>2)
	    clear areavec
            for i=1:length(regpro)
                areavec(i)=regpro(i).Area;
            end
            [trash,maxinds]=sort(areavec);
            regpronew(1)=regpro(maxinds(end));
            regpronew(2)=regpro(maxinds(end-1));
            regpro=regpronew;
        end
        if(length(regpro)==2)
            embmidpt=mean([regpro(1).Centroid ;regpro(2).Centroid]);
        else
            embmidpt=regpro.Centroid;
        end
        for j=1:length(regpro)
            for i=1:length(regpro(j).PixelIdxList)
%               distreal(i)=point_to_line([xmpp*regpro(j).PixelList(i,1) ympp*regpro(j).PixelList(i,2) 0],[xmpp*AP_x(1) ympp*AP_y(1) 0],[xmpp*AP_x(2) ympp*AP_y(2) 0]);
                distreal(i)=sqrt(((embmidpt(1)-regpro(j).PixelList(i,1))*xmpp)^2+((embmidpt(2)-regpro(j).PixelList(i,2))*ympp)^2);
                locquant(k)=locquant(k)+(xmpp*ympp*pi*distreal(i)*embim(regpro(j).PixelList(i,2),regpro(j).PixelList(i,1)));
                % Note: pi*r not 2pi*r because we use each side for only
                % half an annulus
            end
            csrad(k,j)=max(distreal);
            nucrad(k,j)=mean(distreal);
            locconc(k,j)=mean(embim(regpro(j).PixelIdxList));
            if(length(regpro)==1)
                csrad(k,2)=csrad(k,1);
                nucrad(k,2)=nucrad(k,1);
                locconc(k,2)=locconc(k,1);
            end
        end
    end
