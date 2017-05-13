% This function will accept a 2-D image and segment it into regions of int.

function regions=detectreg(fluormean,sigcutoff)

if(~exist('sigcutoff','var'))
    sigcutoff=0.16;
end

phaseSymfb = phasesym(fluormean,'k',12,'norient',12);

phaselog=logical(phaseSymfb>sigcutoff);
BWdfill = imfill(phaselog, 'holes');
BWfinal=(imfill(BWdfill-phaselog,'holes'));

%Finally, label the regions
regions=bwlabel(BWfinal);