figure; hold on;
map=colormap;
taustep=0.05;
taumax=110;
taumin=10;
taurange=taumin:taumax;
filesaysbinsize=0.000254;
filesayscurrent=0.36;
decifacxtimestep=0.05;
binsize=filesaysbinsize*filesayscurrent/decifacxtimestep;
result=importdata('gfftlv38c40str',' ');
bindices=str2double(result.textdata(:,2));
negcts=str2double(result.textdata(:,5));
poscts=result.data;
[shouldbezeroneg,firsttailendneg]=min(negcts);
[shouldbezeropos,firsttailendpos]=min(poscts);
if((shouldbezeroneg==0)&&(shouldbezeropos==0))
    integrateupto=max(firsttailendneg,firsttailendpos);
end
probnormer=sum(negcts(1:integrateupto))+sum(poscts(1:integrateupto));
for j=1:size(result.data,1)
    tau(j)=sum(~bindices(1:j));
    taureal(j)=tau(j)*taustep;
    if((tau(j)<taumax)&&(tau(j)>taumin)&&(~(mod(tau(j),20))))
        if(bindices(j)==0)
            handlevechist(tau(j))=semilogy(binsize*(bindices(j)+0.5),tau(j)*poscts(j)/probnormer,'+','color',squeeze(map(ceil((tau(j)-taurange(1)+1)*64/length(taurange)),:)));
        else
            semilogy(binsize*(bindices(j)+0.5),tau(j)*poscts(j)/probnormer,'+','color',squeeze(map(ceil((tau(j)-taurange(1)+1)*64/length(taurange)),:)));
        end
        semilogy(-binsize*(bindices(j)+0.5),tau(j)*negcts(j)/probnormer,'+','color',squeeze(map(ceil((tau(j)-taurange(1)+1)*64/length(taurange)),:)));
    end
end
xlim([-0.1 0.18]);
xlabel('J_{\tau}');
ylabel('p(J_{\tau})');
legend(handlevechist(20:20:100));