function [phase,nuccent,somedist,cencent]=nucandsome(nuclabel,somepts)

for i=1:length(somepts)
    belongsto(i)=nuclabel(round(somepts(i,2)),round(somepts(i,1)));
end

for i=1:max(nuclabel(:))
    validnuc(i)=sum(belongsto==i)==2;
end

j=0;
for i=find(validnuc)
    j=j+1;
    centrinds=find(belongsto==i);
    phase(j)=atan((somepts(centrinds(1),2)-somepts(centrinds(2),2))/(somepts(centrinds(1),1)-somepts(centrinds(2),1)));
    regpro=regionprops(nuclabel==i);
    cencent(j,1)=mean([somepts(centrinds(1),1) somepts(centrinds(2),1)]);
    cencent(j,2)=mean([somepts(centrinds(1),2) somepts(centrinds(2),2)]);
    nuccent(j,:)=regpro.Centroid;
    somedist(j)=sqrt((somepts(centrinds(1),2)-somepts(centrinds(2),2))^2+(somepts(centrinds(1),1)-somepts(centrinds(2),1))^2);
end
