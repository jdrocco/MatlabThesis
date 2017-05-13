% This function finds the skin location from an image stack
% incorporating user input in the meantime.
% Within crestmult tree

function skinloc=crestskin(timesinseries,imagesc1,pxsize,pysize,axboxes,AP_x,AP_y,uncreated,zstep)

fineness=500;
strictness=1.2;
neartopdist=15;
fractrigincrease=0.75;

selfigidx=figure;
hold on; map=colormap;

for i=1:timesinseries
pAP_x=int16(AP_x(i,:));
pAP_y=int16(AP_y(i,:));

origselector=zeros(size(imagesc1,3),size(imagesc1,4));
origselector((round(mean(pAP_x))-abs(pxsize)):(round(mean(pAP_x))+abs(pxsize)),((round(mean(pAP_y))-pysize):(round(mean(pAP_y))+pysize)))=1;

for j=1:axboxes
    selector=circshift(origselector,[round((AP_x(i,2)-AP_x(i,1))*(j-((1+axboxes)/2))/axboxes) round((AP_y(i,2)-AP_y(i,1))*(j-((1+axboxes)/2))/axboxes)]);
    selector=selector.*squeeze(uncreated(i,:,:));
    stacker(i,j,:)=mean(imagesc1(i,:,logical(selector)),3);
end

derimesh=linspace(zstep,zstep*size(stacker,3),fineness);
for j=1:axboxes
    smoothedfit=fit((zstep*(1:size(stacker,3)))',(squeeze(mean(stacker(i,max((j-2),1):min((j+2),size(stacker,2)),:),2))),'cubicspline');
    deriv=differentiate(smoothedfit,derimesh);
    zeroidx(i,j)=0;
    for k=1:(fineness-1)
        if((deriv(k)<0.0)&&(deriv(k+1)>0.0))
            zeroidx(i,j)=zeroidx(i,j)+1;
            zeroloc(i,j,zeroidx(i,j))=(((deriv(k+1)/(deriv(k+1)-deriv(k)))+k)/fineness)*zstep*(size(stacker,3)-1)+zstep;
            zerosig(i,j,zeroidx(i,j))=smoothedfit(zeroloc(i,j,zeroidx(i,j)));
        end
    end  
    for m=1:zeroidx(i,j)
        plot(zeroloc(i,j,m),smoothedfit(zeroloc(i,j,m)),'*','color',squeeze(map(ceil(j*64/axboxes),:)));
    end
end
end

if(~exist('triggerheight'))
    readfmplot=ginput(1);
    highskinreal=readfmplot(1);
    triggerheight=readfmplot(2);
end

doneflag=0;
while(~doneflag)
closequadmat=(zeroloc>highskinreal)&(zerosig>triggerheight)&(zeroloc<(highskinreal+neartopdist));
for n=1:timesinseries
    neartopsig(n)=mean(zerosig(n,squeeze(closequadmat(n,:,:))));
end
neartopsig(isnan(neartopsig))=nanmin(neartopsig);
addtoot=fractrigincrease*(neartopsig-min(neartopsig));

showfigidx=figure;

figure(showfigidx);clf; hold on;
for i=1:timesinseries
    usetrigh=triggerheight+addtoot(i);
for j=1:axboxes
    foundskin=0;
    for m=1:zeroidx(i,j)
        reversem=zeroidx(i,j)-m+1;
        if((zeroloc(i,j,reversem)>highskinreal)&&(zerosig(i,j,reversem)>usetrigh))
            skinloc(i,j)=zeroloc(i,j,reversem);
            skinsig(i,j)=zerosig(i,j,reversem);
            foundskin=1;
            break;
        end
    end
    if(foundskin==0)
        skinloc(i,j)=zstep;
        skinsig(i,j)=0;
    end
end
        
for j=1:axboxes
    plot(j,skinloc(i,j),'*','color',squeeze(map(ceil(i*64/timesinseries),:)));
end
end
k=menu('Accept skin location?','Yes','No','Eliminate outliers');
if k==1
   doneflag=1;
else
   doneflag=0;
   if k==2
        figure(selfigidx);
        readfmplot=ginput(1);
        highskinreal=readfmplot(1);
        triggerheight=readfmplot(2);
   else
        figure(showfigidx);clf; hold on;
        for j=1:axboxes
            skinhere=skinloc(:,j);
            skinaround=skinloc(:,max(j-2,1):min(j+2,size(skinloc,2)));
            skinoutliers=(skinhere>(mean(skinaround(:))+strictness*std(skinaround(:))))|(skinhere<(mean(skinaround(:))-strictness*std(skinaround(:))));
            skinhere(skinoutliers)=mean(skinhere(~skinoutliers));
            skinloc(:,j)=skinhere;
            for i=1:timesinseries
                plot(j,skinloc(i,j),'*','color',squeeze(map(ceil(i*64/timesinseries),:)));
            end
        end
        q=menu('Better','Yes','No');
        if(q==1)
            doneflag=1;
        else
            prompt={'Choose a strictness (sigma):'};
            name='Fixer upper';
            strictstring=num2str(strictness);
            defaultans={strictstring};
            response=inputdlg(prompt,name,1,defaultans);
            newstrictcell=response(1);
            strictness=str2double(newstrictcell);
            figure(selfigidx);
            readfmplot=ginput(1);
            highskinreal=readfmplot(1);
            triggerheight=readfmplot(2);
        end
   end
end
end
close(selfigidx);
close(showfigidx);
