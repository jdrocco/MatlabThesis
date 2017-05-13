% This function displays the stack of images in z as well as the AP axis
% from end to end in the given plane.

function crestdisp(imchan1,avgdskinloc,zstep,AP_x,AP_y,pxsize,pysize,transdir,seqnumber,highintens,lowintens)

if(transdir==1);
    ptransize=pxsize;
else
    ptransize=pysize;
end

if(~exist('highintens'))
    maxim=squeeze(max(max(imchan1)));
    maximean=mean(double(maxim(:)));
    maxistd=std(double(maxim(:)));
    highintens=maximean+4*maxistd;
end

if(~exist('lowintens'))
    lowintens=maximean-2*maxistd;
end

if(~exist('seqnumber'))
    seqnumber=ceil(size(imchan1,1)/2);
end

if(~exist('stacksize'))
    stacksize=size(imchan1,2);
end

paraxes=size(avgdskinloc,1);
axboxes=size(avgdskinloc,2);
frontskincross=zeros(paraxes,axboxes);
backskincross=zeros(paraxes,axboxes);

for n=1:paraxes
    k=mod(n,3)+1;
    axlen=sqrt((AP_x(seqnumber,1)-AP_x(seqnumber,2))^2+(AP_y(seqnumber,1)-AP_y(seqnumber,2))^2);
    AP_xdisp(k,:)=AP_x(seqnumber,:)-(2*ptransize)*(k-2)*(AP_y(seqnumber,1)-AP_y(seqnumber,2))/axlen;
    AP_ydisp(k,:)=AP_y(seqnumber,:)+(2*ptransize)*(k-2)*(AP_x(seqnumber,1)-AP_x(seqnumber,2))/axlen;
end

for j=1:stacksize
    imfordisp=squeeze(imchan1(seqnumber,j,:,:));
    imfordisp(imfordisp>highintens)=highintens;
    imfordisp(1,1)=highintens;
    imfordisp(imfordisp<lowintens)=lowintens;
    imfordisp(end,end)=lowintens;
    for k=1:paraxes
        for l=1:axboxes    
            if((l>1)&&(avgdskinloc(k,l-1)>(zstep*j))&&(avgdskinloc(k,l)<(zstep*j))&&(~frontskincross(k,j)))
                frontskincross(k,j)=l-1+(avgdskinloc(k,l-1)-(zstep*j))/(avgdskinloc(k,l-1)-avgdskinloc(k,l));
            end
            lreverse=axboxes+1-l;
            if((lreverse>1)&&(avgdskinloc(k,lreverse)>(zstep*j))&&(avgdskinloc(k,lreverse-1)<(zstep*j))&&(~backskincross(k,j)))
                backskincross(k,j)=lreverse-1+(avgdskinloc(k,lreverse)-(zstep*j))/(avgdskinloc(k,lreverse)-avgdskinloc(k,lreverse-1));
            end
        end
    end
    frontxpoint=(AP_xdisp(:,2)-AP_xdisp(:,1)).*(frontskincross(:,j)/axboxes)+AP_xdisp(:,1);
    frontypoint=(AP_ydisp(:,2)-AP_ydisp(:,1)).*(frontskincross(:,j)/axboxes)+AP_ydisp(:,1);
    backxpoint=(AP_xdisp(:,2)-AP_xdisp(:,1)).*(backskincross(:,j)/axboxes)+AP_xdisp(:,1);
    backypoint=(AP_ydisp(:,2)-AP_ydisp(:,1)).*(backskincross(:,j)/axboxes)+AP_ydisp(:,1);
    imagesc(imfordisp);
    for k=1:paraxes
    line([frontypoint(k) backypoint(k)],[frontxpoint(k) backxpoint(k)],'color',[1 0 0]);
    end
    axis equal;
    axis tight;
    colorbar;
    pause(1);
end

imfordisp=sum(sum(imchan1,2),1);
imagesc(squeeze(imfordisp));
colorbar;
