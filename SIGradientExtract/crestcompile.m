% Takes a set of compfiles each containing several embryos at
% multiple depths and aggregates them into a single mat file

function crestcompile(totfiles,numdepths)

for n=1:totfiles
prompter=strcat('choose first file',num2str(n));
    [filein,pathin]=uigetfile('*.mat',prompter);
    firstfilename(n,1:length(filein)) = filein;
    filenamesizesave(n)=length(filein);
    pathname(n,1:length(pathin)) = pathin;
    pathnamesizesave(n)=length(pathin);
end

for fileindex=1:totfiles
    cd(pathname(fileindex,1:pathnamesizesave(fileindex)));
    load(firstfilename(fileindex,1:filenamesizesave(fileindex)));
    actualems(fileindex)=size(gomcomp,1)/numdepths;
avscc(fileindex,1:size(avscomp,1),1:size(avscomp,2),1:size(avscomp,3))=avscomp;        
becc(fileindex,1:size(becomp,1),1:size(becomp,2))=becomp;         
changecc(fileindex,1:size(changecomp,1),1:size(changecomp,2))=changecomp;     
clcc(fileindex,1:length(clcomp))=clcomp;         
egglcc(fileindex,1:length(egglcomp))=egglcomp;       
fecc(fileindex,1:size(fecomp,1),1:size(fecomp,2))=fecomp;         
gfscc(fileindex,1:size(gfscomp,1),1:size(gfscomp,2))=gfscomp;        
gomcc(fileindex,1:size(gomcomp,1),1:size(gomcomp,2),1:size(gomcomp,3))=gomcomp;        
gvxcc(fileindex,1:size(gvxcomp,1),1:size(gvxcomp,2),1:size(gvxcomp,3),1:size(gvxcomp,4))=gvxcomp;        
namescc(fileindex,1:size(namescomp,1),1:size(namescomp,2))=namescomp;      
slveccc(fileindex,1:size(slveccomp,1),1:size(slveccomp,2),1:size(slveccomp,3))=slveccomp;      
timecc(fileindex,1:size(timecomp,1),1:size(timecomp,2))=timecomp;
end

axboxes=size(gomcomp,3);
numtimes=size(gomcomp,2);
numaxes=size(avscomp,2);
totems=sum(actualems);
namelen=size(namescomp,2);

for j=1:numdepths
    for fileindex=1:totfiles;
        alreadyems=sum(actualems(1:fileindex))-actualems(fileindex);
    avsnew((((j-1)*totems)+1+alreadyems):(((j-1)*totems)+alreadyems+actualems(fileindex)),1:numaxes,1:axboxes)=squeeze(avscc(fileindex,(((j-1)*actualems(fileindex))+1):(j*actualems(fileindex)),1:numaxes,1:axboxes));
    benew((((j-1)*totems)+1+alreadyems):(((j-1)*totems)+alreadyems+actualems(fileindex)),1:numtimes)=squeeze(becc(fileindex,(((j-1)*actualems(fileindex))+1):(j*actualems(fileindex)),1:numtimes));
    changenew((((j-1)*totems)+1+alreadyems):(((j-1)*totems)+alreadyems+actualems(fileindex)),1:numtimes)=squeeze(changecc(fileindex,(((j-1)*actualems(fileindex))+1):(j*actualems(fileindex)),1:numtimes));
    clnew((((j-1)*totems)+1+alreadyems):(((j-1)*totems)+alreadyems+actualems(fileindex)))=squeeze(clcc(fileindex,(((j-1)*actualems(fileindex))+1):(j*actualems(fileindex))));
    egglnew((((j-1)*totems)+1+alreadyems):(((j-1)*totems)+alreadyems+actualems(fileindex)))=squeeze(egglcc(fileindex,(((j-1)*actualems(fileindex))+1):(j*actualems(fileindex))));
    fenew((((j-1)*totems)+1+alreadyems):(((j-1)*totems)+alreadyems+actualems(fileindex)),1:numtimes)=squeeze(fecc(fileindex,(((j-1)*actualems(fileindex))+1):(j*actualems(fileindex)),1:numtimes));
    gfsnew((((j-1)*totems)+1+alreadyems):(((j-1)*totems)+alreadyems+actualems(fileindex)),1:axboxes)=squeeze(gfscc(fileindex,(((j-1)*actualems(fileindex))+1):(j*actualems(fileindex)),1:axboxes));
    gomnew((((j-1)*totems)+1+alreadyems):(((j-1)*totems)+alreadyems+actualems(fileindex)),1:numtimes,1:axboxes)=squeeze(gomcc(fileindex,(((j-1)*actualems(fileindex))+1):(j*actualems(fileindex)),1:numtimes,1:axboxes));
    gvxnew((((j-1)*totems)+1+alreadyems):(((j-1)*totems)+alreadyems+actualems(fileindex)),1:numaxes,1:numtimes,1:axboxes)=squeeze(gvxcc(fileindex,(((j-1)*actualems(fileindex))+1):(j*actualems(fileindex)),1:numaxes,1:numtimes,1:axboxes));
    namesnew((((j-1)*totems)+1+alreadyems):(((j-1)*totems)+alreadyems+actualems(fileindex)),1:namelen)=squeeze(namescc(fileindex,(((j-1)*actualems(fileindex))+1):(j*actualems(fileindex)),1:namelen));
    slvecnew((((j-1)*totems)+1+alreadyems):(((j-1)*totems)+alreadyems+actualems(fileindex)),1:numaxes,1:axboxes)=squeeze(slveccc(fileindex,(((j-1)*actualems(fileindex))+1):(j*actualems(fileindex)),1:numaxes,1:axboxes));
    timenew((((j-1)*totems)+1+alreadyems):(((j-1)*totems)+alreadyems+actualems(fileindex)),1:numtimes)=squeeze(timecc(fileindex,(((j-1)*actualems(fileindex))+1):(j*actualems(fileindex)),1:numtimes));
    end
end

save bigmat *new
