    
function maskstruct=addrotang(maskstruct)

for i=1:length(maskstruct)
    rotang(i)=(180/pi)*atan((maskstruct(i).AP_x(2)-maskstruct(i).AP_x(1))/(maskstruct(i).AP_y(2)-maskstruct(i).AP_y(1)));
    maskstruct(i).rotang=rotang(i);
end