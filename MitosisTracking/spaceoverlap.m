function dimermap=spaceoverlap(imcomp456,phase456,nuccent456,figshow)

if(~exist('figshow'))
    figshow=0;
end

newcamp=zeros(150);
newcamp(13:137,60:90)=1;

dimermap=zeros(size(imcomp456));
for i=1:length(phase456)
rotdim=imrotate(newcamp,-(phase456(i)+(pi/2))*180/pi,'crop');
dimermap((round(nuccent456(i,2)-.5)-74):(round(nuccent456(i,2)-.5)+75),(round(nuccent456(i,1)-.5)-74):(round(nuccent456(i,1)-.5)+75))=dimermap((round(nuccent456(i,2)-.5)-74):(round(nuccent456(i,2)-.5)+75),(round(nuccent456(i,1)-.5)-74):(round(nuccent456(i,1)-.5)+75))+rotdim;
end

if(figshow)
figure; imagesc((max(double(imcomp456(:)))/3)*dimermap+double(imcomp456));
end