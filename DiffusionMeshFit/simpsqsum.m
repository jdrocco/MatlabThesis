function squaresum=simpsqsum(realdiffconst,egglength,initgrad,finalgrad,realtimebtw,avgdskinloc,depth,zthick,funfact)

disp(realdiffconst);
timedilate=ceil(abs(4*(realdiffconst+1)));
[actsquaresum,gradout,realprodconst]=findsquaresum(egglength,initgrad,finalgrad,realtimebtw,avgdskinloc,depth,zthick,realdiffconst,timedilate,0.0);
squaresum=actsquaresum/funfact;
hold off;
plot(initgrad,'b');
hold on;
plot(finalgrad,'r');
plot(gradout,'g+');