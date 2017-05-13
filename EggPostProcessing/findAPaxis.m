function [AP_x,AP_y]=findAPaxis(BWemb)

embsob=edge(uint16(BWemb),'canny');
[sobx,soby]=find(embsob);

currmax=0;
for q=1:length(sobx)
    for r=q:length(sobx)
        currdistsq=((sobx(q)-sobx(r))^2+(soby(q)-soby(r))^2);
        if(currdistsq>currmax)
            currr=r;
            currq=q;
            currmax=currdistsq;
        end
    end
end
AP_x=[sobx(currq) sobx(currr)];
AP_y=[soby(currq) soby(currr)];
