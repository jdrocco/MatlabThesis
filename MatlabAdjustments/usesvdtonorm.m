%First index specifies the individual vectors

function [normedvecs,factors]=usesvdtonorm(datery)

[u,v,w]=svd(datery,'econ');
factors=u(:,1);
normedvecs=(datery./abs(repmat(u(:,1),[1 size(datery,2)])));