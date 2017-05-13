% This function allows for manual AP axis selection with confirmation.
% Within crestmult tree

function [AP_y,AP_x]=getapaxisj(image)

image(image>(100*mean(image(:))))=100*mean(image(:));
APselfig=figure;
k=2;
while k==2
    clf
	imagesc(squeeze(image));axis equal;axis tight
	set(gcf,'Units','normalized')
	figpos=get(gcf,'position');
	set(gcf,'position',[0 0 1 1])
	[AP_y,AP_x]=ginput(2);
	clf   
	imagesc(squeeze(image));axis equal;axis tight
    line(AP_y,AP_x)
    k=menu('Accept axis?','Yes','No');
end
close(APselfig);
