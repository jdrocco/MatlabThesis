% This function will accept a 2-D image and segment it into regions of int.

function regions=detectreg(fluormean,sigcutoff)

divverlen=50;
if(~exist('sigcutoff','var'))
    sigcutoff=0.16;
end

phaseSymfb = phasesym(fluormean,'k',12,'norient',12);

phaselog=logical(phaseSymfb>sigcutoff);

linelen=ceil(sqrt(size(phaselog,1)*size(phaselog,2))/50);
phaseout=phaselog;
for i=5:5:180
senow=strel('line',linelen,i);
phaselog=phaselog+(imclose(phaseout,senow)-phaseout);
end
BWdfill = imfill(phaselog, 'holes');
BWfinal=(imfill(BWdfill-phaselog,'holes'));

%Finally, label the regions
regions=bwlabel(BWfinal);