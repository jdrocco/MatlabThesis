%Time will now be in minutes with time zero
%representing the middle of interphase 11
%Gastrulation starts around 90 min.
function timevec=mapstagetotime(stagevec)

timevec=0.8*(stagevec-10);