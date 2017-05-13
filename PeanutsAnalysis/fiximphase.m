function imfursfix=fiximphase(imfurs,shifter)

if(~exist('shifter','var'))
shifter=1;
end

for i=1:size(imfurs,1)
for j=1:size(imfurs,2)
if(mod(j,2))
imfurssh(i,j,:)=circshift(squeeze(imfurs(i,j,:)),shifter);
else
imfurssh(i,j,:)=circshift(squeeze(imfurs(i,j,:)),-shifter);
end
end
end
imfursfix=imfurssh(:,:,(shifter+1):(end-shifter));