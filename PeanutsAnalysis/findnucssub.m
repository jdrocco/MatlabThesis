function [totalmaskPHIS,totalregproPHIS]=findnucsone(origim,sesize,intcutlow,intcuthigh,areamax,steppers)

% origim=double(origim);
if(~exist('steppers'))
    steppers=100;
end

if(max(origim(:)>65535))
    origim=65535*double(origim)/double(max(origim(:)));
end

cutoff1=intcuthigh;
cutoff2=intcutlow;
areacutoff=areamax;

se4=strel('disk',sesize-1);
se5=strel('disk',sesize);
se6=strel('disk',sesize+1);


PHISimp456=uint16(-(double(imtophat(origim,se5))-double(origim)));
h=fspecial('gaussian',ceil(length(origim)/10),ceil(length(origim)/45));
PHIStop456=double(PHISimp456)-deconvlucy(imfilter(origim,h),h);

totalmaskPHIS=zeros(size(PHIStop456));
totallabelPHIS=totalmaskPHIS;
intrange=linspace(cutoff1,cutoff2,steppers);
clear totalregproPHIS

for q=intrange
    curropen1=imopen(imopen(PHIStop456>q,se5)-totalmaskPHIS,se5);
    curregpro=regionprops(bwlabel(curropen1,4),'Centroid','Area','PixelIdxList');
    for i=1:length(curregpro)
        if(curregpro(i).Area>areacutoff)
            curropen1(curregpro(i).PixelIdxList)=0;
        end
    end
    labelPHISnow=bwlabel(curropen1,4);
%     imagesc(labelPHISnow); title(num2str(q)); pause(.5);
    if(~exist('totalregproPHIS','var'))
        totalregproPHIS=regionprops(labelPHISnow,'Centroid','Area','PixelIdxList');
        ltrpPHISold=0;
    else
        ltrpPHISold=length(totalregproPHIS);
        totalregproPHIS=[totalregproPHIS;regionprops(labelPHISnow,'Centroid','Area','PixelIdxList')];
    end
    labelPHISnow(labelPHISnow>0)=labelPHISnow(labelPHISnow>0)+ltrpPHISold;
    totallabelPHIS=totallabelPHIS+labelPHISnow;
    totalmaskPHIS=totalmaskPHIS+curropen1;
end

totalmaskPHIS=logical(totalmaskPHIS);