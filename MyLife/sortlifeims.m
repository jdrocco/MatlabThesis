

function sortlifeims(stagesorer,eggnum,perfol,egglookup)

for i=1:max(eggnum)
    egginds=find(eggnum==i);
    maxfol=ceil(length(egginds)/perfol);
        for k=1:maxfol
            folname=strcat('ims',sprintf('%d',i),char(96+k));
            mkdir(folname);
            stagevec=stagesorer(egginds(((k-1)*perfol+1):min((k*perfol),length(egginds))));
            save(strcat(folname,'/stages.mat'),'stagevec');
%             blastloc=find(stagesorer(egginds)<95,1,'last');
%             if(isempty(blastloc))
%                 break
%             end
%             [a,b]=ind2sub(size(stagesorer),egginds(blastloc));
%             copyfile(strcat('Pos',sprintf('%03d',a),'*t',sprintf('%d',b-1),'*tif'),folname)
        end
    for j=1:length(egginds)
        [a,b]=ind2sub(size(stagesorer),egginds(j));
        subfol=ceil(j/perfol);
        lookeduppos=egglookup(a);
        folname=strcat('ims',sprintf('%d',i),char(96+subfol));
        movefile(strcat('Pos',sprintf('%03d',lookeduppos),'*t',sprintf('%02d',b-1),'*tif'),folname)
        copyfile(strcat('Pos',sprintf('%03d',lookeduppos),'*xml'),folname)
    end
end