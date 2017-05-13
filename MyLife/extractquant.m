function quantstruct=extractquant(imstruct,maskstruct)

%Note: if using with non-square images or pixels, verify that dimensions
%are not transposed.

apboxes=200;

locquant=zeros(size(imstruct.Timeindex,1),apboxes);
locconc=zeros(size(imstruct.Timeindex,1),apboxes,2);
nucrad=zeros(size(imstruct.Timeindex,1),apboxes);
    xmpp=10^6*(imstruct.Xdimreal/imstruct.Xpixels);
    ympp=10^6*(imstruct.Ydimreal/imstruct.Ypixels);
for i=1:size(maskstruct,2)
    goodmask=maskstruct(i).goodmask;
    aplength=sqrt(((maskstruct(i).AP_x(1)-maskstruct(i).AP_x(2))*xmpp)^2+((maskstruct(i).AP_y(1)-maskstruct(i).AP_y(2))*ympp)^2);
    stage=maskstruct(i).stage;
    localtime=imstruct.LocalTimeSec(:,i);
    transpower=maskstruct(i).transpower;
    transpowvec=maskstruct(i).transpowvec;
    for j=1:size(imstruct.Timeindex,1)
        imind=((i-1)*size(imstruct.Timeindex,1))+j;
        [locquant(j,:),locconc(j,:,:),nucrad(j,:)]=findlocquant(squeeze(imstruct.Images(imind,:,:)),maskstruct(i).AntPosrat,apboxes,xmpp,ympp);
    end
    if(i==1)
        quantstruct(i)=struct('locquant',locquant,'locconc',locconc,'nucrad',nucrad,'localtime',localtime,'goodmask',goodmask,'aplength',aplength,'stage',stage,'transpower',transpower,'transpowvec',transpowvec);
    else
        quantstruct(i).locquant=locquant;
        quantstruct(i).locconc=locconc;
        quantstruct(i).nucrad=nucrad;
        quantstruct(i).localtime=localtime;
        quantstruct(i).goodmask=goodmask;
        quantstruct(i).aplength=aplength;
        quantstruct(i).stage=stage;
        quantstruct(i).transpower=transpower;
        quantstruct(i).transpowvec=transpowvec;
    end
%     if(max(maskstruct(i).premaskexc(:)))
%         apratnow=maskstruct(i).AntPosrat;
%         apratnow(maskstruct(i).premaskexc)=0;
%             for j=1:size(imstruct.Timeindex,1)
%                 imind=((i-1)*size(imstruct.Timeindex,1))+j;
%                 [locquant(j,:),locconc(j,:,:),nucrad(j,:)]=findlocquant(squeeze(imstruct.Images(imind,:,:)),apratnow,apboxes,xmpp,ympp);
%             end
%         quantstruct(i).prelocquant=locquant;
%         quantstruct(i).prelocconc=locconc;
%         quantstruct(i).prenucrad=nucrad;
%     end
%     if(max(maskstruct(i).postmaskexc(:)))
%         apratnow=maskstruct(i).AntPosrat;
%         apratnow(maskstruct(i).postmaskexc)=0;
%             for j=1:size(imstruct.Timeindex,1)
%                 imind=((i-1)*size(imstruct.Timeindex,1))+j;
%                 [locquant(j,:),locconc(j,:,:),nucrad(j,:)]=findlocquant(squeeze(imstruct.Images(imind,:,:)),apratnow,apboxes,xmpp,ympp);
%             end
%         quantstruct(i).postlocquant=locquant;
%         quantstruct(i).postlocconc=locconc;
%         quantstruct(i).postnucrad=nucrad;
%     end
end