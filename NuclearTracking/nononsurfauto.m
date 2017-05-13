% This is a preliminary version of a nuclear tracking program

function [xvel,yvel,xtrace,ytrace,imagestack,nucpos]=backwalksurfauto(imagestruct,startimnumber,nucpos,jumptonuc)
    

imagestackraw=imagestruct.imagestack;
for i=1:size(imagestackraw,1)
    imagestack(i,:,:)=imagestackraw((size(imagestackraw,1)+1)-i,:,:);
end
clear imagestackraw
offset=startimnumber-1;
totalims=size(imagestack,1)-startimnumber+1;

if(~exist('imagestruct.xpixels'))
    xpixels=size(imagestack,2);
    ypixels=size(imagestack,3);
    xdimreal=xpixels;
    ydimreal=ypixels;
    timeinmin=1:size(imagestack,1);
else
    xpixels=imagestruct.xpixels;
    ypixels=imagestruct.ypixels;
    xdimreal=imagestruct.xdimreal;
    ydimreal=imagestruct.ydimreal;
    timeinmin=imagestruct.timeinmin;
end

if(~exist('nucpos'))
choosenucfig=figure; 
imtodisp=squeeze(imagestack(startimnumber,:,:));
imagesc(imtodisp);
set(gcf,'Units','normalized')
figpos=get(gcf,'position');
set(gcf,'position',[0.16 0 .84 1])
datacursormode on;
cndataobj=datacursormode(choosenucfig);
notdonenuking=1;
nucinds=0;
while(notdonenuking>0)
    imagesc(imtodisp);
    nucinds=nucinds+1;
    notdonenuking=menu('More nucs?','No','Yes')-1;
    cnstruct=getCursorInfo(cndataobj);
    nucpos(nucinds,:)=cnstruct.Position;
    save npdump nucpos
    imtodisp((nucpos(nucinds,2)-2):(nucpos(nucinds,2)+2),(nucpos(nucinds,1)-2):(nucpos(nucinds,1)+2))=max(max(imtodisp));
end
close(choosenucfig);
else
    nucinds=size(nucpos,1);
end
orignucrad=4.5;
radius=round(1.8*orignucrad);      % half boxwidth of zoom window when tracking
multfactor=2;  %times we will interpolate the image, usually 2
newnucrad=orignucrad*2^multfactor;  %nuclear radius after interpolation
% gausskernel = fspecial('gaussian',[round(newnucrad) round(newnucrad)],round(newnucrad/4));
epsfac=0.125;
guessfrac=0.45;
figure;

estcenterxmat=nucpos(:,2);
estcenterymat=nucpos(:,1);
    xvel=zeros(nucinds,totalims-1);
    yvel=zeros(nucinds,totalims-1);
    xtrace=zeros(nucinds,totalims);
    ytrace=zeros(nucinds,totalims);
    
    if(exist('jumptonuc'))
        load(strcat('movdump',num2str(jumptonuc-1)));
    else
        jumptonuc=1;
    end
    
for k=jumptonuc:nucinds
    centerxstore=zeros(1,totalims);
    centerystore=zeros(1,totalims);
    centerxstorealt=centerxstore;
    centerystorealt=centerystore;
    estcenterx(startimnumber)=estcenterxmat(k);
    estcentery(startimnumber)=estcenterymat(k);
for i=startimnumber:(startimnumber+totalims-1)
    imusenow=double(squeeze(imagestack(i,(estcenterx(i)-radius):(estcenterx(i)+radius),(estcentery(i)-radius):(estcentery(i)+radius))));
    zi3 = interp2(imusenow,multfactor,'bicubic');
%     centerfindim=filter2(gausskernel,zi3);
%     imagesc(L); title(strcat(num2str(k),' : ',num2str(i))); pause(.1);
%     [valx,locxvec]=max(centerfindim);
%     [valy,locy]=max(valx);
%     locx=locxvec(locy);
%     locxorig=(locx+3)/4;
%     locyorig=(locy+3)/4;
%     centerxstore(i-startimnumber+1)=locxorig+estcenterx(i)-radius-1;
%     centerystore(i-startimnumber+1)=locyorig+estcentery(i)-radius-1;
%     [U,movpile(i,:)]=ch(zi3);
    epsilon=epsfac*newnucrad/(length(zi3)/2);
    U=ch(zi3,epsilon);
    topse=strel('disk',round(newnucrad*0.8));
    botse=strel('disk',round(newnucrad*0.5));
    Jedim = imsubtract(imadd(U,imtophat(U,topse)), imbothat(U,botse));
