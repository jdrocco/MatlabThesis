function concnew=ftcskernel(concnow,stabdiff)

    %noflux
    concnow(1)=concnow(2);
    concnow(end)=concnow(end-1);
    
    %delsqcalc
    cxplus=circshift(concnow,1);
    cxminus=circshift(concnow,-1);
    delsqc=cxplus+cxminus-2*concnow;
    
    %diffcalc
    concnew=concnow+stabdiff*delsqc;