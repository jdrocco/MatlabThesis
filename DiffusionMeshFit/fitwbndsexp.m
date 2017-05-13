function [optdiffc,bestsqsum,exitflag,output]=fitwbndsexp(egglength,firstidx,gradoutmult,time,avgdskinloc,depth,zsize,trydiffc,maxevals,bgdlvl)

initgrad=gradoutmult(firstidx,:)-bgdlvl;
finalgrad=gradoutmult(firstidx+1,:)-bgdlvl;
realtimebtw=time(firstidx+1)-time(firstidx);
zthick=zsize;

if(~exist('trydiffc'))
    trydiffc=14;
end
if(~exist('maxevals'))
    maxevals=25;
end

options = optimset('Display','iter','TolX',0.1,'MaxFunEvals',maxevals);
diffc=trydiffc;
funfact=10000;
[optdiffc,bestsqsum,exitflag,output] = fminbnd(@(diffc) simpsqsumexp(diffc,egglength,initgrad,finalgrad,realtimebtw,avgdskinloc,depth,zthick,funfact),0,40,options)
disp(optdiffc)