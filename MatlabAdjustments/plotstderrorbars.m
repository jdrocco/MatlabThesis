function [xval,yval,stdval]=plotstderrorbars(xdata,ydata,span)

[sortedx,sortinds]=sort(xdata);
clippedend=ceil(span/2);
xval=nan(1,length(xdata));
yval=xval;
stdval=xval;
for i=(1+clippedend):(length(xval)-clippedend)
    xval(i)=sortedx(i);
    yval(i)=mean(ydata(sortinds((i-clippedend):(i+clippedend))));
    stdval(i)=std(ydata(sortinds((i-clippedend):(i+clippedend))));
end
