function imcompstruct=concatimstruct(imstruct)

imcompstruct=imstruct(1);
numposes=length(imstruct);
for i=1:numposes
    repinds=(unique(imstruct(i).Timeindex));
    for n=1:length(repinds)
        j=repinds(n);
        findvec=(imstruct(i).Timeindex==j);
        cyclesum(i,j+1)=sum(findvec);
    end
end

cycfinder=find(cyclesum>0);
for n=1:length(cycfinder)
    q=cycfinder(n);
    timeindy=q-1;
    [posnow,localq]=ind2sub(size(cyclesum),q);
    findvec=(imstruct(posnow).Timeindex==(localq-1));
    startingind=sum(cyclesum(1:timeindy))+1;
    endingind=sum(cyclesum(1:q));
    imcompstruct.Images(startingind:endingind,:,:)=imstruct(posnow).Images(findvec,:,:);
    imcompstruct.Timeindex(startingind:endingind)=timeindy;
    imcompstruct.Channel(startingind:endingind)=imstruct(posnow).Channel(findvec);
    imcompstruct.GlobalTimeMin(startingind:endingind)=imstruct(posnow).GlobalTimeMin(findvec);
    imcompstruct.LocalTimeSec(startingind:endingind)=imstruct(posnow).LocalTimeSec(findvec);
end