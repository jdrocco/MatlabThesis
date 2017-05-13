% This function will compute masks for Dronpa lifetime experiment.
% [maskstruct2,transim,fluorim]=makemaskstruct(imstruct)

function [maskstruct2,transim,fluorim,imstruct]=makemaskstruct(imstruct,stages)

% Hardwiring for 1/20/10 experiments
fluorinds=[1 3 5 7 10 12 14 16 18 20 22 24];
transinds=[2 4 6 8 11 13 15 17 19 21 23 25];
saveinds=[1 3 5 7 10 12 14 16 18 20 22 24 9 4 6 17 19];
uvind=9;
sesize=20;

blaststage=find((stages<95),1,'last');

if(isempty(blaststage))
    disp('Bad stage matrix')
    return;
end

numchans=(max(imstruct.Channel)-min(imstruct.Channel)+1);
numtimes=(max(imstruct.Timeindex)-min(imstruct.Timeindex)+1);

finderchan=zeros(numchans,numtimes);
for j=1:numchans
    findernow=find(imstruct(1).Channel==(j-1));
    if(~isempty(findernow))
        finderchan(j,:)=findernow;
    end
end

for i=1:numtimes
    fluorina=finderchan(fluorinds,i);
    transina=finderchan(transinds(transinds<=numchans),i);
    uvina=finderchan(uvind,i);
   
    fluormean=squeeze(mean(double(imstruct.Images(fluorina,:,:)),1));
    transmean=squeeze(mean(double(imstruct.Images(transina(transina>0),:,:)),1));
 
    if(i==1)
        fluorim=zeros(numtimes,size(fluormean,1),size(fluormean,2));
        transim=zeros(numtimes,size(transmean,1),size(transmean,2));
    end
    
    fluorim(i,:,:)=fluormean;
    transim(i,:,:)=transmean;

    maskholder=makeembmask(fluormean,transmean,squeeze(double(imstruct.Images(uvina,:,:))));
    if(~isempty(maskholder))
        maskstruct(i)=maskholder;
    else
        numtimes=i-1;
        break;
    end
end

if(~exist('maskstruct','var'))
    maskstruct2=[];
    return
end

    maskstruct=refinemaskstruct(maskstruct);

for j=1:length(maskstruct)
    maskstruct2(j)=genauxmasks(maskstruct(j));        
end

maskstruct=maskstruct2;
clear maskstruct2

% Now we will shamelessly call the side with higher fluorescence intensity the anterior. 
% We will override the location given for the spermtip from the elimsperm
% routine and pass that to findantwsperm
    % Use the images with good masks to do this.
    goodvec=false(length(maskstruct));
    for j=1:length(maskstruct)
        goodvec(j)=maskstruct(j).goodmask;
    end
    if(~isempty(find(goodvec,1,'first')))
        firstgood=find(goodvec,1,'first');
        lastgood=find(goodvec,1,'last');
    else
        firstgood=1;
        lastgood=1;
    end
    nucuse=returnbiggest(maskstruct(ceil(mean([firstgood lastgood]))).nuclear);
    intenspro=regionprops(logical(nucuse),squeeze(mean(fluorim(firstgood:lastgood,:,:),1)),'WeightedCentroid');
    for j=1:length(maskstruct)
        maskstruct(j).stage=stages(j);
        transina=finderchan(transinds(transinds<=numchans),j);
        if(length(maskstruct)>=blaststage)
            maskstruct(j).blastyolk=maskstruct(blaststage).transyolk;
            maskstruct(j).transpower=mean(transim(j,~imdilate(maskstruct(blaststage).embryo,strel('disk',sesize))));
            maskstruct(j).transpowvec=squeeze(mean(double(imstruct.Images(transina(transina>0),~imdilate(maskstruct(blaststage).embryo,strel('disk',sesize)))),2));
        else
            maskstruct(j).blastyolk=maskstruct(j).yolk;
            maskstruct(j).transpower=mean(transim(j,~imdilate(maskstruct(end).embryo,strel('disk',sesize))));
            maskstruct(j).transpowvec=squeeze(mean(double(imstruct.Images(transina(transina>0),~imdilate(maskstruct(end).embryo,strel('disk',sesize)))),2));
        end
        if(j==1)
            if(j<length(maskstruct))
                maskstruct(j).premaskexc=false(size(maskstruct(j).embnovit));
                maskstruct(j).postmaskexc=maskstruct(j+1).uvexclude;
            else
                maskstruct(j).premaskexc=false(size(maskstruct(j).embnovit));
                maskstruct(j).postmaskexc=false(size(maskstruct(j).embnovit));
            end
        end
        if(j==length(maskstruct))
            maskstruct(j).postmaskexc=false(size(maskstruct(j).embnovit));
            maskstruct(j).premaskexc=maskstruct(j-1).uvexclude;
        end
        if((j>1)&&(j<length(maskstruct)))
            maskstruct(j).premaskexc=maskstruct(j-1).uvexclude;
            maskstruct(j).postmaskexc=maskstruct(j+1).uvexclude;
        end
    end
    for j=1:length(maskstruct)
        maskstruct(j).spermtip(1)=intenspro.WeightedCentroid(2); %Watch indices
        maskstruct(j).spermtip(2)=intenspro.WeightedCentroid(1);
        maskstruct2(j)=findantwsperm(maskstruct(j));
    end
   
% Now eliminate the unnecessary images from imstruct.
fluorinall=finderchan(saveinds,:);
imstruct.Images=imstruct.Images(fluorinall,:,:);
imstruct.Timeindex=imstruct.Timeindex(fluorinall);
imstruct.Channel=imstruct.Channel(fluorinall);
imstruct.GlobalTimeMin=imstruct.GlobalTimeMin(fluorinall);
imstruct.LocalTimeSec=imstruct.LocalTimeSec(fluorinall);
        
