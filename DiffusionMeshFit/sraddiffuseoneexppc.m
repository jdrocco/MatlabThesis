function [conc,newsum]=sraddiffuseoneexppc(region,maturtimeadj,initconc,diffconst,degconst,prodconst,tf)

% tipconccoeff=sqrt(pi/(4*diffconst*maturtimeadj));

movietime=1000000;
maxsho=250;
lengthz=length(initconc);

prodsum=0.0;
prodbasis=zeros(size(initconc));
    for j=1:lengthz
        prodbasis(j)=erfc(sqrt(j^2)/sqrt(4*diffconst*maturtimeadj));
        prodsum=prodsum+prodbasis(j);
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
origcf=dsqrconc;
newcf=dsqrconc;
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
                   dsqrconc(i,j)=(1/(2*(i-0.5)))*(crplus(i,j)-crminus(i,j))+(crplus(i,j)-2*conc(i,j)+crminus(i,j));
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
           origcf(i,j)=-degconst*conc(i,j)+diffconst*(dsqrconc(i,j)+dsqzconc(i,j))+prodconst*normcoeff*prodbasis(i,j);
           newconc(i,j)=conc(i,j)+origcf(i,j);
       end
    end
    newcrplus=circshift(newconc,[1 0]);
    newcrminus=circshift(newconc,[-1 0]);
    newczplus=circshift(newconc,[0 1]);
    newczminus=circshift(newconc,[0 -1]);
    for i=1:lengthr
       for j=1:lengthz
           if ~region(i,j)
               continue;
           elseif (rrplus(i,j)&&rrminus(i,j))
                   dsqrnewconc(i,j)=(1/(2*(i-0.5)))*(newcrplus(i,j)-newcrminus(i,j))+(newcrplus(i,j)-2*newconc(i,j)+newcrminus(i,j));
           elseif (rrplus(i,j)&&~rrminus(i,j))
                   dsqrnewconc(i,j)=2*(newcrplus(i,j)-newconc(i,j));
           elseif (~rrplus(i,j)&&rrminus(i,j))
                   dsqrnewconc(i,j)=2*(newcrminus(i,j)-newconc(i,j));
           else dsqrnewconc(i,j)=0;                   
           end
           if (rzplus(i,j)&&rzminus(i,j))
                   dsqznewconc(i,j)=newczplus(i,j)-2*newconc(i,j)+newczminus(i,j);
           elseif (rzplus(i,j)&&~rzminus(i,j))
                   dsqznewconc(i,j)=2*(newczplus(i,j)-newconc(i,j));
           elseif (~rzplus(i,j)&&rzminus(i,j))
                   dsqznewconc(i,j)=2*(newczminus(i,j)-newconc(i,j));
           else dsqznewconc(i,j)=0;                   
           end
           newcf(i,j)=-degconst*newconc(i,j)+diffconst*(dsqrnewconc(i,j)+dsqznewconc(i,j))+prodconst*normcoeff*prodbasis(i,j);
       end
    end
    conc=conc+0.5*(origcf+newcf);
    
    newsum(t)=0.0;
    for i=1:size(conc,1)
    for j=1:size(conc,2)
    if(region(i,j))
    newsum(t)=newsum(t)+conc(i,j)*2*pi*(i-0.5);
    end
    end
    end
    
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