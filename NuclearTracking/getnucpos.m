function nucpos=getnucpos(imagestack)

choosenucfig=figure; 
imtodisp=squeeze(imagestack(1,:,:));
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