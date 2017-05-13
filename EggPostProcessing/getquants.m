function [sentmean,recmean,time]=getquants(imstruct,nucmaskfinal)


for i=1:length(imstruct)
    preinds=find(imstruct(i).Channel==0);
    poainds=find(imstruct(i).Channel==4);
    pocinds=find(imstruct(i).Channel==19);
    nucmask=squeeze(nucmaskfinal(i,:,:));
    
    for j=1:length(preinds)
        sentim=squeeze(imstruct(i).Images(poainds(j),:,:))-squeeze(imstruct(i).Images(pocinds(j),:,:));
        recim=squeeze(imstruct(i).Images(poainds(j),:,:))-squeeze(imstruct(i).Images(preinds(j),:,:));
        sentmean(i,j)=mean(mean(sentim(nucmask)));
        recmean(i,j)=mean(mean(recim(nucmask)));
        time(i,j)=imstruct(i).GlobalTimeMin(poainds(j))-imstruct(1).GlobalTimeMin(poainds(1));
    end
end
