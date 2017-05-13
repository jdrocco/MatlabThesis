function squaresum=simpsqsumexp(realdiffconst,egglength,initgrad,finalgrad,realtimebtw,avgdskinloc,depth,zthick,funfact)

disp(realdiffconst);
dilatefac=ceil(abs(4*(realdiffconst+1)));
[actsquaresum,gradout,realprodconst]=findsquaresumexp(egglength,initgrad,finalgrad,realtimebtw,avgdskinloc,depth,zthick,realdiffconst,dilatefac,0.0);
squaresum=actsquaresum/funfact;
hold off;
plot(initgrad,'b');
hold on;
plot(finalgrad,'r');
plot(gradout,'g+');