function [efftemp,tempdrift]=fitind

decifacxtimestep=0.05;
map=colormap;
taumin=10;
taumax=121;
tempdetrange=100:120;
taurange=taumin:taumax;
linearityf=figure;
asymptotef=figure;
[filename,pathname] = uigetfile('*.dat', 'chose a file');
clear thingo actloc S slopery taunow oncey tauold toplotnfitx toplotnfity coeffs
cd(pathname);
curstring=(filename);
S=importdata(curstring);
volfrac=str2num(curstring(7:8));
if(length(curstring)==15)
    current=str2num(curstring(10:11));
else
    current=str2num(curstring(10:12));
end
actloc=S(:,3);
maxxfit=abs(actloc(8));
thingo=S(:,2);
acttaurange=1:(sum(~(S(:,1))));
if(acttaurange<taumax) 
    exit;
end
figure(linearityf); clf; hold on;
tpafind=1;
for k=1:size(S,1)
taunow(k)=sum(~(S(1:k,1)));
if(exist('tauold')&&(~(taunow(k)==tauold))&&(~(mod(tauold,20)))&&(tauold>taumin)&&(tauold<taumax))
    handlevec(tauold)=plot(toplotnfitx,toplotnfity,'+','color',squeeze(map(ceil((tauold-taurange(1)+1)*64/length(taurange)),:)));
    coeffs(tauold,:)=polyfit(toplotnfitx,toplotnfity,1);
	line([0 maxxfit],[coeffs(tauold,2) coeffs(tauold,2)+maxxfit*coeffs(tauold,1)],'color',squeeze(map(ceil((tauold-taurange(1)+1)*64/length(taurange)),:)))
	clear toplotnfitx toplotnfity
	tpafind=1;
end
if((taunow(k)>taumin)&&(taunow(k)<taumax)&&(~(mod(taunow(k),20))))
    if(abs(actloc(k))<maxxfit)
        toplotnfitx(tpafind)=-actloc(k);
        toplotnfity(tpafind)=-thingo(k);
        tpafind=tpafind+1;
%         plot(-actloc(k),-thingo(k),'+','color',squeeze(map(ceil((taunow(k)-taurange(1)+1)*64/length(taurange)),:)))
    end
end
tauold=taunow(k);
end
ylabel('ln[p(J_{\tau})/p(-J_{\tau})]')
xlabel('J_{\tau}')
legend(handlevec(20:20:100),'\tau=1','\tau=2','\tau=3','\tau=4','\tau=5')
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
efftemp=mean(((tempdetrange)'./squeeze(coeffs(tempdetrange,1))));
isasympyet=polyfit(tempdetrange',(decifacxtimestep*(tempdetrange)'./squeeze(coeffs(tempdetrange,1))),1);
tempdrift=isasympyet(1);