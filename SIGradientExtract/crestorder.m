% This file takes a gomcompavg along with avscomp and plots
% the gradient time series and total Bcd quantity in an inset

function [goodgcresetnan,amountrealtrealx]=crestorder(gomcomp,avscomp,timecomp,egglcomp,maxoffset)

axboxes=size(avscomp,3);

dimanalfac=3.14159*mean(egglcomp)/axboxes;
fudgefactor=1000;    % multiply comp_c by this to get molecules/micron^3

radmat=mean(squeeze(max(avscomp,[],2)),1);
areamat=(radmat.^2)/(sum(radmat.^2));
for i=1:size(gomcomp,1)
    for j=1:size(gomcomp,2)
        amountpres(i,j)=nansum(squeeze(gomcomp(i,j,:)).*(areamat'));
    end
end

coeffsout=polyfit(1:size(amountpres,2),mean(amountpres,1),1);

intengrowperacq=coeffsout(1);
offset=round((mean(amountpres,2)-min(mean(amountpres,2)))/intengrowperacq);

if(exist('maxoffset')&&(max(offset)>maxoffset))
    offset=round(offset/(max(offset)/maxoffset));
end

for i=1:size(gomcomp,1)
goodgcreset(i,(offset(i)+1):(offset(i)+size(gomcomp,2)),:)=gomcomp(i,:,:);
end

goodgcresetnan=goodgcreset;
goodgcresetnan(goodgcreset==0)=nan;

figure; hold on;
map=colormap;
timerange=1:size(goodgcresetnan,2);
for i=timerange
errorbar(linspace(0,1,size(gomcomp,3)),squeeze(nanmean(goodgcresetnan(:,i,:),1)),squeeze(nanstd(goodgcresetnan(:,i,:),[],1)),'color',squeeze(map(ceil((i-timerange(1)+1)*64/length(timerange)),:)));
end
xlim([0 1]);
xlabel('x_{AP} (<L>)');
ylabel('c_{Bcd}');

tintervals=mean(timecomp,1)-circshift(mean(timecomp,1),[0 1]);
interval=mean(tintervals(2:end));

for i=1:size(goodgcresetnan,1)
    for j=1:size(goodgcresetnan,2)
        amountpresrealt(i,j)=nansum(squeeze(goodgcresetnan(i,j,:)).*(areamat'));
    end
end
amountpresrealt(amountpresrealt==0)=nan;
amountrealtrealx=amountpresrealt*fudgefactor*dimanalfac;
axes('position',[0.53 0.55 0.3 0.3]);
errorbar(((1:size(amountrealtrealx,2))*interval)-(interval/2),nanmean(amountrealtrealx,1),nanstd(amountrealtrealx,[],1),'+');
xlabel('t (min)');
ylabel('Q_{Bcd}');
