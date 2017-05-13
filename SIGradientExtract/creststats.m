% This function incorporates the parallel axis gradient into
% single gradient and computes frontend and backend intensities
% Within crestmult tree

function [gradoutmult,gradfs,change,changeloc,frontend,backend]=creststats(gradoutvarax,timesinseries,axboxes)

testdisc=fspecial('disk',ceil(axboxes/2));
centerdisc=squeeze(testdisc(ceil(axboxes/2),[1:floor(end/2) (floor(end/2)+2):end]));
sidedisc=squeeze(testdisc(ceil(axboxes/4),[1:floor(end/2) (floor(end/2)+2):end]));
for j=1:timesinseries
    gradoutsum(j,:)=squeeze(gradoutvarax(2,j,:))'.*centerdisc;
    gradoutsum(j,:)=gradoutsum(j,:)+squeeze(gradoutvarax(1,j,:))'.*sidedisc;
    gradoutsum(j,:)=gradoutsum(j,:)+squeeze(gradoutvarax(3,j,:))'.*sidedisc;
    gradoutmult(j,:)=gradoutsum(j,:)./(centerdisc+2*sidedisc);
end

for i=1:timesinseries
    change(i)=0;
    storchange(i)=0;
    for j=ceil(axboxes/20):floor(19*axboxes/20)
        if((i>1)&&~isnan(gradoutmult(i,j))&&~isnan(gradoutmult(i-1,j)))
            change(i)=change(i)+(gradoutmult(i,j)-gradoutmult(i-1,j))^2;
            storchange(i)=storchange(i)+1;
        end
    end
end

change=change./storchange;
change(1)=0;

frontend=mean(gradoutmult(:,(end/10):(end/5)),2);
backend=mean(gradoutmult(:,(end-end/5):(end-end/10)),2);

[changemin,changeloc]=min(change(2:timesinseries));
gradfs=mean(gradoutmult(changeloc:changeloc+1,:),1);
