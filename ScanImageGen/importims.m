function imstruct=importims(filenames,stacksize,numchans)

testim=imread(filenames(1).name,1);

imstack=uint16(false(length(filenames),stacksize,numchans,size(testim,1),size(testim,2)));
abstime=zeros(length(filenames),1);
xpos=zeros(length(filenames),1);
ypos=zeros(length(filenames),1);
zstep=zeros(length(filenames),1);

for i=1:length(filenames)
    [abstime(i),xpos(i),ypos(i),zstep(i)]=getsiheaderinfo(filenames(i).name);
    for j=1:stacksize
        for k=1:numchans
            imstack(i,j,k,:,:)=imread(filenames(i).name,(numchans*j)+k-numchans);
        end
    end
end

imstruct=struct('Images',imstack,'LocalTimeSec',abstime,'Xorigin',xpos,'Yorigin',ypos,'Zstep',zstep);