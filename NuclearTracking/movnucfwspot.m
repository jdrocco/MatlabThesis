
function movnucfwhue(moviename,imagestack,xtrace,ytrace,colorstep,offset)

jefforder = [

         0         0    1.0000
    1.0000         0         0
    1.0000    1.0000         0
         0    1.0000         0
    1.0000    0.1000    0.6000
         0    0.7500    1.0000
    0.7500         0    0.7500
    1.0000    0.5000         0
         0    0.5300    0.0800
         ];
     
colind=zeros(1,size(ytrace,1));
for m=1:size(ytrace,1)
    if(m==1)
        colind(m)=1;
        stepuser(colind(m))=1;
        continue;
    end
    colfound=0;
    for n=1:(m-1)
        if((xtrace(m,colorstep)==xtrace(n,colorstep))&&(ytrace(m,colorstep)==ytrace(n,colorstep)))
            colind(m)=colind(n);
            colfound=1;
            break;
        end
    end
    if(colfound==0)
        colind(m)=max(colind)+1;
        stepuser(colind(m))=m;
    end
end

xuse=squeeze(xtrace(stepuser,colorstep));
yuse=squeeze(ytrace(stepuser,colorstep));
[verily,chilly]=voronoin([xuse yuse]);

for i=1:length(stepuser)
    for j=1:length(stepuser)
        googi(i,j)=~isempty(intersect(setdiff(chilly{i},1),setdiff(chilly{j},1)));
    end
end
[vals,locs]=sort(sum(googi),'descend');

tryagain=1;
while((tryagain>0)&&(tryagain<10))
    colmatch=zeros(length(stepuser),1);
for k=locs
    posscolors=randperm(size(jefforder,1));
    for l=find(googi(k,:))
        posscolors=setdiff(posscolors,colmatch(l));
    end
    if(~isempty(posscolors))
        clear fillerup;
        for r=1:length(posscolors)
            posse=posscolors(r);
            fillerup(r)=sum(colmatch==posse);
        end
        [valley,locanda]=min(fillerup);
        colmatch(k)=posscolors(locanda);
    else
        tryagain=tryagain+1;
        break;
    end
end
if(min(colmatch))
    tryagain=0;
end
end

if(~exist('offset'))
    offset=0;
end
aviobj = avifile(strcat(moviename,'.avi'),'fps',8);
figure;
for i=size(xtrace,2):-1:1
imlook=squeeze(imagestack(i+offset,:,:));
h=imagesc(imlook); colormap(gray(256));hold on;
    %set(h,'EraseMode','xor');
    axis equal; axis tight;
    set(gca,'xtick',0);
    set(gca,'ytick',0);
    for m=1:size(ytrace,1)
    plot(ytrace(m,i),xtrace(m,i),'.','color',squeeze(jefforder(colmatch(colind(m)),:)),'LineWidth',2)
    end
    title(num2str(i+offset));
    pause(0.1);
    frame = getframe(gca);
    aviobj = addframe(aviobj,frame);
    hold off;
end
aviobj=close(aviobj);