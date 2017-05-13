function imagestack=crestleicsimpimport(labelstring,labelindex,maxims,minims)

imfiles=dir(strcat(labelstring,sprintf('%03d',labelindex),'_*tif'));

if(isempty(imfiles))
    imfiles=dir(strcat(labelstring,num2str(labelindex),'_*tif'));
end

if(~exist('minims'))
    for i=1:min([length(imfiles) maxims])
    imagestack(i,:,:)=imread(imfiles(i).name);
    end
else
    for i=max([1 minims]):min([length(imfiles) maxims])
        imagestack((i-max([1 minims])+1),:,:)=imread(imfiles(i).name);
    end
end