%This function will take a series of images, choose a mask of constant size
%to use for the whole series, and compensate for translations (but not
%rotations) of the embryo.

function masks=olidmocorr(masks)

%First, don't worry about the translations and just sum up the masks. Use
%regionprops to compute the area of each mask and the embryo centroid.
summedmask=zeros(size(masks(1).uncorrmask));
for i=1:length(masks)
    embpro=regionprops(returnbiggest(masks(i).uncorrmask));
    summedmask=summedmask+masks(i).uncorrmask;
    areavec(i)=embpro.Area;
    centra(i,:)=embpro.Centroid;
end

%Then choose a mastermask by setting a cutoff to apply to the summedmask.
%The cutoff is chosen just high enough so the mastermask area does not
%exceed the mean area of the various masks.

cutoff=2;
    mastermask=summedmask>cutoff;

%Use the mean centroid as the starting point for the translations.  Then
%output the translated mastermasks in corrmasks.
mastermask=returnbiggest(mastermask);
meancent=mean(centra,1);

maxvarier=max(abs(areavec-mean(areavec))/mean(areavec));
if(maxvarier<.002)
    for i=1:length(masks)
        masks(i).corrmask=circshift(mastermask,[round(centra(i,2)-meancent(2)) round(centra(i,1)-meancent(1))]);
        masks(i).corrshift=[round(centra(i,2)-meancent(2)) round(centra(i,1)-meancent(1))];
    end
else
    for i=1:length(masks)
        masks(i).corrmask=mastermask;
        masks(i).corrshift=[0 0];
    end
end
    