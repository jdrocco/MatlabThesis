% This function is now required to prep image files for crestmult.
% Outputs a mat file for each embryo.
% Deprecated with use of NLS to smooth background

function crestprep(npreps,smoothbgd,number_of_embryos,timesinseries,number_of_frames,stacksize,transdir,twochaninput)

% ydimreal=298.7;    % approx for Nikon 20x 512x256 2.5 x 1.25V, zoom 1
% xdimreal=632.9;
ydimreal=619.01;  %for Nikon 20x 192x1024 1 x 2.5, zoom 1
xdimreal=256.9;
%ydimreal=650.9;  % approx for Nikon 20x 192x1024 1 x 2.55, zoom 1
%xdimreal=277.2;   % measured for late May runs on rear Olympus w Nikon 20x
%ydimreal=714.1;

if(~(exist('twochaninput')))
twochaninput=0;
end

for n=1:npreps
[firstfilename(n,:),pathname(n,:)] = uigetfile('*.tif', 'chose a file');
end

for n=1:npreps
cd(pathname(n,:))
files=dir;
for i=1:length(files)
    if length(files(i).name)==length(firstfilename(n,:))
        if files(i).name==firstfilename(n,:)
            onepicked=i;
        end
    end
end

clear imchan1 time timesec header createdpts imchan2
for i=1:timesinseries
    if(exist('zstep'))
        zstepold=zstep;
    end
    filename=files(onepicked+number_of_embryos*number_of_frames*(i-1)).name;
    [imchan1(i,:,:,:),timesec(i),zstep,header(i),createdpts(i,:,:),imchan2(i,:,:,:)]=crestims(smoothbgd,number_of_frames,stacksize,pathname(n,:),filename,twochaninput,xdimreal,ydimreal);
    if(exist('zstepold')&&~(zstep==zstepold))
        disp('Zstep changed, check to see if correct files are being loaded')
    end
end

time=timesec/60;
xppm=size(imchan1,3)/xdimreal;
yppm=size(imchan1,4)/ydimreal;
dumppath=strcat('j',firstfilename(n,1:end-3),'mat');
save(dumppath,'imchan1','time','zstep','header','createdpts','smoothbgd','number_of_embryos','timesinseries','number_of_frames','stacksize','dumppath','xppm','yppm','imchan2','transdir');
end
