% This function computes the gradient at a given depth using the skin
% location.
% Within crestmult tree

function gradout=crestgrad(stacker,skinloc,zsize,depth,zstep,axboxes)

for j=1:axboxes
    gradcalc(j)=0.0;
    todivisor(j)=0.0;
    if((skinloc(j)+depth-zsize)<zstep)
        for k=max(abs(round((skinloc(j)+depth+3*zsize)/zstep)),1):min(abs(round((skinloc(j)+depth-3*zsize)/zstep)),size(stacker,2))
            gradcalc(j)=gradcalc(j)+(stacker(j,k)*exp(-((k*zstep-skinloc(j))^2)/(2*(zsize^2))));
            todivisor(j)=todivisor(j)+exp(-((k*zstep-skinloc(j))^2)/(2*(zsize^2)));
        end
    else
        gradcalc(j)=NaN;
    end
end

gradout=gradcalc./todivisor;
