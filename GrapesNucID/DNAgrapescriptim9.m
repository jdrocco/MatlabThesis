DNAgrape=imread('Image009_ch02.tif');

se3=strel('disk',3);
se4=strel('disk',4);
se2=strel('disk',2);

DNAtop234=(-(double(imtophat(DNAgrape,se3))-double(DNAgrape))-(double(imtophat(DNAgrape,se2))-double(DNAgrape))-(double(imtophat(DNAgrape,se4))-double(DNAgrape)));
DNAtop234shadow1=(uint16(DNAtop234-max(DNAtop234(:))*circshift(totalmask,[1 0])));

totalmaskDNA=zeros(size(DNAtop234));
totallabelDNA=totalmaskDNA;
intrange=200:-10:100;
clear totalregproDNA

for q=intrange
    curropen1=imopen(imopen(DNAtop234shadow1>q,se4)-totalmaskDNA,se4);
    curregpro=regionprops(bwlabel(curropen1,4),'Centroid','Area','PixelIdxList');
    for i=1:length(curregpro)
        if(curregpro(i).Area>64)
            curropen1(curregpro(i).PixelIdxList)=0;
        end
    end
    labelDNAnow=bwlabel(curropen1,4);
    if(~exist('totalregproDNA','var'))
        totalregproDNA=regionprops(labelDNAnow);
        ltrpDNAold=0;
    else
        ltrpDNAold=length(totalregproDNA);
        totalregproDNA=[totalregproDNA;regionprops(labelDNAnow)];
    end
    labelDNAnow(labelDNAnow>0)=labelDNAnow(labelDNAnow>0)+ltrpDNAold;
    totallabelDNA=totallabelDNA+labelDNAnow;
    totalmaskDNA=totalmaskDNA+curropen1;
end

totalmaskDNA=logical(totalmaskDNA);
totalplayDNA=uint8(totalmaskDNA);
for i=1:length(totalregproDNA)
    totalplayDNA(round(totalregproDNA(i).Centroid(2)),round(totalregproDNA(i).Centroid(1)))=2;
end
figure; imagesc(totalplayDNA)

clear DNAcent
for i=1:length(totalregproDNA)
    DNAcent(i,1)=totalregproDNA(i).Centroid(1);
    DNAcent(i,2)=totalregproDNA(i).Centroid(2);
end