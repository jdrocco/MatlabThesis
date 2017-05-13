function DNApaircent=pairingnonexc(DNAcent)

numDNAnuc=size(DNAcent,1);

for i=1:numDNAnuc
    for j=(i+1):numDNAnuc
        DNAdist(i,j)=sqrt((DNAcent(i,1)-DNAcent(j,1))^2+(DNAcent(i,2)-DNAcent(j,2))^2);
        DNAdist(j,i)=DNAdist(i,j);
    end
end

DNAuse=DNAdist;
awayval=max(DNAuse(:))+1;
DNAuse(DNAuse==0)=awayval;
DNAsort=sort(DNAuse,1,'ascend');
DNAmeans=mean(DNAsort(1:6,:),1);
[mval,midx]=sort(DNAmeans,'descend');

paircounter=0;
pairing=zeros(1,2);
for j=midx
    if(max(max(pairing==j))==1)
        continue;
    end
    [val,loc]=min(DNAuse(j,:));
    if(val>30)
        continue;
    end
    paircounter=paircounter+1;
    pairing(paircounter,1)=j;
    pairing(paircounter,2)=loc;
end

for i=1:size(pairing,1)
    DNApaircent(i,1)=mean([DNAcent(pairing(i,1),1) DNAcent(pairing(i,2),1)]);
    DNApaircent(i,2)=mean([DNAcent(pairing(i,1),2) DNAcent(pairing(i,2),2)]);
end
