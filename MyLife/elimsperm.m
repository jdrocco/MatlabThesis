%This function will eliminate a "sperm" that is dangling from the edge of the
%embryo region. It will also eliminate all but the biggest region.

function fixedBWemb=elimsperm(bigreg)

sesize=2;

% gausssize=4;
% 
% cim=harris(transmean, gausssize);

se=strel('disk',sesize);
openedim=imopen(bigreg,se);
fixedBWemb=returnbiggest(openedim);