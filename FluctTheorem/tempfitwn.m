function [efftemp,combotausave,combotempsave,combocorrsave]=tempfitwn(fitcutoff,gendatname,opflag)

if(~exist('gendatname','var'))
    gendatname='*dat';
end

if(~exist('fitcutoff','var'))
    fitcutoff=0;
end

if(~exist('opflag','var'))
    opflag=0;
end

files=dir(gendatname);
dropdiv=5;
mintaus=5;
minbins=20;
showmult=10;
showcurves=5;
map=colormap;
linearityf=figure;
asymptotef=figure;
combof=figure;

for nowind=1:length(files)
    currstring=(files(nowind).name);
    volind=find(currstring=='v',1,'last');
    currind=find(currstring=='c',1,'last');
    nind=find(currstring=='n',1,'last');
    qdind=findstr(currstring,'qd');
    sqind=find(currstring=='.',1,'last');
    volfracstore(nowind)=str2num(currstring((volind+1):(currind-1)));
    currentstore(nowind)=str2num(currstring((currind+1):(nind-1)));
    qdstore(nowind)=str2num(currstring((qdind+2):(volind-1)));
    nstore(nowind)=str2num(currstring((nind+1):(sqind-1)));
end

[trash,trashy,volfraclu]=unique(volfracstore);
[garbage,garbagey,qdlu]=unique(qdstore);

for nowind=1:length(files)
    currstring=(files(nowind).name);
    if(~(files(nowind).bytes))   %check to make sure file not empty
        continue;
    end
    result=importdata(currstring,' ');
    volfrac=volfraclu(nowind);
    qdlev=qdlu(nowind);
    nnow=nstore(nowind)+1;
    disspow=result(:,3);   % meaning actual J_t, also known as the "sum neg A not"
    lnprat=result(:,2);    % meaning lognegposrat
    taureals=result(:,4);
    [uniquetaureal,firsttauinds,taumask]=unique(taureals);
    if(length(taumask)<minbins)
        continue;
    end
    if(~(sum(taumask(1:minbins))==minbins))   % Make sure maxxfit def is legal
        continue;
    end
    maxxfit=abs(disspow(minbins));   % So in other words this says we want to fit all J_t less than the greatest of the first 9 points.
    if(sum(taumask==mintaus)<ceil(minbins/2))    % Now we also make sure there are at least enough taus
        continue;
    end
    
    coeffs=nan(length(uniquetaureal),2);
    pearcorr=nan(length(uniquetaureal),1);
    for k=1:length(uniquetaureal)
        if(sum(taumask==k)>1)
            coeffs(k,:)=polyfit(disspow(find(taumask==k,minbins,'first')),-lnprat(find(taumask==k,minbins,'first')),1);
            corrcoeffsout=corrcoef(disspow(find(taumask==k,minbins,'first')),-lnprat(find(taumask==k,minbins,'first')));
            pearcorr(k)=corrcoeffsout(1,2);
        end
    end
    
    figure(linearityf); clf; hold on;
    if(~opflag)
        taurange=1:(round(length(uniquetaureal)/(showcurves-1))):(length(uniquetaureal));
    else
        taurange=1:opflag:(showcurves*opflag);
    end
    for k=taurange
        handlevec(k)=plot(disspow(find(taumask==k,minbins*showmult,'first')),-lnprat(find(taumask==k,minbins*showmult,'first')),'+','color',squeeze(map(ceil(k*64/(max(taurange))),:)));
        line([0 maxxfit],[coeffs(k,2) coeffs(k,2)+maxxfit*coeffs(k,1)],'color',squeeze(map(ceil(k*64/(max(taurange))),:)));
    end
    ylabel('ln[p(J_{\tau})/p(-J_{\tau})]')
    xlabel('J_{\tau}');  title(currstring);
    
    figure(asymptotef); clf; hold on; 
    plot(uniquetaureal,uniquetaureal./squeeze(coeffs(:,1)));
    xlabel('\tau'); ylabel('\tau/S_{\tau}'); title(currstring);
    
%    figure(combof); hold on;
    if(isempty(find(~(pearcorr>fitcutoff),1,'first')))
        lastk=length(pearcorr);
    else
        lastk=find(~(pearcorr>fitcutoff),1,'first')-1;
    end
    for k=1:lastk
        combotausave(volfrac,qdlev,nnow,k)=uniquetaureal(k);
        combotempsave(volfrac,qdlev,nnow,k)=uniquetaureal(k)/squeeze(coeffs(k,1));
        combocorrsave(volfrac,qdlev,nnow,k)=pearcorr(k);
%        plot(uniquetaureal(k),uniquetaureal(k)/squeeze(coeffs(k,1)),'+','color',squeeze(map(ceil((pearcorr(k)-fitcutoff)*64/(1-fitcutoff)),:)));
    end
%    xlabel('\tau'); ylabel('\tau/S_{\tau}');
    
    efftemp(volfrac,qdlev,nnow)=nanmedian(uniquetaureal(ceil(end/dropdiv):end)./squeeze(coeffs(ceil(end/dropdiv):end,1)));
    
%     taustodi=num2str(uniquetaureal(taurange));
%     legend(handlevec(taurange),strcat('\tau = ',taustodi(1,:)),strcat('\tau = ',taustodi(2,:)),strcat('\tau = ',taustodi(3,:)),strcat('\tau = ',taustodi(4,:)),strcat('\tau = ',taustodi(5,:)));

    pause(.2);
end