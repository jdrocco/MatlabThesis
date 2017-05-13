function movmaker(imagestack,moviename,imin,imax)

if(~exist('moviename'))
    moviename='mymovie';
end

aviobj = avifile(strcat(moviename,'.avi'),'fps',8);
figure;
for i=1:size(imagestack,1)
    imlook=squeeze(imagestack(i,:,:));
    h=imagesc(imlook,[imin imax]); 
    colormap copper; 
    hold on;
    %set(h,'EraseMode','xor');
    axis equal; axis tight;
    set(gca,'xtick',0);
    set(gca,'ytick',0);
    title(num2str(i));
    pause(0.1);
    frame = getframe(gca);
    aviobj = addframe(aviobj,frame);
    hold off;
end
aviobj=close(aviobj);