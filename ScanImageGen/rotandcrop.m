function [depthcrop,depregpro]=rotandcrop(depther,emborient)

    depthorth=imrotate(depther,-emborient);
    depolog=logical(returnbiggest(depthorth>1)); %Want it to be greater than one to avoid noise
    depregpro=regionprops(depolog,'SubarrayIdx');
    depthcrop=depthorth(depregpro.SubarrayIdx{1},depregpro.SubarrayIdx{2});