% This function will take up to a two dimensional mask structure and refine
% it on the assumption that all masks sharing the same first index belong
% to the same embryo in approx. the same orientation.  It will ensure that
% the same size region is used while allowing for a maximum translational
% shift as specified by tolerabledriftsigma (hardwired).
% maskstruct=refinemaskstruct(maskstruct)

function maskstruct=refinemaskstr(maskstruct)

embmasksum=zeros(size(maskstruct,1),size(maskstruct(1,1).embryo,1),size(maskstruct(1,1).embryo,2));
% embmaskcut=zeros(size(maskstruct,1),size(maskstruct(1,1).embryo,1),size(maskstruct(1,1).embryo,2));

%characteristic length for making decisions about cutoffs
sigma=ceil(size(embmasksum,2)/512);
tolerabledriftsigma=30;

timemax=size(maskstruct,2)*ones(size(maskstruct,1),1);

% Find the centroid of each embryo mask.
centra=zeros(size(maskstruct,1),size(maskstruct,2),2);
for i=1:size(maskstruct,1)
	for j=1:size(maskstruct,2)
        embpro=regionprops(bwlabel(maskstruct(i,j).embryo));
        centra(i,j,:)=embpro.Centroid;
    end
end

pixeldrift=zeros(size(maskstruct,1),size(maskstruct,2));

% Calculate the drift of each embryo mask, and disregard masks after the
% maximum tolerable drift has been exceeded.
for i=1:size(maskstruct,1)
    for j=1:size(maskstruct,2)
        pixeldrift(i,j)=sqrt((centra(i,j,2)-centra(i,1,2))^2+(centra(i,j,1)-centra(i,1,1))^2);
        if(pixeldrift(i,j)>(tolerabledriftsigma*sigma))
            timemax(i)=j-1;
            break;
        end
    end
end

% Determine the best mask on average for each embryo, using the masks which
% have not drifted too far. Discards the outlying 20% pixels and then takes
% the average mask after smoothing the rest.
embmaskfull=zeros(size(embmasksum));
for i=1:size(maskstruct,1)
	for j=1:timemax(i)
        embmasksum(i,:,:)=squeeze(embmasksum(i,:,:))+maskstruct(i,j).embryo;
    end

    outamp=floor(0.2*double(max(max(embmasksum(i,:,:)))));
    embmaskcut=uint8(squeeze(embmasksum(i,:,:))-outamp);
    highvalue=max(max(embmaskcut(:))-outamp,1);
    highmask=embmaskcut>highvalue;
    embmaskcut(highmask)=highvalue;

    h=fspecial('gaussian',4*sigma,sigma);
    embmasksmooth=imfilter(embmaskcut,h);
    outbelow=floor(0.5*double(max(embmaskcut(:))));
    embmaskfull(i,:,:)=logical(embmasksmooth>outbelow);
end

%Eliminate the micropile.
[fixedBWemb,spermtip]=elimsperm(logical(squeeze(sum(embmaskfull,1))));
cutter=logical(squeeze(sum(embmaskfull,1)))&~fixedBWemb;
embmaskfull(:,cutter)=0;

% Now redo the mask structure by translating the master mask for each
% specific time point. Still provides a mask for the time points which have
% drifted too far, but with tag goodmask=0

embmaskfinal=zeros(size(embmasksum));
for i=1:size(maskstruct,1)
    embmaskfinal(i,:,:)=returnbiggest(squeeze(embmaskfull(i,:,:)));
    embpro=regionprops(bwlabel(squeeze(embmaskfinal(i,:,:))));
    if(~isempty(embpro)) % If there's nothing just leave it.
        mastercent=embpro.Centroid;
    end
    for j=1:size(maskstruct,2)
        pixelshifty=round(centra(i,j,2)-mastercent(2));
        pixelshiftx=round(centra(i,j,1)-mastercent(1));
        maskstruct(i,j).embryo=circshift(squeeze(embmaskfinal(i,:,:)),[pixelshifty pixelshiftx]);
        if(j>timemax(i))
            maskstruct(i,j).goodmask=0;
        else
            maskstruct(i,j).goodmask=1;
        end
        maskstruct(i,j).pixeldrift=pixeldrift(i,j);
        maskstruct(i,j).pixelshifty=pixelshifty;
        maskstruct(i,j).pixelshiftx=pixelshiftx;
    end
end


