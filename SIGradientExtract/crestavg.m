% Takes a gomcomp matrix and sums different depths to create one
% gradient time series per embryo

function gomcompavg=crestavg(actualems,gomcomp,depthint)

if(~exist('depthint'))
    depthint=1:(size(gomcomp,1)/actualems);
end
gomcompavg=zeros(actualems,size(gomcomp,2),size(gomcomp,3));
for i=depthint
for j=1:actualems
gomcompavg(j,:,:)=gomcompavg(j,:,:)+gomcomp((i-1)*actualems+j,:,:);
end
end
