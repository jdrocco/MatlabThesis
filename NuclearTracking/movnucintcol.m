
function movnucfwhue(moviename,imagestack,xtrace,ytrace,colorstep,offset)

map=colormap(jet(64));

colind=zeros(1,size(ytrace,1));
for m=1:size(ytrace,1)
    if(m==1)
        colind(m)=1;
        continue;
    end
    colfound=0;
    for n=1:(m-1)
        if((abs(xtrace(m,colorstep)-xtrace(n,colorstep))<0.2)&&(abs(ytrace(m,colorstep)-ytrace(n,colorstep))<0.2))
            colind(m)=colind(n);
            colfound=1;
            break;
        end
    end
    if(colfound==0)
        colind(m)=max(colind)+1;
    end
end

% colmult=floor(64/max(colind));
colmult=9;

xfine=4*xtrace-3;
yfine=4*ytrace-3;

if(~exist('offset'))
    offset=0;
end
aviobj = avifile(strcat(moviename,'.avi'),'fps',8);
figure;
for i=1:size(imagestack,1)
imlook=squeeze(imagestack(i,:,:));
imfine=interp2(imlook,2,'cubic');
h=imagesc(imfine); colormap(gray(256));hold on;
    %set(h,'EraseMode','xor');
    axis equal; axis tight;
    set(gca,'xtick',0);
    set(gca,'ytick',0);
    for m=1:size(ytrace,1)
    line(round([yfine(m,i+offset) yfine(m,i+offset)+5]),round([xfine(m,i+offset) xfine(m,i+offset)-6]),'color',squeeze(map((colmult*mod(colind(m),(round(63/colmult)+1)))+1,:)),'LineWidth',2)
    end
    title(num2str(i+offset));
    pause(0.1);
    frame = getframe(gca);
    aviobj = addframe(aviobj,frame);
    hold off;
end
aviobj=close(aviobj);