meshsize=100;
timelength=200; %in min
writemovietime=10;

%const prod
prodplot=ones(1,200);
kdeg=[zeros(1,100) .02*ones(1,40) linspace(.02,.06,40) .06*ones(1,20)];

%deg we believe constant from fert
%load kpwebelieve

% deg zero until we observe it
load kpzerobefore

diffconst=4.4;  %in um2/s
stabdiff=.4;   % this is the computational diff const, must be less than .5
timesteps=diffconst*timelength*60/(stabdiff*(500/meshsize)^2);
initconc=zeros(meshsize+2,1);
prodprof=[0 linspace(0,1,meshsize/10) linspace(1,0,meshsize/10) zeros(1+8*meshsize/10,1)']'; %where we make it

% %test of expprof - checked on AA 11/16
%prodprof=[0 1 zeros(100,1)']';
%kdeg=.05*ones(180,1);

writemoviesteps=ceil(writemovietime*timesteps/timelength);
concnow=initconc;

for t=1:timesteps
    %prod
    concnow=concnow+prodprof*prodplot(ceil(t*timelength/timesteps));
    
    %noflux
    concnow(1)=concnow(2);
    concnow(end)=concnow(end-1);
    
    %delsqcalc
    cxplus=circshift(concnow,1);
    cxminus=circshift(concnow,-1);
    delsqc=cxplus+cxminus-2*concnow;
    
    %diffcalc
    concnow=concnow+stabdiff*delsqc;
    
    %deg
    concnow=concnow*exp(-kdeg(ceil(t*timelength/timesteps))*timelength/timesteps);
    
    if(~mod(t,writemoviesteps))
        concsave(t/writemoviesteps,:)=concnow(2:(end-1));
    end
end