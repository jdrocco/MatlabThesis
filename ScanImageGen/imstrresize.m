function [newimage,newppm]=imstrresize(imagein,xdim,ydim)

xppm=size(imagein,1)/xdim;
yppm=size(imagein,2)/ydim;

if(yppm>xppm)
    newppm=yppm;
    h=elliptfspecial(.5,.5*yppm/xppm);
    newimage=imresize(imfilter(imagein,h),'Scale',[1 xppm/yppm],'Method','nearest');
else
    newppm=xppm;
    h=elliptfspecial(.5*xppm/yppm,.5);
    newimage=imresize(imfilter(imagein,h),'Scale',[yppm/xppm 1],'Method','nearest');
end