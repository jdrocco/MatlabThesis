function [squaresum,gradout,realprodconst]=findsquaresumexp(egglength,initgrad,finalgrad,realtimebtw,avgdskinloc,depth,zthick,realdiffconst,dilatefac,realdegconst,realprodconst)

maturationtimesec=900;
% zstep is the actual slice width
% realtimebtw is the time interval in minutes

timebtwsec=realtimebtw*60;
% dilatefac=100;
meanskin=mean(avgdskinloc,1);
% rsize=ceil(abs(zstep*max(max(abs(meanskin)))));
rsize=ceil(max(abs(meanskin)));
zlength=size(initgrad,2);
rlength=round(rsize*(zlength/egglength));
region=logical(zeros(rlength+1,zlength+1));
initconc=zeros(rlength+1,zlength+1);

[initgrad,firstnotnani,lastnotnani]=fixgrad(initgrad);
[finalgrad,firstnotnanf,lastnotnanf]=fixgrad(finalgrad);
firstnotnan=max([firstnotnani firstnotnanf]);
lastnotnan=min([lastnotnani lastnotnanf]);
maxrad=ceil(abs(meanskin)*(zlength/egglength));

for i=1:zlength
    for j=1:maxrad(i)
        region(j,i)=logical(1);
        initconc(j,i)=initgrad(i);
    end
end

tf=ceil((dilatefac/((egglength/zlength)^2))*timebtwsec);
% sourcemax=round(zlength*realsourcemax/egglength);
diffconst=realdiffconst/dilatefac;

if(~exist('realdegconst','var'))
    reldegconst=0;
end

degconst=realdegconst/(dilatefac/((egglength/zlength)^2));
maturtimeadj=maturationtimesec*(dilatefac/((egglength/zlength)^2));

if(~exist('realprodconst','var'))
    incrperstep=(sum((finalgrad-initgrad).*(pi*maxrad.*maxrad))/(tf-1))+sum(degconst*((finalgrad+initgrad)/2).*(pi*maxrad.*maxrad));
    prodconst=incrperstep;
    realprodconst=prodconst*(dilatefac/((egglength/zlength)^2));
else
    prodconst=realprodconst/(dilatefac/((egglength/zlength)^2));
end

[conc,newsum]=sraddiffusetwoexppc(region,maturtimeadj,initconc,diffconst,degconst,0,tf);
artifactualincr=newsum(end)-newsum(1);
corrprodconst=prodconst-(artifactualincr/(tf-1));
[conc,newsum]=sraddiffusetwoexppc(region,maturtimeadj,initconc,diffconst,degconst,corrprodconst,tf);
% [conc,newsum]=sraddiffusetwoexppc(region,maturtimeadj,initconc,diffconst,degconst,prodconst,tf);

pdepth=round(abs(depth)*zlength/egglength);
pthick=round(abs(zthick)*zlength/egglength);
squaresum=0.0;

for i=firstnotnan:lastnotnan
    gradout(i)=mean(conc(max(1,(maxrad(i)-pdepth-pthick)):(maxrad(i)-pdepth+pthick),i));
    squaresum=squaresum+((gradout(i)-finalgrad(i))^2);
end