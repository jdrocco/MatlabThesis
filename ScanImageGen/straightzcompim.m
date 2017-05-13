for i=1:22
compim(i,:,:)=uint16(zeros(size(depther,1),size(depther,2)));
abshei=double((toploc(embnow)-max(depther(:))));
selnow=depther-(i-2-abshei);
for j=1:30
imuse=squeeze(imstack(12,j,2,:,:));
compim(i,selnow==j)=compim(i,selnow==j)+squeeze(imuse(selnow==j))';
end
end