%     toppedim=imtophat(U,se);
    cutoffintens=0.5;
    nowdone=0;
    loopnum=0;
    while(~nowdone)
    loopnum=loopnum+1;
    binaryim=(im2bw(Jedim,min(Jedim(:))+cutoffintens*(max(Jedim(:))-min(Jedim(:)))));
    L=bwlabel(binaryim);
    imagesc(L); title(strcat(num2str(k),' : ',num2str(i))); pause(.1);
    centstruct=regionprops(L,Jedim,'WeightedCentroid','Centroid','Area','Solidity','MajorAxisLength');
    qualcounter=0;
    clear qualstruct;
    for r=1:length(centstruct)
        if((centstruct(r).Area>=(newnucrad^2/5)))
            qualcounter=qualcounter+1;
            qualstruct(qualcounter)=centstruct(r);
        end
    end
    if(qualcounter==0)
        cutoffintens=cutoffintens-0.04;
        continue;
    end
    clear distsq
    for q=1:length(qualstruct)
        distsq(q)=sum((qualstruct(q).WeightedCentroid-[ceil(size(binaryim,2)/2) ceil(size(binaryim,1)/2)]).^2);
    end
    [mindist,regtouse]=min(distsq);
    if((loopnum>7)&&(~(qualcounter==0)))
        break;
    end
    if((qualstruct(regtouse).Solidity<0.8)||(qualstruct(regtouse).MajorAxisLength>(2.7*newnucrad)))
        cutoffintens=cutoffintens+0.04;
        continue;
    else
        nowdone=1;
    end
    end
    centerxorig=(qualstruct(regtouse).WeightedCentroid(2)+(multfactor^2-1))/(multfactor^2);
    centeryorig=(qualstruct(regtouse).WeightedCentroid(1)+(multfactor^2-1))/(multfactor^2);
    centerxstorealt(i-startimnumber+1)=centerxorig+estcenterx(i)-radius-1;
    centerystorealt(i-startimnumber+1)=centeryorig+estcentery(i)-radius-1;
%     highreg=(imusenow>(1.1*mean(imusenow(:))));
%     L=bwlabel(highreg);
%     centstruct=regionprops(L,'Centroid');
%     centerxstore(i-startimnumber+1)=centstruct(1).Centroid(1)+estcenterx(i)-radius-1;
%     centerystore(i-startimnumber+1)=centstruct(1).Centroid(2)+estcentery(i)-radius-1;
%     estcenterx(i)=round(mean([centerxstore(i-startimnumber+1) centerxstorealt(i-startimnumber+1)]));
%     estcentery(i)=round(mean([centerystore(i-startimnumber+1) centerystorealt(i-startimnumber+1)]));
    if(i>(startimnumber+1))
        estcenterx(i+1)=round(centerxstorealt(i-startimnumber+1)+guessfrac*(centerxstorealt(i-startimnumber+1)-centerxstorealt(i-startimnumber)));
        estcentery(i+1)=round(centerystorealt(i-startimnumber+1)+guessfrac*(centerystorealt(i-startimnumber+1)-centerystorealt(i-startimnumber)));
    else
        estcenterx(i+1)=round(centerxstorealt(i-startimnumber+1));
        estcentery(i+1)=round(centerystorealt(i-startimnumber+1));
    end
    matchflag=0;
        for m=1:k-1
            if(((centerxstorealt(i-startimnumber+1)-xtrace(m,i-offset))^2+(centerystorealt(i-startimnumber+1)-ytrace(m,i-offset))^2)<((orignucrad^2)/2))
                for j=i:(startimnumber+totalims-1)
                    centerxstorealt(j)=xtrace(m,j-offset);
                    centerystorealt(j)=ytrace(m,j-offset);
                end
                matchflag=1;
                break;
            end
            if(matchflag==1)
                break;
            end
        end
        if(matchflag==1)     
            break;
        end
end

for m=1:totalims
    if(~(m==totalims))
        xvel(k,m)=(xdimreal/xpixels)*(centerxstorealt(m+1)-centerxstorealt(m))/60*(timeinmin(m+1)-timeinmin(m));
        yvel(k,m)=(ydimreal/ypixels)*(centerystorealt(m+1)-centerystorealt(m))/60*(timeinmin(m+1)-timeinmin(m));
    end
    xtrace(k,m)=centerxstorealt(m);
    ytrace(k,m)=centerystorealt(m);
end

save(strcat('movdump',num2str(k)),'xtrace','ytrace');

end