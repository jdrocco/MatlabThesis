function [usefulgrad,firstnotnan,lastnotnan]=fixgrad(badgrad)

% This just finds where the gradient cannot be measured at the edges (is
% Nan) and bleeds the neighboring intensity out appropriately (taking the
% mean).

bleedbox=5;
firstnotnan=0;
lastnotnan=0;
gradboxes=size(badgrad,2);
for i=1:gradboxes
    if((~firstnotnan)&&(~isnan(badgrad(i))))
        firstnotnan=max(i,round(gradboxes/12));
    end
    if((~lastnotnan)&&(firstnotnan)&&(isnan(badgrad(i))))
        lastnotnan=min(i-1,round(gradboxes*11/12));
    end
end
if(~lastnotnan)
    lastnotnan=round(gradboxes*11/12);
end
usefulgrad=badgrad;
usefulgrad(1:firstnotnan)=mean(badgrad(firstnotnan:(firstnotnan+bleedbox)));
if(lastnotnan)
    usefulgrad(lastnotnan:end)=mean(badgrad((lastnotnan-bleedbox):lastnotnan));
end