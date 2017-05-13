% Takes an image time series and returns AP axis calling
% a user response in the meanwhile

function [AP_x,AP_y]=crestaxes(imchan1,timesinseries)

if(~exist('timesinseries'))
    timesinseries=size(imchan1,1);
end

AP_x=zeros(timesinseries,2);
AP_y=AP_x;
[AP_y(1,:),AP_x(1,:)]=getapaxisj(squeeze(imchan1(1,1,:,:)));
lastaxis=1;
origintenstop=mean(mean(imchan1(1,1,round(AP_x(1,1)-3):round(AP_x(1,1)+3),round(AP_y(1,1)-3):round(AP_y(1,1)+3))));
origintensbot=mean(mean(imchan1(1,1,round(AP_x(1,2)-3):round(AP_x(1,2)+3),round(AP_y(1,2)-3):round(AP_y(1,2)+3))));

for j=2:timesinseries
    m=0;
    currintenstop=mean(mean(imchan1(j,1,round(AP_x(lastaxis,1)-3):round(AP_x(lastaxis,1)+3),round(AP_y(lastaxis,1)-3):round(AP_y(lastaxis,1)+3))));
    currintensbot=mean(mean(imchan1(j,1,round(AP_x(lastaxis,2)-3):round(AP_x(lastaxis,2)+3),round(AP_y(lastaxis,2)-3):round(AP_y(lastaxis,2)+3))));
    if((abs(currintenstop-origintenstop)+abs(currintensbot-origintensbot))>(0.5*(origintenstop+origintensbot)))
        clf;
        imagesc(squeeze(imchan1(j,1,:,:)));axis equal;axis tight
        line(AP_y(lastaxis,:),AP_x(lastaxis,:))
        m=menu('Accept last axis for this image?','Yes','No');
    end
    if(m==2)
        [AP_y(j,:),AP_x(j,:)]=getapaxisj(squeeze(imchan1(j,1,:,:)));
        lastaxis=j;
        origintenstop=currintenstop;
    else
        AP_x(j,:)=AP_x(lastaxis,:);
        AP_y(j,:)=AP_y(lastaxis,:);
    end
end
