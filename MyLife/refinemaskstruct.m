% This function will take up to a two dimensional mask structure and refine
% it on the assumption that all masks belong
% to the same embryo in approx. the same orientation.  It will ensure that
% the same size region is used while allowing for a maximum translational
% shift as specified by tolerabledriftsigma (hardwired).
% maskstruct=refinemaskstruct(maskstruct)

function maskstruct=refinemaskstruct(maskstruct)

convfactor=4;

for i=1:length(maskstruct)
    maskstruct(i).embryo=maskstruct(i).embnovit;
end

embmasksum=zeros(size(maskstruct(1).embryo,1),size(maskstruct(1).embryo,2));

%characteristic length for making decisions about cutoffs
sigma=ceil(size(embmasksum,2)/512);
tolerabledriftsigma=5;

timemax=length(maskstruct);

% Find the centroid of each embryo mask.
centra=zeros(length(maskstruct),2);
for j=1:length(maskstruct)
    embpro=regionprops(logical(maskstruct(j).embryo));
    centra(j,:)=embpro.Centroid;
end

pixeldrift=zeros(1,length(maskstruct));

% Calculate the drift of each embryo mask, and disregard masks after the
% maximum tolerable drift has been exceeded.
for j=1:length(maskstruct)
    pixeldrift(j)=sqrt((centra(j,2)-centra(1,2))^2+(centra(j,1)-centra(1,1))^2);
    if(pixeldrift(j)>(tolerabledriftsigma*sigma))
        timemax=j-1;
        break;
    end
end

% Determine the best mask on average for each embryo, using the masks which
% have not drifted too far. Discards the outlying 20% pixels and then takes
% the average mask after smoothing the rest.
	for j=1:timemax
        embmasksum=squeeze(embmasksum)+maskstruct(j).embryo;
    end

    outamp=floor(0.2*double(max(max(embmasksum))));
    embmaskcut=uint8(squeeze(embmasksum)-outamp);
    highvalue=max(max(embmaskcut(:))-outamp,1);
    highmask=embmaskcut>highvalue;
    embmaskcut(highmask)=highvalue;

    h=fspecial('gaussian',convfactor*sigma,sigma);
    embmasksmooth=imfilter(embmaskcut,h);
    outbelow=floor(0.5*double(max(embmaskcut(:))));
    embmaskfull=logical(embmasksmooth>outbelow);


% Now redo the mask structure by translating the master mask for each
% specific time point. Still provides a mask for the time points which have
% drifted too far, but with tag goodmask=0

    embmaskfinal=returnbiggest(squeeze(embmaskfull));
    
    if((logical(embmasksum)-logical(embmaskfinal))>(0.02*sum(embmaskfinal(:))))
        disp('Warning: Significant mask shifting. Perhaps AP selection problem');
    end

    embpro=regionprops(logical(squeeze(embmaskfinal)));
    mastercent=embpro.Centroid;
    for j=1:length(maskstruct)
        maskstruct(j).embryo=circshift(squeeze(embmaskfinal),[round(centra(j,2)-mastercent(2)) round(centra(j,1)-mastercent(1))]);
        if(j>timemax)
            maskstruct(j).goodmask=0;
        else
            maskstruct(j).goodmask=1;
        end
        maskstruct(j).pixeldrift=pixeldrift(j);
    end


