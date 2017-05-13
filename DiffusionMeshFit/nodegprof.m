function finalprof=nodegprof(matrate,diffconst,initconc,prodvec)

% matrate=.1;
% diffconst=.2;
% initconc=zeros(1,100);
% prodvec=ones(1,200);
tottime=length(prodvec);
for tdiff=1:tottime
    sourceprof(:,tdiff)=erfc(sqrt(((.5:1:length(initconc)).^2)/(4*diffconst*tdiff)));
    maturedfrac(tdiff)=1-exp(-tdiff*matrate);
end

finalprof=initconc;
for time=1:(tottime-1)
    finalprof=finalprof+(prodvec(time)*sourceprof(:,tottime-time)*maturedfrac(tottime-time))';
end