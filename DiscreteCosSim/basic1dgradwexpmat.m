maturationtime=3600;
mtcunits=maturationtime/25;
diffconst=1;
initconds=zeros(100,1);
for j=2:51
initconds(j)=25^2-(j-26.5)^2;
end
for j=11:99
initconds(j)=initconds(j)+(45^2-(j-55)^2)/9;
end
totpermtunit=sum(initconds);
realdisco=dct(initconds);
showgrad=figure;
for t=1:300
    laterdisco=realdisco'.*exp(-25*diffconst*t*(pi*(1:100)/100).^2);
    outdisco=idct(laterdisco);
    needtoadd=totpermtunit-sum(outdisco);
    odstore(t,:)=outdisco+(needtoadd/100);
    figure(showgrad); clf;
    rawinverse=zeros(100,1);
    for k=1:t
        rawinverse=rawinverse+(odstore(k,:)*(1-exp(-(t-k)/mtcunits)))';
    end
    plot(rawinverse);
    ylim([0 100000]);
    pause(0.1);
end