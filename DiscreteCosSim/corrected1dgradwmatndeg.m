
for matind=10
maturationtime=1400+(matind*400);
% maturationtime=3600;
mtcunits=maturationtime/25;
matalpha=1;
% Have to use 25 because our units are 5 mum and 25 s to make d const
degtime=4500;
dtcunits=degtime/25;
degalpha=1;
for diffind=6
    diffconst=0.2+(0.4*diffind);
% diffconst=1;
initconds=zeros(100,1);
for j=2:11
initconds(j)=5^2-(j-6.5)^2;
end
% for j=11:99
% initconds(j)=initconds(j)+(45^2-(j-55)^2)/9;
% end
% for j=1:100
% initconds(j)=initconds(j)-100*(j-50)^2;
% end
totpermtunit=sum(initconds);
realdisco=dct(initconds);
showgrad=figure;
odstore=zeros(400,100);
for t=1:276  %in my units i.e. 25s ,  400*25=10000 s = about 2 h 50 min
    laterdisco=realdisco'.*exp(-diffconst*t*((pi*(1:100)/100).^2));
    outdisco=idct(laterdisco);
    outdiscosave(t,:)=idct(laterdisco);
    needtomult(t)=1+((totpermtunit-sum(outdisco))/sum(outdisco));
    odstore(t,:)=outdisco*(needtomult(t));
%     figure(showgrad); clf;
    rawinverse=zeros(100,1);
    recinverse=zeros(100,1);
    for k=1:t % k is AGE
        rawinverse=rawinverse+(odstore(k,:)*(gamcdf(k,matalpha,mtcunits))*(1-gamcdf(k,degalpha,dtcunits)))';
        % probability it has already matured (CDF for mat) but not yet
        % degraded (1-CDF for deg), which are independent so P=P1*P2
        % this is for the case that you can be degraded before maturing
%         rawinverse=rawinverse+(odstore(k,:)*(1-exp(-(k)/mtcunits))*exp(-(k)/dtcunits))';
        % this is for the case that you can only be degraded once mature
    end
    ristore(t,:)=rawinverse;
%     for k=1:45   % 45 chosen for 20 min recovery
%         recinverse=recinverse+(odstore(k,:)*(gamcdf(k,matalpha,mtcunits))*(1-gamcdf(k,degalpha,dtcunits)))';
%         % this is for the case that you can be degraded before maturing
% %         recinverse=recinverse+(odstore(k,:)*(1-exp(-(k)/mtcunits))*exp(-(k)/dtcunits))';
%         % this is for the case that you can only be degraded once mature
%     end
%     recstore(t,:)=recinverse;

    plot(rawinverse);
    ylim([0 1000]);
    pause(0.01);
    if(275==t)      
        rawtomult=1+((sum(ristore(45,:))-sum(rawinverse))/sum(rawinverse));
        rawout=rawtomult*rawinverse;
        ratioplay=(ristore(45,:))./rawout';
    end
end
ratiostore(matind,diffind,:)=ratioplay;
chisqout(matind,diffind)=sum((ratioplay(2:68)-standratplay(2:68)).^2);
end
end