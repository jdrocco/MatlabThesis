function imfursfix=fiximphaseplane(imfurs,shiftera,shifterb)

for j=1:size(imfurs,1)
if(mod(j,2))
imfurssh(j,:)=circshift(squeeze(imfurs(j,:))',shiftera);
else
imfurssh(j,:)=circshift(squeeze(imfurs(j,:))',-shifterb);
end
end
imfursfix=imfurssh(:,(max(abs([shiftera shifterb]))+1):(end-max(abs([shiftera shifterb]))));