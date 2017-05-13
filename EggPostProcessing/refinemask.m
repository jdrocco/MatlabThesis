function [nucmaskfinal,embmaskfinal]=refinemask(maskstruct)

embmasksum=zeros(size(maskstruct,1),1024,1024);
embmaskcut=zeros(size(maskstruct,1),1024,1024);
for i=1:size(maskstruct,1)
	for j=1:size(maskstruct,2)
        embmasksum(i,:,:)=squeeze(embmasksum(i,:,:))+maskstruct(i,j).embryo;
    end
end
outamp=floor(0.2*double(max(embmasksum(:))));
embmaskcut=uint8(embmasksum-outamp);
embmaskcut(embmaskcut>(max(embmaskcut(:))-outamp))=max(embmaskcut(:))-outamp;

sigma=ceil(size(embmasksum,2)/512);
h=fspecial('gaussian',4*sigma,sigma);
for i=1:size(maskstruct,1)
    embmasksmooth(i,:,:)=imfilter(squeeze(embmaskcut(i,:,:)),h);
end
outbelow=floor(0.5*double(max(embmaskcut(:))));
embmaskfull=logical(embmasksmooth>outbelow);

for i=1:size(maskstruct,1)
    embmaskfinal(i,:,:)=returnbiggest(squeeze(embmaskfull(i,:,:)));
end

for i=1:size(maskstruct,1)
    BWemb=squeeze(embmaskfinal(i,:,:));
    regpro=regionprops(bwlabel(BWemb),'all');
    
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
    nucmaskfinal(i,:,:)=nuclear;
    yolk=logical(BWmod);


%     %If a mask pixel is closer to the anterior tip, then put it in that mask
%     [nucx,nucy]=find(nuclear);
%     for k=1:length(nucx)
%         distsq1=(nucx(k)-APfixedx(1))^2+(nucy(k)-APfixedy(1))^2;
%         distsq2=(nucx(k)-APfixedx(2))^2+(nucy(k)-APfixedy(2))^2;
%         antposrat(k)=sqrt(distsq1/distsq2);
%     end
%     forwardnuc=zeros(size(nuclear));
%     apratmask=zeros(size(nuclear));
%     indices=find(nuclear);
%     apratmask(indices)=antposrat;
% 
%     %Finally make an anterior nuclei mask.  Use the cutoff ratio of 1.
%     cutoffaprat=1;
%     forwardnuc=apratmask<1&nuclear;
%     forwardnuc=logical(forwardnuc);
end
