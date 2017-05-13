function [twodx,twody,pcorrx,pcorry,yintx,yinty]=difffit(gendatname)

if(~exist('gendatname','var'))
    gendatname='diff*';
end

files=dir(gendatname);
% linearityf=figure;
for nowind=1:length(files)
    currstring=(files(nowind).name);
    volind=find(currstring=='v',1,'last');
    currind=find(currstring=='c',1,'last');
    sqind=find(currstring=='s',1,'last');
    volfracstore(nowind)=str2num(currstring((volind+1):(currind-1)));
    currentstore(nowind)=str2num(currstring((currind+1):(sqind-1)));    
end

[trash,trashy,volfraclu]=unique(volfracstore);

for nowind=1:length(files)
    currstring=(files(nowind).name);
    if(~(files(nowind).bytes))   %check to make sure file not empty
        continue;
    end
    result=importdata(currstring,' ');
    
    volfrac=volfraclu(nowind);
    current=currentstore(nowind);
    meanxsq=result(:,2);   
    meanysq=result(:,4);   
    taureals=result(:,1);
    
    coeffsx=polyfit(taureals,meanxsq,1);
    corrcoeffsoutx=corrcoef(taureals,meanxsq);
    pearcorrx=corrcoeffsoutx(1,2);
    
    coeffsy=polyfit(taureals,meanysq,1);
    corrcoeffsouty=corrcoef(taureals,meanysq);
    pearcorry=corrcoeffsouty(1,2);
    
    twodx(volfrac,current)=coeffsx(1);
    pcorrx(volfrac,current)=pearcorrx;
    yintx(volfrac,current)=coeffsx(2);
    twody(volfrac,current)=coeffsy(1);
    pcorry(volfrac,current)=pearcorry;
    yinty(volfrac,current)=coeffsy(2);

end

% figure(linearityf); imagesc(twodx);