function imstruct=imstructresize(imstruct,firstim,lastim)

imstruct.Images=imstruct.Images(firstim:lastim,:,:);
imstruct.Timeindex=imstruct.Timeindex(firstim:lastim);
imstruct.Channel=imstruct.Channel(firstim:lastim);
imstruct.GlobalTimeMin=imstruct.GlobalTimeMin(firstim:lastim);
imstruct.LocalTimeSec=imstruct.LocalTimeSec(firstim:lastim);