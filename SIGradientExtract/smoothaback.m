% This function applies a gaussian smoothing filter to the background image
% and normalizes the mean intensity per pixel to 1.
% Deprecated with use of NLS to compensate for background irregularities

function smoothed=smoothaback(imagein,sigmain)

if(~exist('sigmain'))
    sigmain=15;
end
% in general we set sigmain=15
imageuse=imagein;
imageuse(1,:)=imagein(2,:);
%first line often has unique problems of its own
cutofflen=ceil(2.5*sigmain);
gausspot=fspecial('gaussian',[cutofflen cutofflen],sigmain);
smoothednoremove=double(imfilter(imagein,gausspot,'replicate','same'));
smoothed=double(imfilter(imageuse,gausspot,'replicate','same'));
smoothed(1,:)=smoothednoremove(1,:);
avgall=mean(mean(smoothed(:,:)));
smoothed=smoothed./avgall;
