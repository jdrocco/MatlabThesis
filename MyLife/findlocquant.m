% Embim is the fluorescence intensity image. Maskaprat is an image
% containing the mask with values from 0 to 1 representing AP axis
% location. Apboxes is the number of slices to take along the AP axis.
% [locquant,locconc,csrad,nucrad]=findlocquant(embim,maskaprat,apboxes,xmpp,ympp)

function [locquant,locconc,nucrad,nucarea]=findlocquant(embim,maskaprat,apboxes,xmpp,ympp)

%Must use doubles! Otherwise you will max out the variable taking the sum
%Actually singles (i.e. float!) should be fine.
embim=single(embim);

if(~exist('apboxes','var'))
    apboxes=200;
end

locquant=zeros(apboxes,1);
nucarea=zeros(apboxes,1);
nucrad=zeros(apboxes,1);
locconc=nan(apboxes,2);

    apincrement=1/apboxes;
	for k=1:apboxes
        labeled=logical((maskaprat<(k*apincrement))&(maskaprat>((k-1)*apincrement)));
        if(max(labeled(:))==0)
            continue
        end
        regpro=regionprops(labeled,'Area','PixelList','PixelIdxList','Centroid','MajorAxisLength');
        if(length(regpro)>2)
%             disp('More than dor/ven in findlocquant');
            areavec=zeros(length(regpro),1);
            for i=1:length(regpro)
                areavec(i)=regpro(i).Area;
            end
            [trash,maxinds]=sort(areavec);
            regpronew(1)=regpro(maxinds(end));
            regpronew(2)=regpro(maxinds(end-1));
            regpro=regpronew;
        end
        if(length(regpro)==2)
            nucrad(k)=0.5*sqrt((regpro(1).Centroid(1)-regpro(2).Centroid(1))^2+(regpro(1).Centroid(2)-regpro(2).Centroid(2))^2);
            nucarea(k)=mean([regpro(1).Area regpro(2).Area]);
        else
            nucrad(k)=regpro.MajorAxisLength/4;
            nucarea(k)=regpro.Area/2; % Remember this was only for one side.
        end
        for j=1:length(regpro)
            locconc(k,j)=mean(embim(regpro(j).PixelIdxList));
        end
        concuse=nanmean(locconc(k,:));
        locquant(k)=2*pi*nucrad(k)*nucarea(k)*concuse;
    end
