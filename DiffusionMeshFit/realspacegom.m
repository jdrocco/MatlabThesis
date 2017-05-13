function gomrsout=realspacegom(gomcompavg,egglcomp)

gomrssum=zeros(size(gomcompavg,2),ceil(max(egglcomp)));
gomrscount=gomrssum;
axboxes=size(gomcompavg,3);
for i=1:size(gomcompavg,2)
    for k=1:size(gomcompavg,1)
        for j=1:ceil(egglcomp(k))
            gomrssum(i,j)=gomrssum(i,j)+gomcompavg(k,i,ceil(j*axboxes/ceil(egglcomp(k))));
            gomrscount(i,j)=gomrscount(i,j)+1;
        end
    end
end
gomrsout=gomrssum./gomrscount;