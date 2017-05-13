function conc=sraddiffusetwoexp(region,maturtimeadj,initconc,diffconst,degconst,prodconst,tf)

% tipconccoeff=sqrt(pi/(4*diffconst*maturtimeadj));

movietime=1000000;
maxsho=250;
lengthr=size(initconc,1);
lengthz=size(initconc,2);

prodsum=0.0;
prodbasis=zeros(size(initconc));
for i=1:lengthr
    for j=1:lengthz
        if(region(i,j))
            prodbasis(i,j)=erfc(sqrt(i^2+j^2)/sqrt(4*diffconst*maturtimeadj));
            prodsum=prodsum+2*pi*prodbasis(i,j)*(i-0.5);
        end
    end
end
normcoeff=1/prodsum;

rrplus=circshift(region,[1 0]);
rrminus=circshift(region,[-1 0]);
rzplus=circshift(region,[0 1]);
rzminus=circshift(region,[0 -1]);

dsqrconc=zeros(lengthr,lengthz);
dsqzconc=dsqrconc;
conc=initconc;
newconc=conc;
t=1;
while t<tf
    crplus=circshift(conc,[1 0]);
    crminus=circshift(conc,[-1 0]);
    czplus=circshift(conc,[0 1]);
    czminus=circshift(conc,[0 -1]);
    for i=1:lengthr
       for j=1:lengthz
           if ~region(i,j)
               continue;
           elseif (rrplus(i,j)&&rrminus(i,j))
                   dsqrconc(i,j)=(1/(2*i))*(crplus(i,j)-crminus(i,j))+(crplus(i,j)-2*conc(i,j)+crminus(i,j));
           elseif (rrplus(i,j)&&~rrminus(i,j))
                   dsqrconc(i,j)=2*(crplus(i,j)-conc(i,j));
           elseif (~rrplus(i,j)&&rrminus(i,j))
                   dsqrconc(i,j)=2*(crminus(i,j)-conc(i,j));
           else dsqrconc(i,j)=0;                   
           end
           if (rzplus(i,j)&&rzminus(i,j))
                   dsqzconc(i,j)=czplus(i,j)-2*conc(i,j)+czminus(i,j);
           elseif (rzplus(i,j)&&~rzminus(i,j))
                   dsqzconc(i,j)=2*(czplus(i,j)-conc(i,j));
           elseif (~rzplus(i,j)&&rzminus(i,j))
                   dsqzconc(i,j)=2*(czminus(i,j)-conc(i,j));
           else dsqzconc(i,j)=0;                   
           end
           newconc(i,j)=(1-degconst)*conc(i,j)+diffconst*(dsqrconc(i,j)+dsqzconc(i,j))+prodconst*normcoeff*prodbasis(i,j);
       end
    end
    conc=newconc;
    t=t+1;
    if(mod(t,movietime)==0)
        imfordisp=conc;
        imfordisp(imfordisp>maxsho)=maxsho;
        imfordisp(end,end)=maxsho;
        imagesc(squeeze(imfordisp));
        colorbar;
        pause(0.01);
    end
end
donnow=1;