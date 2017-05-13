function [kout,success]=degnewton(qdft,qdfzero,timeint,qfzero,phivec,dtmin,kguess,tolerance,maxit)

if(~exist('kguess'))
    kguess=0.1;
end

if(~exist('tolerance'))
    tolerance=0.0001;
end

if(~exist('maxit'))
    maxit=50;
end

i=0;
success=0;
ktry=kguess;
kout=nan;

while((i<maxit)&&(~success))
    i=i+1;
    for j=1:length(phivec)
        intvec(j)=exp((j-0.5)*dtmin*ktry)*phivec(j)*dtmin/qfzero;
        dintvec(j)=(1-((j-0.5)*dtmin/timeint))*exp((j-0.5)*dtmin*ktry)*phivec(j)*dtmin/qfzero;
    end
    fk=(qdft/qdfzero)-(exp(-ktry*timeint))*(1+sum(intvec));
    dfk=timeint*exp(-ktry*timeint)*(1+sum(dintvec));
    ktryold=ktry;
    ksave(i)=ktry;
    ktry=ktryold-(fk/dfk);
    if(abs(fk/dfk)<tolerance)
        kout=ktry;
        success=1;
    end
end
    
