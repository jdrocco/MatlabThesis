function imstruct=imstructcrop(imstruct,approxregpro,movegrace)

bblow=floor(approxregpro.BoundingBox(1:2))-movegrace;
bbhigh=bblow+floor(approxregpro.BoundingBox(3:4))+movegrace*2+1;
bblow(bblow<1)=1;
bbhigh(bbhigh>imstruct.Xpixels)=imstruct.Xpixels;

imstruct.Images=imstruct.Images(:,bblow(2):bbhigh(2),bblow(1):bbhigh(1));
imstruct.Xpixels=bbhigh(2)-bblow(2)+1;
imstruct.Ypixels=bbhigh(1)-bblow(1)+1;
