function [imstruct,newmaskstruct]=imstrrotcrop(imstruct,detmasks)
% 
% embpro=regionprops(detmasks(1).corrmask,'Orientation');
% emborient=embpro.Orientation;
% for i=1:length(detmasks)
%     detmasks(i).uncorrmask=logical(imrotate(detmasks(i).uncorrmask,-emborient,'nearest'));
%     detmasks(i).corrmask=returnbiggest(logical(imrotate(detmasks(i).corrmask,-emborient,'nearest')));
% end
ipers=size(imstruct.Images,1)/length(detmasks);
for j=1:size(imstruct.Images,1)
    inow=1+floor((j-1)/ipers);
	rotimnow=imrotate(squeeze(imstruct.Images(j,:,:)),-detmasks(inow).emborient,'bilinear');
    regprosery=regionprops(detmasks(inow).corrmask,'SubarrayIdx');
    rotims(j,:,:)=rotimnow(regprosery.SubarrayIdx{1},regprosery.SubarrayIdx{2});
    newmaskstruct(inow).embryo=detmasks(inow).corrmask(regprosery.SubarrayIdx{1},regprosery.SubarrayIdx{2});
end

imstruct.Images=rotims;
xpixnew=size(rotims,2);
imstruct.Xdimreal=imstruct.Xdimreal*xpixnew/imstruct.Xpixels;
imstruct.Xpixels=xpixnew;
ypixnew=size(rotims,3);
imstruct.Ydimreal=imstruct.Ydimreal*ypixnew/imstruct.Ypixels;
imstruct.Ypixels=ypixnew;
