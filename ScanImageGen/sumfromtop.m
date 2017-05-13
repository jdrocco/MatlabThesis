coola=nlslocs(mod(nlslocs,12)==6)
for i=1:length(coola)
for j=1:30
for k=1:2
imstack(i,j,k,:,:)=imread(files(coola(i)).name,(2*j)+k-2);
end
end
end
imsummer=sum(sum(imstack(:,:,chancontrol,:,:),5),4);
figure; plot(imsummer')
imsumall=squeeze(sum(imsummer,1));
[val,loc]=min(diff(imsumolindc1'));


function sumfromtop(imstack,chancontrol)

if(~exist('chancontrol','var'))
    chancontrol=1;
end

imsummer=sum(sum(imstack(:,:,chancontrol,:,:),5),4);

imsumall=squeeze(sum(imsummer,1));

[val,loc]=min(diff(imsumolindc1'));