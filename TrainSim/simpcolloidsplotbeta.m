%Move colloids.  Note: massless!

% This will be imported from experimental data
function []=simpcolloidsplotbeta(APtrace,time,Dmumps

radius=5*(10^(-9));
mobilconst=3.6*(10^21);
kT=Dmumps/mobilconst;
eta=1/(6*pi*mobilconst*radius);
dt=0.2;
fluctforce=sqrt(2*eta*kT/dt);

bindsitesize=.003; %in microns
nucrad=6.5;
kon=24*bindsitesize*Dmumps/(nucrad^3);

beta=50;    
fracfree=1/beta; 

APvelmumps=diff(APtrace,1,2);
APstepsize=mean(diff(time));  %what is the number of seconds per unit of imported data

figure; hold on;
map=colormap;

koffvec=logspace(-4,0,8);

for koffind=1:8
    
koff=koffvec(koffind);    
% koff=(1/80);  % we assume that the correlation time is about 80 s, with
% weak binding approx
densityofbindsites=round((beta-1)*(koff/kon));

indepbindrate=koff/fracfree;

substratevel=interp1(APstepsize:APstepsize:(APstepsize*size(APvelmumps,2)),mean(APvelmumps,1),dt:dt:(APstepsize*size(APvelmumps,2)),'spline');

maxparticles=1000;
maxtime=length(substratevel)-2;
creationrate=1000;
creationinterval=1:1;
creationloc=0;
% kon=0.05;
% koff=0.01;
positions=zeros(maxtime,maxparticles);
bound=logical(zeros(maxparticles,1));
bindradius=.1;

% First initialize the state variables
livenow=0;

% Now for the runtime loop

for t=1:maxtime
    
    % First introduce the newly created particles
    if(ismember(t,creationinterval))
        livenow=livenow+creationrate;
    end
    
    % Then decide which particles will unbind
%     occupancynew=occupancy&(rand(size(occupancy))>koff);
%     for j=find(occupancy-occupancynew)
%         bound(occupancy(j))=0;
%     end
%     occupancy=occupancynew;
    bound=bound&(rand(size(bound))>(koff*dt));

    currpositions=squeeze(positions(t,:));
    % Then decide which particles will bind
    for j=(find(~bound(1:livenow)))'
        if (rand(1)<(indepbindrate*dt))
            bound(j)=1;
        end
    end
        
    
    % First set velocities for particles that are bound
    velocities(logical(bound))=substratevel(t);
    
    % Then set velocities for particles that are not bound
    velocities(~bound)=fluctforce*randn(sum(~bound),1)/eta;
    velocities((livenow+1):end)=0;
    
    positions(t+1,:)=positions(t,:)+dt*velocities;
    boundnow(koffind,t+1)=sum(bound);
end

semilogy(dt:dt:(size(positions,1)*dt),var(positions,[],2),'color',map(ceil(koffind*7.8),:))
varstore(koffind,:)=var(positions,[],2);
% errorbar(1:size(positions,1),mean(positions,2),std(positions,[],2),'color',map(ceil(beta*0.6),:));
end