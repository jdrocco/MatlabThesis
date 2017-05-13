function BWembout=fillwbord(BWembin)

BWembout=returnbiggest(BWembin);
regpro=regionprops(logical(BWembout),'SubarrayIdx','ConvexImage');

BWembout(regpro.SubarrayIdx{1},regpro.SubarrayIdx{2})=regpro.ConvexImage;
