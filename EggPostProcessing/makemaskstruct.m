% This function will compute masks for Dronpa lifetime experiment.
% [maskstruct2,transim,fluorim]=makemaskstruct(imstruct)

function [maskstruct2,transim,fluorim]=makemaskstruct(imstruct)

pretransseq=29;
postatransseq=33;
postctransseq=61;
prefseq=pretransseq-1;
postafseq=postatransseq-1;
postcfseq=postctransseq-1;

for i=1:length(imstruct)
    preinds=find(imstruct(i).Channel==pretransseq,imstruct(end).Groupsize,'first');
    postainds=find(imstruct(i).Channel==postatransseq,imstruct(end).Groupsize,'first');
    postcinds=find(imstruct(i).Channel==postctransseq,imstruct(end).Groupsize,'first');
    preindsf=find(imstruct(i).Channel==prefseq,imstruct(end).Groupsize,'first');
    postaindsf=find(imstruct(i).Channel==postafseq,imstruct(end).Groupsize,'first');
    postcindsf=find(imstruct(i).Channel==postcfseq,imstruct(end).Groupsize,'first');
    for j=1:length(preinds)
        transim(i,j,:,:)=uint16(mean(imstruct(i).Images([preinds(j) postainds(j) postcinds(j)],:,:),1));
        fluorim(i,j,:,:)=squeeze(imstruct(i).Images(postaindsf(j),:,:))-squeeze(imstruct(i).Images(preindsf(j),:,:));
        compim=double(squeeze(transim(i,j,:,:)));
        maskstruct(i,j,:,:)=makeembmask(compim);
    end
end

maskstruct=refinemaskstruct(maskstruct);

for i=1:size(maskstruct,1)
    for j=1:size(maskstruct,2)
        maskstruct2(i,j)=genauxmasks(maskstruct(i,j));        
    end
end

maskstruct=maskstruct2;
clear maskstruct2

% Now we will shamelessly call the side with higher fluorescence intensity the anterior. 
% We will override the location given for the spermtip from the elimsperm
% routine and pass that to findantwsperm
for i=1:size(maskstruct,1)
    % Use the images with good masks to do this.
    for j=1:size(maskstruct,2)
        goodvec(j)=maskstruct(i,j).goodmask;
    end
    if(~isempty(find(goodvec,1,'first')))
        firstgood=find(goodvec,1,'first');
        lastgood=find(goodvec,1,'last');
    else
        firstgood=1;
        lastgood=1;
    end
    nucuse=returnbiggest(maskstruct(i,ceil(mean([firstgood lastgood]))).nuclear);
    intenspro=regionprops(bwlabel(nucuse),squeeze(mean(fluorim(i,firstgood:lastgood,:,:),2)),'WeightedCentroid');
    for j=1:size(maskstruct,2)
        maskstruct(i,j).spermtip(1)=intenspro.WeightedCentroid(2); %Watch indices
        maskstruct(i,j).spermtip(2)=intenspro.WeightedCentroid(1);
        maskstruct2(i,j)=findantwsperm(maskstruct(i,j));
    end
end