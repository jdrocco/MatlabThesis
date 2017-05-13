function h=elliptfspecial(sigx,sigy)


hx=fspecial('gaussian',[ceil(6*sigx) 1],sigx);
hy=fspecial('gaussian',[ceil(6*sigy) 1],sigy);

h=hx*hy';