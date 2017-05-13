PHISgrape=imread('Image002_ch01.tif');

cutoff1=160;
cutoff2=50;

se4=strel('disk',4);
se5=strel('disk',5);
se6=strel('disk',6);

PHIStop456=(double(imtophat(PHISgrape,se4))-3*double(PHISgrape)+double(imtophat(PHISgrape,se5))+double(imtophat(PHISgrape,se6)));

PHIStop456mask120=(abs(PHIStop456)>cutoff1);
PHIS120label=bwlabel(PHIStop456mask120,4);
regproadd1=regionprops(PHIS120label);

PHIStop456mask50=(abs(PHIStop456)>cutoff2);
add2mask=imopen((PHIStop456mask50-PHIStop456mask120),se6);
add2label=bwlabel(add2mask,4);
regproadd2=regionprops(add2label);
add3mask=(imopen(imopen((PHIStop456mask50-PHIStop456mask120),se5)-imopen((PHIStop456mask50-PHIStop456mask120),se6),se5));
add3label=bwlabel(add3mask,4);
regproadd3=regionprops(add3label);

totalmask=logical(PHIStop456mask120+add2mask+add3mask);
totalregpro=[regproadd1; regproadd2; regproadd3];

totalplay=uint8(totalmask);
for i=1:length(totalregpro)
    totalplay(round(totalregpro(i).Centroid(2)),round(totalregpro(i).Centroid(1)))=2;
end
figure; imagesc(totalplay)

clear PHIScent
for i=1:length(totalregpro)
    PHIScent(i,1)=totalregpro(i).Centroid(1);
    PHIScent(i,2)=totalregpro(i).Centroid(2);
end