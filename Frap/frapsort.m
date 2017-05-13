% This function will take an MxN matrix of frap intensities along
% with corresponding radii of bleaching regions in a vector of 
% length M, and take the mean intensity over the regions of size
% within a specified tolerance (10%)
%
% [intensvec,meanrad]=frapsort(intensin,regradius)

function [intensvec,meanrad,intensstd]=frapsort(intensus,regradin)

tolerance=0.1;

[regradius,lut]=sort(regradin);
intensin=intensus(lut,:);

counter=0;
for i=2:length(regradius)
    if(~(abs(regradius(i)/regradius(i-1)-1)<tolerance))
        counter=counter+1;
        breakind(counter)=i-1;
    end
end
breakind(counter+1)=length(regradius);

for i=1:length(breakind)
    if(i==1)
        meanrad(i)=mean(regradius(1:breakind(i)));
        intensvec(i,:)=mean(intensin(1:breakind(i),:),1);
        intensstd(i,:)=std(intensin(1:breakind(i),:),[],1);
    else
        meanrad(i)=mean(regradius((breakind(i-1)+1):breakind(i)));
        intensvec(i,:)=mean(intensin((breakind(i-1)+1):breakind(i),:),1);
        intensstd(i,:)=std(intensin((breakind(i-1)+1):breakind(i),:),[],1);
    end
end