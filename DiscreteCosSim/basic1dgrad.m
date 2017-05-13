maturationtime=3600;
mtcunits=maturationtime/25;
% Of course, this does not factor in maturation time as a exponential
% process.
diffconst=0.4;
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
    odstore(t,:)=outdisco;
    figure(showgrad); clf;
    if((t-mtcunits)>=1)
        rawinverse=sum(odstore(1:(t-mtcunits),:),1);
        needtoadd=(totpermtunit*(t-mtcunits))-sum(rawinverse);
        plot(rawinverse+(needtoadd/100));
        ylim([0 100000]);
        pause(0.1);
    end
end