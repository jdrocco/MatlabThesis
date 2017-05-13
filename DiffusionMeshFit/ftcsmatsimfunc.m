function gradoutery=ftcsmatsimfunc(kaddery,mattime,diffconst,timetouse)

meshsize=200;
timelength=200; %in min
writemovietime=2;

%const prod
prodplot=ones(1,200);
kdeg=[zeros(1,100) .02*ones(1,40) linspace(.02,.06,40) .06*ones(1,20)];

%deg we believe constant from fert
load /media/Yukawa/DronpaLifetime/812/Experiment_8minall/kpwebelieve

% deg zero until we observe it
%load kpzerobefore

%diffconst=4;  %in um2/s
stabdiff=.4;   % this is the computational diff const, must be less than .5
timesteps=diffconst*timelength*60/(stabdiff*(500/meshsize)^2);
initconc=zeros(meshsize+2,1);
%prodprof=[0 linspace(0,1,ceil(meshsize/14)) linspace(1,0,ceil(meshsize/5)) zeros(73,1)']'; %where we make it

load /media/Yukawa/DronpaLifetime/812/Experiment_8minall/newprodprof200
%load /media/Yukawa/DronpaLifetime/1111/shawnprodprof200
%newprodprof200=shawnprodprof200';

prodprof=[0; newprodprof200(3:1:(length(newprodprof200)-1)); 0; 0; 0; 0];
%prodprof=[0 linspace(1,0,28) zeros(73,1)']';
%prodprof=[0 ones(8,1)' linspace(1,0,ceil(meshsize/5)) zeros(73,1)']'; %where we make it

%kdeg=kdeg+.005;
kmat=1/mattime;

kadd=[zeros(1,89) kaddery*ones(1,111)];

% %test of expprof - checked on AA 11/16
%prodprof=[0 1 zeros(100,1)']';
%kdeg=.05*ones(180,1);

writemoviesteps=ceil(writemovietime*timesteps/timelength);
immconcnow=initconc;
matconcnow=initconc;

for t=1:timesteps
    %prod
    immconcnow=immconcnow+prodprof*prodplot(ceil(t*timelength/timesteps));
    
    immconcnow=ftcskernel(immconcnow,stabdiff);
    
    %deg
    immconcnow=immconcnow*exp(-kdeg(ceil(t*timelength/timesteps))*timelength/timesteps);
    
    immconcnow=immconcnow*exp(-kmat*timelength/timesteps);

    matconcnow=matconcnow+immconcnow*(1-exp(-kmat*timelength/timesteps));
    
    matconcnow=ftcskernel(matconcnow,stabdiff);
    
    matconcnow=matconcnow*exp(-(kdeg(ceil(t*timelength/timesteps))+kadd(ceil(t*timelength/timesteps)))*timelength/timesteps);
    
    if(~mod(t,writemoviesteps))
        immconcsave(t/writemoviesteps,:)=immconcnow(2:(end-1));
        matconcsave(t/writemoviesteps,:)=matconcnow(2:(end-1));
    end
end

gradoutery=squeeze(matconcsave(ceil(timetouse/writemovietime),:));