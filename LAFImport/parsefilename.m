% This function parses a LAF-produced filename.

function [namestruct,letterid,numericalid]=parsefilename(filename)

xmltypestrings={'Series' 'Pos' 'SnoopyHun' 'WoodyHun' 'ProjMax' 'Image' 'S' 'FRAP Bleach Series' 'FRAP Pb1 Series' 'FRAP Pre Series' 'FRAP Series' 'LatenoUV' 'SinglenoUV' 'InitMagic' 'MakeMagic' 'SeeMagic' 'OutMagic' 'uvie' 'seeie' 'transie' 'seeieb' 'transieb' 'seeiec' 'transiec' 'seeied' 'transied' 'seeiee' 'transiee' 'seeief' 'transief' 'seeieg' 'transieg' 'seeieh' 'transieh' 'Narrow' 'losie' 'seqie' 'Charlie' 'Woodstock' 'Snoopy' 'Lucy' 'Linus' 'MakeMagic' 'OutMagic' 'SeeMagic' 'InitMagic' 'weardown' 'wearun' 'wearinc' 'wearmult' 'pushup'};

underscorelocs=find(filename=='_');
periodloc=find(filename=='.');

testfirstslice=filename(1:(underscorelocs(1)-1));
lastletter=find(~(int16(testfirstslice)>47&int16(testfirstslice)<58),1,'last');
letterid=cellstr(filename(1:lastletter));
if(logical(sum(strcmp(cellstr(letterid),xmltypestrings))))
    keyparselocs(1)=0;
    keyparselocs(2:(length(underscorelocs)+1))=underscorelocs;
    keyparselocs(end+1)=periodloc(end);
else
    keyparselocs=underscorelocs;
    keyparselocs(length(underscorelocs)+1)=periodloc(end);
end

parsingregs=length(keyparselocs)-1;
letterid=cell(1,parsingregs);
numberreg=zeros(parsingregs,length(filename));
letterreg=zeros(parsingregs,length(filename));
xmlworthy=zeros(1,parsingregs);
integerid=zeros(1,parsingregs);
timeind=nan;
chanid=nan;

for q=1:parsingregs
    slicetoparse=filename((keyparselocs(q)+1):(keyparselocs(q+1)-1));
    numnumbers=0;
    while(int16(slicetoparse(end-numnumbers))>47&&int16(slicetoparse(end-numnumbers))<58)
        numnumbers=numnumbers+1;
    end
    numberreg(q,(keyparselocs(q+1)-numnumbers):(keyparselocs(q+1)-1))=1;
    numericalid(q)=cellstr(filename(logical(numberreg(q,:))));
    integerid(q)=str2num(char(numericalid(q)));
    letterreg(q,(keyparselocs(q)+1):(keyparselocs(q+1)-numnumbers-1))=1;
    letterid(q)=cellstr(filename(logical(letterreg(q,:))));
    if(logical(sum(strcmp(letterid(q),xmltypestrings))))
        xmlworthy(q)=1;
    else
        xmlworthy(q)=0;
    end
    if(strcmp(letterid(q),cellstr('t')))
        timeind=q;
    end
    if(strcmp(letterid(q),cellstr('ch')))
        chanind=q;
    end
end

%Then determine what the corresponding xml filename is.

for r=1:length(xmlworthy)
    if(xmlworthy(r)==1&&(exist('xmlname')))
        xmlname=strcat(xmlname,'_',char(letterid(r)),char(numericalid(r)));
    end
    if(xmlworthy(r)==1&&(~exist('xmlname')))
        xmlname=strcat(char(letterid(r)),char(numericalid(r)));
    end
end
xmlname=strcat(xmlname,'.xml');

namestruct=struct('filename',filename,'parsingregs',parsingregs,'integerid',integerid,'letterreg',letterreg,'numberreg',numberreg,'xmlworthy',xmlworthy,'timeind',timeind,'chanind',chanind,'xmlname',xmlname);