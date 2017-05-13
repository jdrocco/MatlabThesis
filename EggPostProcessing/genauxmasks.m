% This function will add nuclear, yolk, and vitelline masks to a mask
% structure which already contains an embryo mask.
% maskstruct=genauxmasks(maskstruct,vitdiv,nucdiv)

function maskstruct=genauxmasks(maskstruct,vitdiv,nucdiv)

BWemb=returnbiggest(maskstruct.embryo);
regpro=regionprops(logical(BWemb),'MinorAxisLength');

% HARD WIRING - don't want to catch the first couple points
if(~exist('vitdiv','var'))
    vitdiv=36;
end
if(~exist('nucdiv','var'))
    nucdiv=9;
end
vitellineerosions=round(regpro.MinorAxisLength/vitdiv);
nucerosions=round(regpro.MinorAxisLength/nucdiv);

% Now successively erode the image and save vitelline and nuclear regions
BWmod=BWemb;
se=strel('disk',vitellineerosions);
BWmod=imerode(BWmod,se);
vitelline=logical(BWemb-BWmod);

se=strel('disk',nucerosions-vitellineerosions);
BWmod=imerode(BWmod,se);
nuclear=logical(BWemb-BWmod-vitelline);
yolk=logical(BWmod);

maskstruct.nuclear=nuclear;
maskstruct.vitelline=vitelline;
maskstruct.yolk=yolk;
