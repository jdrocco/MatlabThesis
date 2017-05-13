function [orientout,lengthout]=findorientation(depther)

oruserfrac=0.6;
lnuserfrac=0.1;

for i=1:ceil(max(depther(:))*oruserfrac)
    regpro=regionprops(logical(depther>(i-1)),'Orientation','MajorAxisLength');
    orstore(i)=regpro.Orientation;
    if(i<=round(max(depther(:))*lnuserfrac)&&(i>1))
        lnstore(i-1)=regpro.MajorAxisLength;
    end
end

orientout=mean(orstore);
lengthout=mean(lnstore);