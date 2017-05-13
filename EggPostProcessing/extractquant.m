function quantstruct=extractquant(imstruct,maskstruct)

%Note: if using with non-square images or pixels, verify that dimensions
%are not transposed.

if(~(length(imstruct)==size(maskstruct,1)))
    disp('Image and mask structure size mismatch')
end

apboxes=100;

for i=1:size(maskstruct,1)
    xmpp=10^6*(imstruct(i).Xdimreal/imstruct(i).Xpixels);
    ympp=10^6*(imstruct(i).Ydimreal/imstruct(i).Ypixels);
    se=strel('disk',ceil(size(imstruct(i).Images,2)/20));
    notembmask=~(imdilate(maskstruct(i,1).embryo,se));
    preinds=find(imstruct(i).Channel==0,imstruct(end).Groupsize,'first');
    postainds=find(imstruct(i).Channel==4,imstruct(end).Groupsize,'first');
    postcinds=find(imstruct(i).Channel==19,imstruct(end).Groupsize,'first');
    postaindst=find(imstruct(i).Channel==6,imstruct(end).Groupsize,'first');
    for j=1:length(postcinds)
        recoveredim=squeeze(double(imstruct(i).Images(postainds(j),:,:))-double(imstruct(i).Images(preinds(j),:,:)));
        convertedim=squeeze(double(imstruct(i).Images(postainds(j),:,:))-double(imstruct(i).Images(postcinds(j),:,:)));
%         recconcant(i,j)=mean(mean(recoveredim(squeeze(maskstruct(i,j).anteriornuc))));
        rectime(i,j)=mean([imstruct(i).GlobalTimeMin(postainds(j)) imstruct(i).GlobalTimeMin(preinds(j))]);
%         conconcant(i,j)=mean(mean(convertedim(squeeze(maskstruct(i,j).anteriornuc))));
        contime(i,j)=mean([imstruct(i).GlobalTimeMin(postainds(j)) imstruct(i).GlobalTimeMin(postcinds(j))]);
%         recconcpost(i,j)=mean(mean(recoveredim(logical(squeeze(maskstruct(i,j).nuclear-maskstruct(i,j).anteriornuc)))));
%         conconcpost(i,j)=mean(mean(convertedim(logical(squeeze(maskstruct(i,j).nuclear-maskstruct(i,j).anteriornuc)))));
        transint(i,j)=mean(mean(imstruct(i).Images(postaindst(j),notembmask)));
        goodmask(i,j)=maskstruct(i,j).goodmask;
        aplength(i,j)=sqrt(((maskstruct(i,j).AP_x(1)-maskstruct(i,j).AP_x(2))*xmpp)^2+((maskstruct(i,j).AP_y(1)-maskstruct(i,j).AP_y(2))*ympp)^2);
        [locquantrec(i,j,:),locconcrec(i,j,:,:),csrad(i,j,:,:)]=findlocquant(recoveredim,maskstruct(i,j).AntPosrat,apboxes,xmpp,ympp);
        [locquantcon(i,j,:),locconccon(i,j,:,:),csrad(i,j,:,:)]=findlocquant(convertedim,maskstruct(i,j).AntPosrat,apboxes,xmpp,ympp);
    end
end

quantstruct=struct('rectime',rectime,'contime',contime,'transint',transint,'goodmask',goodmask,'aplength',aplength,'locquantrec',locquantrec,'locquantcon',locquantcon,'locconcrec',locconcrec,'locconccon',locconccon,'csrad',csrad);