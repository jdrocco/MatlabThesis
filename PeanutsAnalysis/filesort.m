function sortedfiles=filesort(filesr)

for i=1:length(filesr)
undinds=find(filesr(i).name=='_',2,'first');
seqnum(i)=str2num(filesr(i).name((undinds(1)+1):(undinds(2)-1)));
tnum(i)=str2num(filesr(i).name((undinds(2)+2):(undinds(2)+3)));
end
for i=1:length(filesr)
compwoodnum(i)=seqnum(i)*20+tnum(i);
end
[a,b]=sort(compwoodnum);
for i=1:length(filesr)
sortedfiles(i)=filesr(b(i));
end