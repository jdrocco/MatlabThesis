function grad=extractgrad(fluorim,nucmask,rotang)

%Rotate image and mask so it is orthogonal to our indices
envmask=imrotate(nucmask,rotang);
rotfluor=imrotate(squeeze(fluorim),rotang);

%Then go from left to right averaging the intensities falling within the
%mask at each stripe.

for j=1:size(rotfluor,2)
    if(max(envmask(:,j)))
        grad(j)=mean(rotfluor(logical(envmask(:,j)),j));
    end
end