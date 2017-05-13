function optdiffmat=fitmult(filenamelist,lastgoodlist,maxevals,bgdlvl,trydiffc)

for i=1:size(filenamelist,1)
    load(filenamelist(i,:));
    for firstidx=1:(lastgoodlist(i)-1)
        [optdiffc,bestsqsum,exitflag,output]=fitwbnds(zstep,egglength,firstidx,gradoutmult,time,avgdskinloc,depth,zsize,trydiffc,maxevals,bgdlvl);
        optdiffmat(i,firstidx)=optdiffc;
        exitmat(i,firstidx)=exitflag;
        countmat(i,firstidx)=output.funcCount;
        summat(i,firstidx)=bestsqsum;
        save diffdump optdiffmat exitmat countmat summat;
    end
end