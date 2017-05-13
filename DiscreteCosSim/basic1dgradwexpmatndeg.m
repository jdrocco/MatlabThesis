maturationtime=2400;
mtcunits=maturationtime/25;
degtime=2900;
dtcunits=degtime/25;
diffconst=.2;
initconds=zeros(100,1);
% for j=2:51
% initconds(j)=25^2-(j-26.5)^2;
% end
% for j=11:99
% initconds(j)=initconds(j)+(45^2-(j-55)^2)/9;
% end
for j=1:45
initconds(j)=23^4-(j-23)^4;
end
totpermtunit=sum(initconds);
realdisco=dct(initconds);
showgrad=figure;
for t=1:400
    laterdisco=realdisco'.*exp(-25*diffconst*t*(pi*(1:100)/100).^2);
    outdisco=idct(laterdisco);
%     needtoadd=totpermtunit-sum(outdisco);
needtoadd=0;
    odstore(t,:)=outdisco+(needtoadd/100);
    figure(showgrad); clf;
    rawinverse=zeros(100,1);
    for k=1:t
        rawinverse=rawinverse+(odstore(k,:)*(1-exp(-(t-k)/mtcunits)))'-(odstore(k,:)*(1-exp(-(t-k)/dtcunits)))';
        % this is for the case that you can be degraded before maturing
%         rawinverse=rawinverse+(odstore(k,:)*(1-exp(-(t-k)/mtcunits))*exp(-(t-k)/dtcunits))';
        % this is for the case that you can only be degraded once mature
    end
    plot(rawinverse);
    ylim([0 10000000]);
    pause(0.1);
end