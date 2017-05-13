function optdiffmat=fitcomp(gomcompavg,egglcomp,timecomp,avscomp,depth,zsize,maxevals,bgdlvl,trydiffc)

% zsize is the averaging box size
actualems=size(gomcompavg,1);
numtimes=size(gomcompavg,2);

for i=1:actualems
%     gomrsout=realspacegom(gomcompavg(i,:,:),egglcomp(i));
    for firstidx=1:(numtimes-1)
        [optdiffc,bestsqsum,exitflag,output]=fitwbnds(egglcomp(i),firstidx,squeeze(gomcompavg(i,:,:)),timecomp(i,:),squeeze(avscomp(i,:,:)),depth,zsize,trydiffc,maxevals,bgdlvl);
        optdiffmat(i,firstidx)=optdiffc;
        exitmat(i,firstidx)=exitflag;
        countmat(i,firstidx)=output.funcCount;
        summat(i,firstidx)=bestsqsum;
        save diffdump optdiffmat exitmat countmat summat;
    end
end