%This function will take a series of images, choose a mask of constant size
%to use for the whole series, and compensate for translations (but not
%rotations) of the embryo.

function corrmasks=motioncorrect(masks)

%First, don't worry about the translations and just sum up the masks. Use
%regionprops to compute the area of each mask and the embryo centroid.
summedmask=zeros(size(masks(1).anteriornuc));
for i=1:length(masks)
    currpro=regionprops(bwlabel(masks(i).anteriornuc));
    embpro=regionprops(bwlabel(masks(i).embryo));
    summedmask=summedmask+masks(i).anteriornuc;
    areavec(i)=currpro.Area;
    centra(i,:)=embpro.Centroid;
end

%Then choose a mastermask by setting a cutoff to apply to the summedmask.
%The cutoff is chosen just high enough so the mastermask area does not
%exceed the mean area of the various masks.
notdone=1;
cutoff=1;
while(notdone)
    mastermask=summedmask>cutoff;
    if(sum(mastermask(:))<mean(areavec))
        notdone=0;
    else
        cutoff=cutoff+1;
    end
end
if((logical(summedmask)-mastermask)>(0.1*mean(areavec)))
    disp('Warning: Significant mask shifting. Perhaps AP selection problem');
end

%Use the mean centroid as the starting point for the translations.  Then
%output the translated mastermasks in corrmasks.
meancent=mean(centra,1);
corrmasks=zeros(length(masks),size(mastermask,1),size(mastermask,2));
for i=1:length(masks)
    corrmasks(i,:,:)=circshift(mastermask,[round(centra(i,2)-meancent(2)) round(centra(i,1)-meancent(1))]);
end