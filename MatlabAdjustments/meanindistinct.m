function [nowdistinctx,nowdistincty]=meanindistinct(indistinctx,indistincty)

[nowdistinctx,indicia,origia]=unique(indistinctx);
for i=1:length(nowdistinctx)
    usery=find(origia==i);
    nowdistincty(i)=nanmean(indistincty(usery));
end