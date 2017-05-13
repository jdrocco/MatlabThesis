function [finalprof,profstore]=withdegprof(matrate,diffconst,initconc,prodvec,degrate)

% matrate=.1;
% diffconst=.2;
% initconc=zeros(1,100);
% prodvec=ones(1,200);
tottime=length(prodvec);
for tdiff=1:tottime
    try
    sourceprof(:,tdiff)=erfc(sqrt(((.5:1:length(initconc)).^2)/(4*diffconst*tdiff)));
    catch
        keyboard
    end
    sourceprof(:,tdiff)=sourceprof(:,tdiff)'+erfc(sqrt((((2*length(initconc)-.5):-1:(length(initconc)+.5)).^2)/(4*diffconst*tdiff)));
    maturedfrac(tdiff)=1-exp(-tdiff*matrate);
    undegfrac(tdiff)=exp(-tdiff*degrate);
end

finalprof=initconc;
profstore=zeros(tottime-1,length(initconc));
for time=1:(tottime-1)
    finalprof=finalprof+(prodvec(time)*sourceprof(:,tottime-time)*maturedfrac(tottime-time)*undegfrac(tottime-time))';
    profstore(time,:)=finalprof;
end