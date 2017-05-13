% This function takes a mask. If it is not simply connected, it will return
% the biggest region.

function region=returnbiggest(regions)

labeledregs=bwlabel(regions);
regpro=regionprops(labeledregs,'Area');
maxareaval=0;
for r=1:length(regpro)
    if(regpro(r).Area>maxareaval)
        maxareaval=regpro(r).Area;
        bigreg=r;
    end
end
if(length(regpro)>0)
    region=(labeledregs==bigreg);
else
    region=logical(regions);
end
% regpro=regpro(bigreg);