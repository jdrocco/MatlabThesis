function [squaresum,gradout,realprodconst]=findsquaresum(egglength,initgrad,finalgrad,realtimebtw,avgdskinloc,depth,zthick,realdiffconst,timedilate,realdegconst,realprodconst)

maturationtimesec=900;
% zstep is the actual slice width
% realtimebtw is the time interval in minutes

sourcefrac=sqrt(4*realdiffconst*maturationtimesec)/egglength;
timebtwsec=realtimebtw*60;
% timedilate=100;
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
sourcefracnotfound=1;

for i=1:zlength
    for j=1:maxrad(i)
        region(j,i)=logical(1);
        initconc(j,i)=initgrad(i);
        volfrac=sum(maxrad(1:i).*maxrad(1:i))/sum(maxrad.*maxrad);
        if(sourcefracnotfound&&(volfrac>(sourcefrac)))
            sourcemax=i;
            sourcefracnotfound=0;
        end
    end
end

tf=ceil((timedilate/((egglength/zlength)^2))*timebtwsec);
% sourcemax=round(zlength*realsourcemax/egglength);
diffconst=realdiffconst/timedilate;

if(~exist('realdegconst','var'))
    reldegconst=0;
end

degconst=realdegconst/(timedilate/((egglength/zlength)^2));
maturtimeadj=maturationtimesec*(timedilate/((egglength/zlength)^2));

if(~exist('realprodconst','var'))
    incrperstep=(sum((finalgrad-initgrad).*(pi*maxrad.*maxrad))/(tf-1))+sum(degconst*((finalgrad+initgrad)/2).*(pi*maxrad.*maxrad));
    prodconst=(incrperstep/sum(pi*maxrad(1:sourcemax).*maxrad(1:sourcemax)));
    realprodconst=prodconst*(timedilate/((egglength/zlength)^2));
else
    prodconst=realprodconst/(timedilate/((egglength/zlength)^2));
end

conc=sraddiffusetwo(region,sourcemax,initconc,diffconst,degconst,prodconst,tf);

pdepth=round(abs(depth)*zlength/egglength);
pthick=round(abs(zthick)*zlength/egglength);
squaresum=0.0;

for i=firstnotnan:lastnotnan
    gradout(i)=mean(conc((maxrad(i)-pdepth-pthick):(maxrad(i)-pdepth+pthick),i));
    squaresum=squaresum+((gradout(i)-finalgrad(i))^2);
end