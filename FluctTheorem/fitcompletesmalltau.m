function [efftemp,tempdrift]=fitcompletesmalltau

% Nope, this one doesn't work at all.  For some reason there is something
% special about going to tau=100 to see the asymptotic behavior

files=dir;
decifacxtimestep=0.05;
map=colormap;
taumin=2;
taumax=25;
tempdetrange=20:24;  % cioe the range of taus which will be used to determine the temperature_eff
taurange=taumin:taumax;
linearityf=figure;
asymptotef=figure;
for nowind=3:length(files)
clear thingo actloc S slopery taunow oncey tauold toplotnfitx toplotnfity coeffs
curstring=(files(nowind).name);
S=importdata(curstring);
volfrac=str2num(curstring(7:8));
if(length(curstring)==15)
    current=str2num(curstring(10:11));
else
    current=str2num(curstring(10:12));
end
actloc=S(:,3);   % meaning actual J_t, also known as the "sum neg A not"
maxxfit=abs(actloc(9));   % So in other words this says we want to fit all J_t less than the greatest of the first 9 points. HOWEVER, unhandled exception if less than 9 points total for first tau
if(~(sum(~S(1:9,1))==1))   % So we insert this check
    continue;
end
thingo=S(:,2);   % meaning lognegposrat
acttaurange=1:(sum(~(S(:,1))));
if(acttaurange<taumax)    % Now we also make sure there are at least enough taus to get to our taumax
    continue;
end
figure(linearityf); clf; hold on;
tpafind=1;
for k=1:size(S,1)
taunow(k)=sum(~(S(1:k,1)));
if(exist('tauold')&&(~(taunow(k)==tauold))&&(~(mod(tauold,4)))&&(tauold>taumin)&&(tauold<taumax))
    handlevec(tauold)=plot(toplotnfitx,toplotnfity,'+','color',squeeze(map(ceil((tauold-taurange(1)+1)*64/length(taurange)),:)));
    coeffs(tauold,:)=polyfit(toplotnfitx,toplotnfity,1);
	line([0 maxxfit],[coeffs(tauold,2) coeffs(tauold,2)+maxxfit*coeffs(tauold,1)],'color',squeeze(map(ceil((tauold-taurange(1)+1)*64/length(taurange)),:)))
	clear toplotnfitx toplotnfity
	tpafind=1;
end
if((taunow(k)>taumin)&&(taunow(k)<taumax)&&(~(mod(taunow(k),4))))
    if(abs(actloc(k))<maxxfit)
        toplotnfitx(tpafind)=actloc(k);  % negative actloc for nuala (galilean data), positive for brian (non-trasformed data)
        toplotnfity(tpafind)=-thingo(k);  
        tpafind=tpafind+1;
%         plot(-actloc(k),-thingo(k),'+','color',squeeze(map(ceil((taunow(k)-taurange(1)+1)*64/length(taurange)),:)))
    end
end
tauold=taunow(k);
end
ylabel('ln[p(J_{\tau})/p(-J_{\tau})]')
xlabel('J_{\tau}')
legend(handlevec(4:4:20),'\tau=1','\tau=2','\tau=3','\tau=4','\tau=5')
clear tauold
tpafind=1;
for k=1:size(S,1)
taunow(k)=sum(~(S(1:k,1)));
if((taunow(k)>taumin)&&(taunow(k)<taumax)&&(~(mod(taunow(k),1))))
    if(exist('tauold'))
        if(~(taunow(k)==tauold))
%               plot(toplotnfitx,toplotnfity,'+','color',squeeze(map(ceil((tauold-taurange(1)+1)*64/length(taurange)),:)))
              coeffs(tauold,:)=polyfit(toplotnfitx,toplotnfity,1);
%               line([0 maxxfit],[coeffs(tauold,2) coeffs(tauold,2)+maxxfit*coeffs(tauold,1)],'color',squeeze(map(ceil((tauold-taurange(1)+1)*64/length(taurange)),:)))
              clear toplotnfitx toplotnfity
              tpafind=1;
        end
    end
    if(abs(actloc(k))<maxxfit)
        toplotnfitx(tpafind)=-actloc(k);
        toplotnfity(tpafind)=-thingo(k);
        tpafind=tpafind+1;
%         plot(-actloc(k),-thingo(k),'+','color',squeeze(map(ceil((taunow(k)-taurange(1)+1)*64/length(taurange)),:)))
    end
    tauold=taunow(k);
end
end
figure(asymptotef); clf; hold on; 
plot((taumin:(taumax-2))*decifacxtimestep,((taumin:(taumax-2))'./squeeze(coeffs(taumin:(taumax-2),1))))
xlabel('\tau'); ylabel('\tau/S_{\tau}');
figure(linearityf);
efftemp(volfrac,current)=mean(((tempdetrange)'./squeeze(coeffs(tempdetrange,1))));
isasympyet=polyfit(tempdetrange',(decifacxtimestep*(tempdetrange)'./squeeze(coeffs(tempdetrange,1))),1);
tempdrift(volfrac,current)=isasympyet(1);
end