function finorthvec=detectoropt(origorthvec,fullsigzmn,refsigzmn,stepsize,iterations)

finorthvec(1,:)=origorthvec;

for i=2:iterations
    finorthvec(i,:)=finorthvec(i-1)-stepsize*(dot(fullsigzmn,refsigzmn+finorthvec(i-1))*(fullsigzmn-dot(fullsigzmn,refsigzmn)*refsigzmn));
end