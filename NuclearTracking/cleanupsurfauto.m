function [xvel,yvel,xtrace,ytrace]=cleanupsurfauto(imagestruct,imbackcrop,xtrace,ytrace)

if(~exist('imagestruct.xpixels'))
    xpixels=size(imbackcrop,2);
    ypixels=size(imbackcrop,3);
    xdimreal=xpixels;
    ydimreal=ypixels;
    timeinmin=1:size(imbackcrop,1);
else
    xpixels=imagestruct.xpixels;
    ypixels=imagestruct.ypixels;
    xdimreal=imagestruct.xdimreal;
    ydimreal=imagestruct.ydimreal;
    timeinmin=imagestruct.timeinmin;
end

for i=1:(size(xtrace,2)-1)
    xvel(:,i)=xtrace(:,i+1)-xtrace(:,i);
    yvel(:,i)=ytrace(:,i+1)-ytrace(:,i);
    for j=1:size(xtrace,1)
        absvel(j,i)=sqrt(xvel(j,i)^2+yvel(j,i)^2);
        veldir(j,i)=atan(yvel(j,i)/xvel(j,i));
    end
    velthreesig(i)=3*nanstd(absvel(:,i));
end
meanxvelsmoothed=smooth(mean(xvel,1),5);
meanyvelsmoothed=smooth(mean(yvel,1),5);

orignucrad=6.5;    %3.5 for spot099, 6.5 for spot013
radius=round(1.8*orignucrad);      % half boxwidth of zoom window when tracking
multfactor=2;  %times we will interpolate the image, usually 2
newnucrad=orignucrad*2^multfactor;  %nuclear radius after interpolation
% gausskernel = fspecial('gaussian',[round(newnucrad) round(newnucrad)],round(newnucrad/4));
epsfac=0.125;
guessfrac=1;
figure;

for k=1:size(xtrace,1)
    centerxstorealt=xtrace(k,:);
    centerystorealt=ytrace(k,:);
    hitsvec=(absvel(k,:)>(smooth(nanmean(absvel,1)+velthreesig,5)'))|(absvel(k,:)<(smooth(nanmean(absvel,1)-velthreesig,5)'));
    firstdev=find(hitsvec,1,'first');
    startimnumber=firstdev;
    totalims=size(imbackcrop,1);
    clear estcenterx estcentery
    estcenterx(startimnumber)=round(xtrace(k,startimnumber));
    estcentery(startimnumber)=round(ytrace(k,startimnumber));
for i=startimnumber:totalims
    imusenow=double(squeeze(imbackcrop(i,(estcenterx(i)-radius):(estcenterx(i)+radius),(estcentery(i)-radius):(estcentery(i)+radius))));
    zi3 = interp2(imusenow,multfactor,'bicubic');
    epsilon=epsfac*newnucrad/(length(zi3)/2);
    U=ch(zi3,epsilon);
    topse=strel('disk',round(newnucrad*0.8));
    botse=strel('disk',round(newnucrad*0.5));
    Jedim = imsubtract(imadd(U,imtophat(U,topse)), imbothat(U,botse));
    cutoffintens=0.4;
    nowdone=0;
    loopnum=0;
    while(~nowdone)
    loopnum=loopnum+1;
    binaryim=(im2bw(Jedim,min(Jedim(:))+cutoffintens*(max(Jedim(:))-min(Jedim(:)))));
    L=bwlabel(binaryim);
    imagesc(L); title(strcat(num2str(k),' : ',num2str(i))); pause(.1);
    centstruct=regionprops(L,'Centroid','Area','Solidity','MajorAxisLength');
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
        distsq(q)=sum((qualstruct(q).Centroid-[ceil(size(binaryim,2)/2) ceil(size(binaryim,1)/2)]).^2);
    end
    [mindist,regtouse]=min(distsq);
    if((loopnum>8)&&(~(qualcounter==0)))
        break;
    end
    if((qualstruct(regtouse).MajorAxisLength>(2.7*newnucrad)))
        cutoffintens=cutoffintens+0.04;
        continue;
    else
        nowdone=1;
    end
    end
    centerxorig=(qualstruct(regtouse).Centroid(2)+(multfactor^2-1))/(multfactor^2);
    centeryorig=(qualstruct(regtouse).Centroid(1)+(multfactor^2-1))/(multfactor^2);
    centerxstorealt(i)=centerxorig+estcenterx(i)-radius-1;
    centerystorealt(i)=centeryorig+estcentery(i)-radius-1;
    if(i<(totalims))
        estcenterx(i+1)=round((centerxstorealt(i))+guessfrac*meanxvelsmoothed(i));
        estcentery(i+1)=round((centerystorealt(i))+guessfrac*meanyvelsmoothed(i));
    else
        estcenterx(i+1)=round(centerxstorealt(i));
        estcentery(i+1)=round(centerystorealt(i));
    end
    matchflag=0;
        for m=1:k-1
            if(((centerxstorealt(i)-xtrace(m,i))^2+(centerystorealt(i)-ytrace(m,i))^2)<((orignucrad^2)/2))
                for j=i:totalims
                    centerxstorealt(j)=xtrace(m,j);
                    centerystorealt(j)=ytrace(m,j);
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
    xtrace(k,m)=centerxstorealt(m);
    ytrace(k,m)=centerystorealt(m);
end

save(strcat('cleandump',num2str(k)),'xtrace','ytrace','xvel','yvel');

end
