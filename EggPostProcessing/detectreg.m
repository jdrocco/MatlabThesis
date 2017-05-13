% This function will accept a 2-D image and segment it into regions of int.

function regions=detectreg(im,fudgeFactor)

%Use the sobel method to find the salient boundaries.  Get a threshold
%first and then detune it.
[junk threshold] = edge(im, 'sobel');
if(~exist('fudgeFactor','var'))
    fudgeFactor = .7;
end
BWs = edge(im,'sobel', threshold * fudgeFactor);

%Use a linear structuring element to expand the boundary features.
se90 = strel('line', 3, 90);
se0 = strel('line', 3, 0);
BWsdil = imdilate(BWs, [se90 se0]);

%Fill in the gaps to make convex regions
BWdfill = imfill(BWsdil, 'holes');

%Remove "dusty" particles that may have attached themselves to the region
%First do single pixels attached on a diagonal
% BWnobord = imclearborder(BWdfill, 4);  %Removed this--problems if emb
% touches side of image field
BWnobord=BWdfill; 
%Then look for larger diamond structures;
seD = strel('diamond',1);
BWfinal = imerode(BWnobord,seD);
BWfinal = imerode(BWfinal,seD);

%Finally, label the regions
regions=bwlabel(BWfinal);