function sortnarrowseries

propfiles=dir('*Properties.xml')
for i=1:length(propfiles)
    dirname=propfiles(i).name(1:(end-15));
    checkerflag=mkdir(dirname);
    if(checkerflag)
    movefile(strcat(propfiles(i).name(1:(end-15)),'*tif'),dirname)
    movefile(strcat(propfiles(i).name(1:(end-15)),'*xml'),dirname)
    end
end