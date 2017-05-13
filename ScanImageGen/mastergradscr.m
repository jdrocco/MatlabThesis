function mastergradscr(strmatname)

load(strmatname);
outmatname=strcat(strmatname,'grad');
depuse=4;
cropfrac=.1;
for i=1:length(embstr)
    if(isempty(embstr(i).CroppedImages))
        continue;
    end
    [normvec,nxi,nyi,nzi,devfromvert]=tangfinder(embstr(i).DepthMask,embstr(i).Xdimreal,embstr(i).Ydimreal,embstr(i).Zstep(1));
    goodang=logical(devfromvert<0.1);
    cropdist=ceil(cropfrac*size(goodang,1));
    goodang(1:cropdist,:)=0;
    goodang((end-cropdist+1):end,:)=0;
    goodang=returnbiggest(goodang);
    gooddep=(embstr(i).DepthMask(goodang'))-1;
    [izz,jzz]=find(goodang'>0);
    maxdepper=floor(min(gooddep))-1;
    intsave=zeros(length(gooddep),maxdepper,size(embstr(i).CroppedImages,1));
    for j=1:length(gooddep)
        di=(gooddep(j)-(maxdepper-1)):gooddep(j);
        exrange=floor(min(di)):ceil(max(di));
        % exrange=max(floor(min(di)),1):min(ceil(max(di)),size(embstr(i).CroppedImages,1));
        try
        intpts=interp1(double(exrange),double(embstr(i).CroppedImages(:,exrange,izz(j),jzz(j))'),double(di));
        catch
            continue;
        end
        intsave(j,:,:)=intpts;
    end
    [gradpts,trash,gradinds]=unique(jzz);
    gradout=nan(size(embstr(i).CroppedImages,4),maxdepper,size(embstr(i).CroppedImages,1));
    for k=1:length(gradpts)
        gradout(gradpts(k),:,:)=squeeze(mean(intsave(gradinds==k,:,:),1));
    end
    try
        storer=gradout(:,(maxdepper-depuse):(maxdepper-1),:);
        gradstr(i)=struct('Gradient',storer,'PixPerMicron',embstr(i).PixPerMicron,'EmbLengthMicrons',embstr(i).EmbLengthMicrons,'ZStep',embstr(i).Zstep,'LocalTimeSec',embstr(i).LocalTimeSec,'Enter14Frame',embstr(i).Enter14Frame);
    catch
        continue;
    end
    save(outmatname,'gradstr');
end