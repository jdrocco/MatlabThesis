function [imparams,labelstring,labelindex]=crestleicxml(labelindex,serorpos,pathname)

if(~exist('serorpos'))
serorpos=0; % 0 for series, 1 for Pos
end

if(~exist('pathname'))
    pathname='.';
end

if(~serorpos)
    labelstring=sprintf('Series');
else
    labelstring=sprintf('Pos');
end

cd(pathname)
xmlfiles=dir(strcat('*',labelstring,sprintf('%03d',labelindex),'*xml'));
if(isempty(xmlfiles))
    xmlfiles=dir(strcat('*',labelstring,num2str(labelindex),'*xml'));
end
% For each position there will be several separate "series".  The idea here
% is to capture all the xmlfiles for a single position.

for i=1:length(xmlfiles)
[tree treeName] = xml_read (xmlfiles(i).name);
stacksize(i)=tree.Image.ImageDescription.Dimensions.DimensionDescription(3).ATTRIBUTE.NumberOfElements;
xpixels(i)=tree.Image.ImageDescription.Dimensions.DimensionDescription(1).ATTRIBUTE.NumberOfElements;
ypixels(i)=tree.Image.ImageDescription.Dimensions.DimensionDescription(2).ATTRIBUTE.NumberOfElements;
xdimreal(i)=tree.Image.ImageDescription.Dimensions.DimensionDescription(1).ATTRIBUTE.Length;
ydimreal(i)=tree.Image.ImageDescription.Dimensions.DimensionDescription(2).ATTRIBUTE.Length;
xorigin(i)=tree.Image.ImageDescription.Dimensions.DimensionDescription(1).ATTRIBUTE.Origin;
yorigin(i)=tree.Image.ImageDescription.Dimensions.DimensionDescription(2).ATTRIBUTE.Origin;
zstep(i)=tree.Image.ImageDescription.Dimensions.DimensionDescription(2).ATTRIBUTE.Length/stacksize(i);
% Here we extract the number of pixels and total length in x and y, similar
% idea but by stepzsize for z
imagesinseries(i)=length(tree.Image.TimeStampList.TimeStamp);
for j=1:imagesinseries(i)
timeinmin(i,j)=(tree.Image.TimeStampList.TimeStamp(j).ATTRIBUTE.HighInteger-29900000)*429.4967/60+tree.Image.TimeStampList.TimeStamp(j).ATTRIBUTE.LowInteger/(60*10000000);
end
% Here we calculate the time stamp in minutes from the metadata.  Absolute
% zero is some time in late 2007.
numrawchans(i)=length(tree.Image.ImageDescription.Channels.ChannelDescription);
% We also find the number of channels to import.
end

imparams=struct('stacksize',stacksize,'xpixels',xpixels,'ypixels',ypixels,'xdimreal',xdimreal,'ydimreal',ydimreal,'zstep',zstep,'imagesinseries',imagesinseries,'numrawchans',numrawchans,'timeinmin',timeinmin,'xorigin',xorigin,'yorigin',yorigin);
