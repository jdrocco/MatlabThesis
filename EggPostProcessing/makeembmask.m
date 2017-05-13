% This function will accept an embryo image and return the embryo mask
% maskstruct=makeembmask(im)

function maskstruct=makeembmask(im)

%First use the detectreg program to detect regions
regions=detectreg(im);

%Then figure out which is the largest--assume this is the embryo.
[fixedBWemb,spermtip]=elimsperm(regions);
BWemb=returnbiggest(fixedBWemb);

maskstruct=struct('embryo',BWemb,'spermtip',spermtip);