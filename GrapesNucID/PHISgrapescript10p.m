PHISgrape=imread('Image010_ch00.tif');

cutoff1=240;
cutoff2=120;

se4=strel('disk',4);
se5=strel('disk',5);
se6=strel('disk',6);
areacutoff=100;

PHIStop456=uint16(-(double(imtophat(PHISgrape,se5))-double(PHISgrape))-(double(imtophat(PHISgrape,se4))-double(PHISgrape))-(double(imtophat(PHISgrape,se6))-double(PHISgrape)));

totalmaskPHIS=zeros(size(PHIStop456));
totallabelPHIS=totalmaskPHIS;
intrange=cutoff1:-2:cutoff2;
clear totalregproPHIS
% figure

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
        totalregproPHIS=regionprops(labelPHISnow);
        ltrpPHISold=0;
    else
        ltrpPHISold=length(totalregproPHIS);
        totalregproPHIS=[totalregproPHIS;regionprops(labelPHISnow)];
    end
    labelPHISnow(labelPHISnow>0)=labelPHISnow(labelPHISnow>0)+ltrpPHISold;
    totallabelPHIS=totallabelPHIS+labelPHISnow;
    totalmaskPHIS=totalmaskPHIS+curropen1;
end

totalmaskPHIS=logical(totalmaskPHIS);
totalplayPHIS=uint8(totalmaskPHIS);
for i=1:length(totalregproPHIS)
    totalplayPHIS(round(totalregproPHIS(i).Centroid(2)),round(totalregproPHIS(i).Centroid(1)))=2;
end
figure; imagesc(totalplayPHIS)

clear PHIScent
for i=1:length(totalregproPHIS)
    PHIScent(i,1)=totalregproPHIS(i).Centroid(1);
    PHIScent(i,2)=totalregproPHIS(i).Centroid(2);
end