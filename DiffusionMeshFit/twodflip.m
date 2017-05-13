function [conc,imsaver]=twodflip(initconc,bleachprof,diffconst,degconst,prodconst,tf,movietime,numbleaches)

%movietime=100;
%maxsho=250;
lengthr=length(initconc)+2;

dsqrconc=zeros(lengthr,1);
conc=[initconc(1) initconc initconc(end)];
t=1;
counter=0;
while t<tf
    crplus=circshift(conc,[0 1]);
    crminus=circshift(conc,[0 -1]);
    for i=1:lengthr
        dsqrconc(i)=(1/(2*(i-1.5)))*(crminus(i)-crplus(i))+(crplus(i)-2*conc(i)+crminus(i));                 
        conc(i)=(1-degconst)*conc(i)+diffconst*dsqrconc(i);
        conc(i)=conc(i)+prodconst;
    end
    if(mod(t-1,(tf/numbleaches))==0)
    conc(2:(end-1))=conc(2:(end-1)).*bleachprof;
    end
    conc(1)=conc(2);
    conc(end)=conc(end-1);
    t=t+1;
    if(mod(t,movietime)==0)
        counter=counter+1;
        imfordisp=conc(2:(end-1));
        %imfordisp(imfordisp>maxsho)=maxsho;
        %imfordisp(end)=maxsho;
        imsaver(counter,:)=imfordisp;
    end
end