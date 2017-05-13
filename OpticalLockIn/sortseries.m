function sortseries(stringer,cutoffend)

if(~exist('stringer','var'))
    stringer='*Properties.xml';
end

if(~exist('cutoffend','var'))
    cutoffend=15;
end

propfiles=dir(stringer);
for i=1:length(propfiles)
    dirname=propfiles(i).name(1:(end-cutoffend));
    checkerflag=mkdir(dirname);
    if(checkerflag)
    movefile(strcat(propfiles(i).name(1:(end-cutoffend)),'*tif'),dirname)
    movefile(strcat(propfiles(i).name(1:(end-cutoffend)),'*xml'),dirname)
    end
end