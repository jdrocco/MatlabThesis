

clear allcent
for i=1:(size(DNApaircent,1)+size(PHIScent,1))
if(i<=size(DNApaircent,1))
allcent(i,1)=DNApaircent(i,1);
allcent(i,2)=DNApaircent(i,2);
allcent(i,3)=-1;
else
allcent(i,1)=PHIScent(i-size(DNApaircent,1),1);
allcent(i,2)=PHIScent(i-size(DNApaircent,1),2);
allcent(i,3)=1;
end
end

counter=0;
clear pairycory
for i=1:size(allcent,1)
for j=(i+1):size(allcent,1)
distnow=sqrt((allcent(i,1)-allcent(j,1))^2+(allcent(i,2)-allcent(j,2))^2);
if(distnow<250)
counter=counter+1;
pairycory(counter,1)=distnow;
pairycory(counter,2)=allcent(i,3)*allcent(j,3);
pairycory(counter,3)=allcent(i,3)+allcent(j,3);
end
end
end

figure; hold on;
for i=1:250
    plot(i,mean(pairycory(round(pairycory(:,1))==i,2))-(((size(DNApaircent,1)-size(PHIScent,1))/(size(DNApaircent,1)+size(PHIScent)))^2),'+');
end
xlabel('|r_i-r_j|'); ylabel('<\pi_i\pi_j> - <\pi_i><\pi_j>');

figure; hold on;
for i=1:250
    plot(i,mean(pairycory(round(pairycory(:,1))==i,3)),'+');
end
xlabel('|r_i-r_j|'); ylabel('<\pi_i + \pi_j>');
