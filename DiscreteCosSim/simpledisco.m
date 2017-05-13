clear saverdisco
load prodplot

meshsize=100;
diffconst=1;  % works out to 7.4 in um^2/s
%prodprof=[1 zeros(1,99)];
prodprof=[linspace(1,0,10)/sum(linspace(1,0,10)) zeros(90,1)'];
%prodplot=ones(1,200);   %uncomment for constprod
%prodprof=[zeros(1,16) 1 zeros(1,83)];
%prodprof=[zeros(1,14) .2 .2 .2 .2 .2 zeros(1,81)];
degconst=0.0005;
kdeg=.03*ones(1,200)/60;
kdeg(144:180)=linspace(.03,.06,37)/60;
kdeg(181:end)=kdeg(180);
%kdeg(1:100)=0;         % uncomment for constprod
writemovietime=600;
initconds=zeros(1,100);


prodprof=[1 zeros(99,1)'];
prodplot=ones(1,200);
kdeg=.2/60*ones(1,200);

disdisco=dct(initconds);
showgrad=figure;
for t=1:12000  %in my units i.e. 1s, 12000 s= 200 min
    laterdisco=disdisco.*exp(-diffconst*((pi*(1:meshsize)/meshsize).^2));
    outdisco=idct(laterdisco);
    outdisco=outdisco+prodprof*prodplot(ceil(t/60));
    degdisco=exp(-kdeg(ceil(t/60)))*outdisco;
    realdisco=degdisco;
    if(~(mod(t,writemovietime)))
        saverdisco(floor(t/writemovietime),:)=realdisco;
    end
    disdisco=dct(realdisco);
end
plot(saverdisco')