function output=slicerfun(fudger,immer,cutoffnow)

regnow=returnbiggest(detectreg(immer,fudger));
regnow=logical(regnow);
fracnow=sum(regnow(:))/(size(regnow,1)*size(regnow,2));

output=fracnow-cutoffnow;