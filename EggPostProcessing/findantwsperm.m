% This function will add an anteriornuc mask to a maskstruct by specifying
% the location of the micropili tip.  It will also flip the AP-axis points
% if necessary.
% maskstruct=findantwsperm(maskstruct)

function maskstruct=findantwsperm(maskstruct)

[AP_x,AP_y]=findAPaxis(maskstruct.embryo);
spermtip=maskstruct.spermtip;

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
[nucx,nucy]=find(maskstruct.nuclear);
for k=1:length(nucx)
    distsq1=(nucx(k)-APfixedx(1))^2+(nucy(k)-APfixedy(1))^2;
    distsq2=(nucx(k)-APfixedx(2))^2+(nucy(k)-APfixedy(2))^2;
    antposrat(k)=sqrt(distsq1)/(sqrt(distsq1)+sqrt(distsq2));
end
forwardnuc=zeros(size(maskstruct.nuclear));
apratmask=zeros(size(maskstruct.nuclear));
indices=find(maskstruct.nuclear);
apratmask(indices)=antposrat;

%Finally make an anterior nuclei mask.  Use the cutoff ratio of 1.
cutoffaprat=0.5;
forwardnuc=(apratmask<cutoffaprat)&maskstruct.nuclear;
forwardnuc=logical(forwardnuc);

maskstruct.anteriornuc=forwardnuc;
maskstruct.AP_x=APfixedx;
maskstruct.AP_y=APfixedy;
maskstruct.AntPosrat=apratmask;