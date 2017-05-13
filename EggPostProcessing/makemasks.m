% This function will accept an embryo image and return four masks
% masks=makemasks(im,vitdiv,nucdiv)  vitdiv and nucdiv specify the number
% by which to dive the embryo minor axis when eroding for the vitelline and
% nuclear layers, respectively

function masks=makemasks(im,vitdiv,nucdiv,viterode,nucerode)

%First use the detectreg program to detect regions
regions=detectreg(im);

%Then figure out which is the largest--assume this is the embryo.
[fixedBWemb,spermtip]=elimsperm(regions);
BWemb=returnbiggest(fixedBWemb);
regpro=regionprops(logical(BWemb),'MinorAxisLength');
BWemb=fillwbord(BWemb); % This step assumes the embryo is convex.  Added with qotn10 for embryo which are not entirely in the field of view.
[AP_x,AP_y]=findAPaxis(BWemb);

%Try to guess from the location of the micropili which is the anterior
if(~isnan(spermtip))
    distsq1=(spermtip(1)-AP_x(1))^2+(spermtip(2)-AP_y(1))^2;
    distsq2=(spermtip(1)-AP_x(2))^2+(spermtip(2)-AP_y(2))^2;
    if(distsq1<distsq2)
        forwardside=1;
    else
        forwardside=2;
    end
else
    forwardside=ceil(2*rand);
end
    
% HARD WIRING - don't want to catch the first couple points
if(~exist('vitdiv','var'))
    vitdiv=36;
end
if(~exist('nucdiv','var'))
    nucdiv=9;
end
vitellineerosions=round(regpro.MinorAxisLength/vitdiv);
nucerosions=round(regpro.MinorAxisLength/nucdiv);

if(exist('viterode','var'))
    vitellineerosions=viterode;
end
if(exist('nucerode','var'))
    nucerosions=nucerode;
end

% Now successively erode the image and save vitelline and nuclear regions
BWmod=BWemb;
se=strel('disk',vitellineerosions);
BWmod=imerode(BWmod,se);
vitelline=logical(BWemb-BWmod);

se=strel('disk',nucerosions-vitellineerosions);
BWmod=imerode(BWmod,se);
nuclear=logical(BWemb-BWmod-vitelline);
yolk=logical(BWmod);

%Swap the AP axis points if they are oriented in the wrong
%direction
if(forwardside==2)
    APfixedx(1)=AP_x(2);
    APfixedx(2)=AP_x(1);
    APfixedy(1)=AP_y(2);
    APfixedy(2)=AP_y(1);
else
    APfixedx(1)=AP_x(1);
    APfixedx(2)=AP_x(2);
    APfixedy(1)=AP_y(1);
    APfixedy(2)=AP_y(2);
end

%If a mask pixel is closer to the anterior tip, then put it in that mask
[nucx,nucy]=find(nuclear);
for k=1:length(nucx)
    distsq1=(nucx(k)-APfixedx(1))^2+(nucy(k)-APfixedy(1))^2;
    distsq2=(nucx(k)-APfixedx(2))^2+(nucy(k)-APfixedy(2))^2;
    antposrat(k)=sqrt(distsq1)/(sqrt(distsq1)+sqrt(distsq2));
end
forwardnuc=zeros(size(nuclear));
apratmask=zeros(size(nuclear));
indices=find(nuclear);
apratmask(indices)=antposrat;

%Finally make an anterior nuclei mask.  Use the cutoff ratio of 0.5.
cutoffaprat=0.5;
forwardnuc=apratmask<cutoffaprat&nuclear;
forwardnuc=logical(forwardnuc);

masks=struct('embryo',BWemb,'nuclear',nuclear,'vitelline',vitelline,'yolk',yolk,'anteriornuc',forwardnuc,'AP_x',APfixedx,'AP_y',APfixedy,'AntPosrat',apratmask);