%
% Crestdeep calculates the zstack at each axbox now that crestskin is
% reserved solely for calculating the skin location.
% Within crestmult tree

function stacker=crestdeep(timesinseries,imagesc1,pxsize,pysize,axboxes,AP_x,AP_y,uncreated)

for i=1:timesinseries
pAP_x=int16(AP_x(i,:));
pAP_y=int16(AP_y(i,:));

origselector=zeros(size(imagesc1,3),size(imagesc1,4));
origselector((round(mean(pAP_x))-abs(pxsize)):(round(mean(pAP_x))+abs(pxsize)),((round(mean(pAP_y))-pysize):(round(mean(pAP_y))+pysize)))=1;

for j=1:axboxes
    selector=circshift(origselector,[round((AP_x(i,2)-AP_x(i,1))*(j-((1+axboxes)/2))/axboxes) round((AP_y(i,2)-AP_y(i,1))*(j-((1+axboxes)/2))/axboxes)]);
    selector=selector.*squeeze(uncreated(i,:,:));
    stacker(i,j,:)=mean(imagesc1(i,:,logical(selector)),3);
end
end
