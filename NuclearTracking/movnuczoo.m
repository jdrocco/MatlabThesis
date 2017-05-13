
function movnuczoo(moviename,imagestack,xtrace,ytrace,offset)

if(~exist('offset'))
    offset=0;
end
aviobj = avifile(strcat(moviename,'.avi'),'fps',10);
figure;
for i=1:size(imagestack,1)
imlook=squeeze(imagestack(i,:,:));
h=imagesc(imlook); hold on;
    %set(h,'EraseMode','xor');
    axis equal; axis tight;
    set(gca,'xtick',0);
    set(gca,'ytick',0);
    for m=1:size(ytrace,1)
    line(round([ytrace(m,i+offset) ytrace(m,i+offset)+3]),round([xtrace(m,i+offset) xtrace(m,i+offset)-4]),'color',[0 0 0],'LineWidth',2)
    end
    title(num2str(i+offset));
    pause(0.1);
    frame = getframe(gca);
    aviobj = addframe(aviobj,frame);
    hold off;
end
aviobj=close(aviobj);