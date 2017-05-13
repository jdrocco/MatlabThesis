%Move colloids.  Note: massless!

% This will be imported from experimental data

APstepsize=2.6;  %what is the number of seconds per unit of imported data

figure; hold on;
map=colormap;

koffvec=logspace(-4,-1,8);

for koffind=1:8
    
koff=koffvec(koffind);    
beta=2;    
fracfree=1/beta; 
% koff=(1/80);  % we assume that the correlation time is about 80 s, with weak binding approx
kon=(1/100);
densityofbindsites=round((beta-1)*(koff/kon));

indepbindrate=koff/(fracfree/(1-fracfree));

dt=.5;
substratevel=interp1(APstepsize:APstepsize:(APstepsize*size(APvelmumps,2)),mean(APvelmumps,1),dt:dt:(APstepsize*size(APvelmumps,2)),'spline');

%  substratevel=zeros(size(substratevel));

temperature=0;  % Used this nomenclature for compatibility with C&C but really there is a 1/sqrt(dt) dependence
maxparticles=1000;
maxtime=length(substratevel)-2;
creationrate=1000;
creationinterval=1:1;
creationloc=0;
% kon=0.05;
% koff=0.01;
velocities=zeros(1,maxparticles);
positions=zeros(maxtime,maxparticles);
bound=logical(rand(maxparticles,1)>fracfree);
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
    velocities(~bound)=temperature*randn(sum(~bound),1);
    velocities((livenow+1):end)=0;
    
    positions(t+1,:)=positions(t,:)+dt*velocities;
    boundnow(koffind,t+1)=sum(bound&livenow);
end

handles=semilogy(dt:dt:(size(positions,1)*dt),var(positions,[],2),'color',map(ceil(koffind*7.8),:));
varstore(koffind,:)=var(positions,[],2);
% errorbar(1:size(positions,1),mean(positions,2),std(positions,[],2),'color',map(ceil(beta*0.6),:));
end