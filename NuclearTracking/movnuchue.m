
function movnuchue(moviename,imagestack,xtrace,ytrace,colorstep,offset)

map=colormap(jet);

colind=zeros(1,size(ytrace,1));
for m=1:size(ytrace,1)
    if(m==1)
        colind(m)=1;
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
    end
end

colmult=floor(64/max(colind));

if(~exist('offset'))
    offset=0;
end
aviobj = avifile(strcat(moviename,'.avi'),'fps',8);
figure;
for i=1:size(imagestack,1)
imlook=squeeze(imagestack(i,:,:));
h=imagesc(imlook); colormap(gray(256));hold on;
    %set(h,'EraseMode','xor');
    axis equal; axis tight;
    set(gca,'xtick',0);
    set(gca,'ytick',0);
    for m=1:size(ytrace,1)
    line(round([ytrace(m,i+offset) ytrace(m,i+offset)+3]),round([xtrace(m,i+offset) xtrace(m,i+offset)-4]),'color',squeeze(map(colmult*colind(m),:)),'LineWidth',2)
    end
    title(num2str(i+offset));
    pause(0.1);
    frame = getframe(gca);
    aviobj = addframe(aviobj,frame);
    hold off;
end
aviobj=close(aviobj);