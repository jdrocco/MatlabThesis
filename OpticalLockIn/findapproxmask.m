function [approxmask,approxregpro]=findapproxmask(transims,approxcoeff)

approxinit=squeeze(mean(transims,1))<approxcoeff*mean(transims(:));
approxfill=imfill(approxinit,'holes');
approxmask=returnbiggest(approxfill);
approxregpro=regionprops(approxmask);