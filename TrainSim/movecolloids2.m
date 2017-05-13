%Move colloids.  Note: massless!

% This will be imported from experimental data

APstepsize=2.6;  %what is the number of seconds per unit of imported data

beta=50;  % beta is (1+(densityofsites*kon/koff))
koff=(1/80);  % we assume that the correlation time is about 80 s, with weak binding approx
kon=5*koff;
densityofbindsites=round((beta-1)*(koff/kon));
    
dt=0.1;
substratevel=interp1(APstepsize:APstepsize:(APstepsize*size(APvelmumps,2)),mean(APvelmumps,1),dt:dt:(APstepsize*size(APvelmumps,2)),'spline');

temperature=0;
maxparticles=1001;
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
    bound=bound&(rand(size(bound))>koff);

    currpositions=squeeze(positions(t,:));
    % Then decide which particles will bind
    for j=(find(~bound(1:livenow)))'
        occupied=sum((currpositions<(currpositions(j)+bindradius))&(currpositions>(currpositions(j)-bindradius))&bound');
        freefloat=sum((currpositions(1:livenow)<(currpositions(j)+bindradius))&(currpositions(1:livenow)>(currpositions(j)-bindradius))&(~bound(1:livenow))');
        localbindprob=kon*(freefloat/2*bindradius)*max([densityofsites-occupied 0])/densityofsites;
        if (rand(1)<localbindprob)
            bound(j)=1;
        end
    end
        
    
    % First set velocities for particles that are bound
    velocities(logical(bound))=substratevel(t);
    
    % Then set velocities for particles that are not bound
    velocities(~bound)=temperature*randn(sum(~bound),1);
    velocities((livenow+1):end)=0;
    
    positions(t+1,:)=positions(t,:)+dt*velocities;
end

finaldist=positions(end,:);
finalbound=sum(bound);
