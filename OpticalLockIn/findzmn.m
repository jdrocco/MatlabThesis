function zmnvec=findzmn(origvec)

zmvec=origvec-nanmean(origvec);
zmnvec=zmvec/norm(zmvec);