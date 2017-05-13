function [normvec,nxi,nyi,nzi,devfromvert]=tangfinder(depthorig,xdim,ydim,zstep)

xpixels=size(depthorig,1);
ypixels=size(depthorig,2);
smoothfact=100;

differx=1;
differy=round(differx*((xdim/xpixels)/(ydim/ypixels)));
if(differy<1)
    differy=1;
end

h=elliptfspecial(xdim/smoothfact,ydim/smoothfact);
depther=imfilter(depthorig,h);
% totalslices=round(max(depther(:)));

% numcontrange=(totalslices-3):(totalslices+10);

% for j=numcontrange
%     qs=contourc(double(depther),j);
%     if((max(mod(qs(1,find(qs(1,:)<(j+1))),1))<0.01)||(j==numcontrange(end)))
%         break;
%     end
% end

% qs=contourc(double(depther),round(3*zstep*totalslices));
% 
% summedim=nan(size(depther));
% maxer=size(qs,2);
% 
% while(maxer>0)
%     controlnow=size(qs,2)-maxer+1;
%     tillnext=qs(2,controlnow);
%     levelnow=qs(1,controlnow);
%     for i=1:tillnext
%         summedim(ceil(qs(2,controlnow+i)),ceil(qs(1,controlnow+i)))=zstep*levelnow;
%     end
%     maxer=maxer-tillnext-1;
% end

depther(depther==0)=nan;
% 
% [xs,ys]=find(~isnan(depther));
[nxi,nyi]=meshgrid(linspace(0,xdim,xpixels),linspace(0,ydim,ypixels));
% [nxi,nyi,nzi]=griddata(xs*(xdim/xpixels),ys*(ydim/ypixels),double(summedim(~isnan(summedim))),xi,yi,'cubic');
nzi=zstep*depther';

% F=TriScatteredInterp(xs*(xdim/xpixels),ys*(ydim/ypixels),double(summedim(~isnan(summedim))),xi,yi);
normvec=zeros(size(nzi,1),size(nzi,2),3);

for curry=(differy+1):(ypixels-differy)
    for currx=(differx+1):(xpixels-differx)
    	normvec(curry,currx,:)=cross([nxi(curry+differy,currx)-nxi(curry-differy,currx) nyi(curry+differy,currx)-nyi(curry-differy,currx) nzi(curry+differy,currx)-nzi(curry-differy,currx)],[nxi(curry,currx+differx)-nxi(curry,currx-differx) nyi(curry,currx+differx)-nyi(curry,currx-differx) nzi(curry,currx+differx)-nzi(curry,currx-differx)]);
    end
end

devfromvert=sqrt(squeeze(normvec(:,:,1)).^2+squeeze(normvec(:,:,2)).^2)/abs(mode(mode(normvec(:,:,3))));


%then normalize vectors
