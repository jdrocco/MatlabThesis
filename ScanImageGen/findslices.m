function maskerstr=findslices(imstack,toploc,chancontrol,totalslices,abovetoploc)

maskerstr=struct;
lowbound=0.1;
upperbound=1.6;
tolval=0.03;
    
% fudgeranger=1.6:-0.05:0.1;
options=optimset('TolX',tolval);

for i=1:totalslices
    locnow=i+toploc-totalslices+abovetoploc;
    cutoffnow=0.003+(.135*(((totalslices-i+1)^0.35)-1));
    for k=1:size(imstack,1)
        immer=squeeze(imstack(k,locnow,chancontrol,:,:));
%          disp(k); pause(0.01);
        try
            [fudger,fval] = fzero(@slicerfun,[lowbound upperbound],options,immer,cutoffnow);
        catch
            if(slicerfun(upperbound,immer,cutoffnow)>0)
                fudger=upperbound;
                fval=1;
            else
                fudger=lowbound;
                fval=1;
            end
        end
        while(fval<=0)
            fudger=fudger-tolval;
            fval=feval(@slicerfun,fudger,immer,cutoffnow);
        end
        regnow=returnbiggest(detectreg(immer,fudger-tolval));
        maskerstr(i,k).embryo=logical(regnow);
    end
    disp(i); pause(0.01);
end