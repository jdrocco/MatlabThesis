function [raddist,radstd,annarea]=findraddistandstdmask(imageraw,maskin,nannulin,figshow)

if(~exist('figshow','var'))
    figshow=0;
end

nannuli=nannulin;

L = bwlabeln(maskin);
S = regionprops(L, 'BoundingBox');
coors=floor(S.BoundingBox);
imagein=imageraw(coors(2):(coors(2)+coors(4)),coors(1):(coors(1)+coors(3)));

[majorsize,majorind]=max(size(imagein));
majorstep=majorsize/(2*nannuli);
[minorsize,minorind]=min(size(imagein));
minorstep=minorsize/(2*nannuli);

for i=1:size(imagein,majorind)
    for j=1:size(imagein,minorind)
        annulusind=max(ceil(sqrt(((i-(majorsize/2))/majorstep)^2+((j-(minorsize/2))/minorstep)^2)),1);
        if(majorind==1)
            annulusmat(i,j)=annulusind;
        else
            annulusmat(j,i)=annulusind;
        end
    end
end

for k=1:nannulin
    raddist(k)=mean(double(imagein(annulusmat==k)));
    radstd(k)=std(double(imagein(annulusmat==k)));
    annarea(k)=sum(sum(annulusmat==k));
end

if(figshow)
    figure; imagesc(imagein+0.25*max(imagein(:))*double(annulusmat));
end