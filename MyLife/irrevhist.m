function lograt=irrevhist(converted,recovered,time)
figure;

instantratio=recovered(2:end)./converted(1:(end-1));  %Ratio of amount remaining, as close to "instantaneous" as possible.
%Should be distributed around 1 if the measurement is completely reversible and the quantity does not 
%change between single series
timedelta=time(2)-time(1);

loginstrat=log(instantratio(instantratio>0));
[lfreqs,lbars]=hist(loginstrat(:),10);
subplot(2,1,1); bar(lbars,lfreqs,'k'); xlabel(strcat('log(Q_{t+\delta}/Q_{t})  \delta= ',sprintf('%1.2f min',timedelta)));
title('Consecutive measurements');

maxlags=25;
for k=1:maxlags
    ratioforlag=zeros(1,length(recovered)-k);
    for i=1:(length(recovered)-k)
        ratioforlag(i)=recovered(i+k)/converted(i);
    end
    lograt=log(ratioforlag);
    meanvallrat(k)=mean(lograt(:));
    stddevlrat(k)=std(lograt(:));
end
subplot(2,1,2);
errorbar(timedelta:timedelta:(timedelta*maxlags),meanvallrat,stddevlrat,'k+');
xlabel('lag time \Delta (min)   \Delta=N\delta'); ylabel('log(Q_{t+\Delta}/Q_{t})');
