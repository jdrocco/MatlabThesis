% This function will accept an embryo image and return the embryo mask
% maskstruct=makeembmask(im)

function maskstruct=makeembmask(im,transim,uvim)

powdiv=2.5;
uvpow=12000;
sesize=3;

donenow=0;
sigcutoff=0.16;
sizecutoff=0.42;

while(~donenow)
%First use the detectreg program to detect regions
regions=detectreg(im,sigcutoff);

%Then figure out which is the largest--assume this is the embryo.
bigreg=returnbiggest(regions);

if(sum(logical(bigreg(:)))<(sizecutoff*size(bigreg,1)*size(bigreg,2)))
    sigcutoff=sigcutoff-0.02;
    if(sigcutoff<0.07)
        maskstruct=[];
        return
    end
else
    donenow=1;
end
end

se=strel('disk',5*sesize);
roughpow=mean(transim(imdilate(~bigreg,se)));
se=strel('disk',sesize);
transyolk=imfill(imopen(returnbiggest(transim<(roughpow/powdiv)),se),'holes');
transyolk=returnbiggest(transyolk);

fixedbigreg=elimsperm(bigreg);

cleaneruv=bwmorph(uvim>uvpow,'majority');
finaluv=imfill(cleaneruv&fixedbigreg,'holes');

maskstruct=struct('embnovit',fixedbigreg,'transyolk',transyolk,'uvexclude',finaluv);