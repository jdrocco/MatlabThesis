function powerhist(showcurves,opflag,diagfilename)

if(~exist('opflag','var'))
    opflag=0;
end

if(~exist('diagfilename','var'))
    diagfilename=uigetfile;
end

hold on;
map=colormap;
% binsize=filesaysbinsize*filesayscurrent/decifacxtimestep;

result=importdata(diagfilename,' ');
binlocs=result(:,2);
negcts=result(:,3);
poscts=result(:,4);
taureals=result(:,1);
[uniquetaureal,firsttauinds,taumask]=unique(taureals);
if(~opflag)
    taurange=1:(round(length(uniquetaureal)/(showcurves-1))):(length(uniquetaureal));
else
    taurange=1:opflag:(showcurves*opflag);
end
for j=taurange
    handlevechist(j)=semilogy(binlocs(taumask==j),poscts(taumask==j)/(sum(negcts(taumask==j))+sum(poscts(taumask==j))),'+','color',squeeze(map(ceil(j*64/(max(taurange))),:)));
    semilogy(-binlocs(taumask==j),negcts(taumask==j)/(sum(negcts(taumask==j))+sum(poscts(taumask==j))),'+','color',squeeze(map(ceil(j*64/(max(taurange))),:)));
    legtrans=sprintf('t = %.2f',uniquetaureal(j));
    legpart(j,1:length(legtrans))=legtrans;
end
xlabel('J_{\tau}');
ylabel('p(J_{\tau})');
legend(handlevechist(taurange),legpart(taurange,:));
title(diagfilename);